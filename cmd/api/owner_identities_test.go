package main

import (
	"context"
	"database/sql"
	"errors"
	"fmt"
	"os"
	"path/filepath"
	"testing"

	"github.com/Robert-litts/fantasy-football-archive/internal/db"
	"github.com/Robert-litts/fantasy-football-archive/internal/sleeperdb"
)

func TestParseOwnerIdentitiesFileBuildsAliasMap(t *testing.T) {
	path := filepath.Join(t.TempDir(), "owner-identities.json")
	err := os.WriteFile(path, []byte(`{
  "schema_version": 1,
  "owners": [
    {
      "name": "Robbie",
      "espn": {"names": ["Robert Litts"]},
      "sleeper": {
        "owner_ids": ["123456789"],
        "usernames": ["robbie_sleeper"],
        "display_names": ["Robbie"]
      }
    }
  ]
}`), 0o600)
	if err != nil {
		t.Fatalf("WriteFile returned error: %v", err)
	}

	aliases, err := parseOwnerIdentitiesFile(path)
	if err != nil {
		t.Fatalf("parseOwnerIdentitiesFile returned error: %v", err)
	}

	for _, alias := range []string{"Robbie", "Robert Litts", "123456789", "robbie_sleeper"} {
		if aliases[alias] != "Robbie" {
			t.Fatalf("aliases[%q] = %q, want Robbie", alias, aliases[alias])
		}
	}
}

func TestParseOwnerIdentitiesFileRejectsConflictingAliases(t *testing.T) {
	path := filepath.Join(t.TempDir(), "owner-identities.json")
	err := os.WriteFile(path, []byte(`{
  "schema_version": 1,
  "owners": [
    {"name": "Robbie", "sleeper": {"owner_ids": ["123"]}},
    {"name": "Bobby", "sleeper": {"owner_ids": ["123"]}}
  ]
}`), 0o600)
	if err != nil {
		t.Fatalf("WriteFile returned error: %v", err)
	}

	if _, err := parseOwnerIdentitiesFile(path); err == nil {
		t.Fatal("parseOwnerIdentitiesFile returned nil error, want alias conflict")
	}
}

func TestParseOwnerIdentitiesFileRejectsInvalidSchema(t *testing.T) {
	tests := []struct {
		name string
		raw  string
	}{
		{"unknown field", `{"schema_version":1,"owners":[],"unknown":true}`},
		{"unknown nested field", `{"schema_version":1,"owners":[{"name":"Robbie","espn":{"names":[],"unknown":true}}]}`},
		{"wrong version", `{"schema_version":2,"owners":[]}`},
		{"missing owners", `{"schema_version":1}`},
		{"null owners", `{"schema_version":1,"owners":null}`},
		{"blank owner name", `{"schema_version":1,"owners":[{"name":"  "}]}`},
		{"multiple values", `{"schema_version":1,"owners":[]} {}`},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			path := writeOwnerIdentitiesTestFile(t, tt.raw)
			if _, err := parseOwnerIdentitiesFile(path); err == nil {
				t.Fatal("parseOwnerIdentitiesFile returned nil error")
			}
		})
	}
}

func TestParseOwnerIdentitiesFileRejectsBlankIdentifiers(t *testing.T) {
	identifiers := []string{
		`"espn":{"names":["  "]}`,
		`"sleeper":{"owner_ids":["  "]}`,
		`"sleeper":{"usernames":["  "]}`,
		`"sleeper":{"display_names":["  "]}`,
	}
	for _, identifier := range identifiers {
		path := writeOwnerIdentitiesTestFile(t, fmt.Sprintf(`{"schema_version":1,"owners":[{"name":"Robbie",%s}]}`, identifier))
		if _, err := parseOwnerIdentitiesFile(path); err == nil {
			t.Fatalf("parseOwnerIdentitiesFile accepted %s", identifier)
		}
	}
}

func TestParseOwnerIdentitiesFileMissingPathReturnsEmptyMap(t *testing.T) {
	aliases, err := parseOwnerIdentitiesFile(filepath.Join(t.TempDir(), "missing.json"))
	if err != nil {
		t.Fatalf("parseOwnerIdentitiesFile returned error: %v", err)
	}
	if len(aliases) != 0 {
		t.Fatalf("aliases = %v, want empty map", aliases)
	}
}

func TestMergeOwnerAliasesFlattensNormalizedChainsAndAcceptsSelf(t *testing.T) {
	aliases, err := mergeOwnerAliases(
		map[string]string{" A ": " B ", "B": " C ", " C ": " C "},
		nil,
	)
	if err != nil {
		t.Fatalf("mergeOwnerAliases returned error: %v", err)
	}
	for _, alias := range []string{"A", "B", "C"} {
		if aliases[alias] != "C" {
			t.Fatalf("aliases[%q] = %q, want C", alias, aliases[alias])
		}
	}
}

func TestMergeOwnerAliasesEnvironmentOverridesExactKey(t *testing.T) {
	aliases, err := mergeOwnerAliases(
		map[string]string{"Alias": "Base", "Base": "Base"},
		map[string]string{"Alias": "Environment", "Environment": "Environment"},
	)
	if err != nil {
		t.Fatalf("mergeOwnerAliases returned error: %v", err)
	}
	if aliases["Alias"] != "Environment" {
		t.Fatalf("aliases[Alias] = %q, want Environment", aliases["Alias"])
	}
}

func TestMergeOwnerAliasesRejectsCyclesDeterministically(t *testing.T) {
	_, err := mergeOwnerAliases(map[string]string{"C": "B", "A": "C", "B": "C"}, nil)
	if err == nil {
		t.Fatal("mergeOwnerAliases returned nil error")
	}
	want := `owner alias cycle detected: "B" -> "C" -> "B"`
	if err.Error() != want {
		t.Fatalf("error = %q, want %q", err, want)
	}
}

func TestParseOwnerAliasesJSONRejectsNormalizedConflictsDeterministically(t *testing.T) {
	_, err := parseOwnerAliasesJSON(`{"Robbie":"One"," Robbie ":"Two"}`)
	if err == nil {
		t.Fatal("parseOwnerAliasesJSON returned nil error")
	}
	want := `invalid OWNER_ALIASES_JSON: normalized alias "Robbie" maps to both "Two" and "One"`
	if err.Error() != want {
		t.Fatalf("error = %q, want %q", err, want)
	}
}

func TestEnsureOwnerIdentitiesFileCreatesStarterFromArchives(t *testing.T) {
	path := filepath.Join(t.TempDir(), "config", "owner-identities.json")
	err := ensureOwnerIdentitiesFile(
		context.Background(),
		path,
		ownerIdentityESPNStub{
			leagues: []db.GetAllLeaguesRow{{ID: 1, Year: 2022}},
			teams: map[int32][]db.GetTeamsByLeagueYearRow{
				1: {{Owners: "ESPN Robbie"}},
			},
		},
		ownerIdentitySleeperStub{
			reports: []sleeperdb.ListLeagueReportsRow{{LeagueID: 2001}},
			teams: map[int64][]sleeperdb.Team{
				2001: {{OwnerID: "sleeper-robbie", DisplayName: sqlNullString("Robbie"), Username: sqlNullString("rob")}},
			},
		},
		nil,
	)
	if err != nil {
		t.Fatalf("ensureOwnerIdentitiesFile returned error: %v", err)
	}

	aliases, err := parseOwnerIdentitiesFile(path)
	if err != nil {
		t.Fatalf("parseOwnerIdentitiesFile returned error: %v", err)
	}
	if aliases["ESPN Robbie"] != "ESPN Robbie" {
		t.Fatalf("ESPN alias = %q, want ESPN Robbie", aliases["ESPN Robbie"])
	}
	if aliases["sleeper-robbie"] != "Robbie" {
		t.Fatalf("Sleeper owner id alias = %q, want Robbie", aliases["sleeper-robbie"])
	}
}

func TestEnsureOwnerIdentitiesFileAllowsNilSleeperAndZeroOwners(t *testing.T) {
	path := filepath.Join(t.TempDir(), "owner-identities.json")
	if err := ensureOwnerIdentitiesFile(context.Background(), path, ownerIdentityESPNStub{}, nil, nil); err != nil {
		t.Fatalf("ensureOwnerIdentitiesFile returned error: %v", err)
	}
	aliases, err := parseOwnerIdentitiesFile(path)
	if err != nil {
		t.Fatalf("parseOwnerIdentitiesFile returned error: %v", err)
	}
	if len(aliases) != 0 {
		t.Fatalf("aliases = %v, want empty map", aliases)
	}
}

func TestEnsureOwnerIdentitiesFileDiscoveryFailureWritesNoFile(t *testing.T) {
	discoveryErr := errors.New("discovery failed")
	tests := []struct {
		name    string
		espn    ownerIdentitiesESPNLister
		sleeper ownerIdentitiesSleeperLister
	}{
		{"ESPN league list", ownerIdentityESPNStub{listErr: discoveryErr}, nil},
		{"ESPN team list", ownerIdentityESPNStub{leagues: []db.GetAllLeaguesRow{{ID: 1}}, teamErrs: map[int32]error{1: discoveryErr}}, nil},
		{"Sleeper league list", nil, ownerIdentitySleeperStub{listErr: discoveryErr}},
		{"Sleeper team list", nil, ownerIdentitySleeperStub{reports: []sleeperdb.ListLeagueReportsRow{{LeagueID: 1}}, teamErrs: map[int64]error{1: discoveryErr}}},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			path := filepath.Join(t.TempDir(), "owner-identities.json")
			err := ensureOwnerIdentitiesFile(context.Background(), path, tt.espn, tt.sleeper, nil)
			if !errors.Is(err, discoveryErr) {
				t.Fatalf("error = %v, want wrapped discovery error", err)
			}
			if _, err := os.Stat(path); !errors.Is(err, os.ErrNotExist) {
				t.Fatalf("os.Stat error = %v, want file not to exist", err)
			}
		})
	}
}

func TestEnsureOwnerIdentitiesFilePreservesExistingFile(t *testing.T) {
	path := filepath.Join(t.TempDir(), "owner-identities.json")
	want := []byte("existing content")
	if err := os.WriteFile(path, want, 0o600); err != nil {
		t.Fatalf("WriteFile returned error: %v", err)
	}
	if err := ensureOwnerIdentitiesFile(context.Background(), path, ownerIdentityESPNStub{listErr: errors.New("must not run")}, nil, nil); err != nil {
		t.Fatalf("ensureOwnerIdentitiesFile returned error: %v", err)
	}
	got, err := os.ReadFile(path)
	if err != nil {
		t.Fatalf("ReadFile returned error: %v", err)
	}
	if string(got) != string(want) {
		t.Fatalf("file content = %q, want %q", got, want)
	}
}

func TestEnsureOwnerIdentitiesFilePublicationRacePreservesFileAndCleansTemp(t *testing.T) {
	dir := t.TempDir()
	path := filepath.Join(dir, "owner-identities.json")
	want := []byte("concurrent content")
	var callbackErr error
	espn := ownerIdentityESPNStub{onList: func() {
		callbackErr = os.WriteFile(path, want, 0o600)
	}}

	if err := ensureOwnerIdentitiesFile(context.Background(), path, espn, nil, nil); err != nil {
		t.Fatalf("ensureOwnerIdentitiesFile returned error: %v", err)
	}
	if callbackErr != nil {
		t.Fatalf("concurrent WriteFile returned error: %v", callbackErr)
	}
	got, err := os.ReadFile(path)
	if err != nil {
		t.Fatalf("ReadFile returned error: %v", err)
	}
	if string(got) != string(want) {
		t.Fatalf("file content = %q, want %q", got, want)
	}
	temps, err := filepath.Glob(filepath.Join(dir, ".owner-identities.json.tmp-*"))
	if err != nil {
		t.Fatalf("Glob returned error: %v", err)
	}
	if len(temps) != 0 {
		t.Fatalf("temporary files remain: %v", temps)
	}
}

type ownerIdentityESPNStub struct {
	leagues  []db.GetAllLeaguesRow
	teams    map[int32][]db.GetTeamsByLeagueYearRow
	listErr  error
	teamErrs map[int32]error
	onList   func()
}

func (s ownerIdentityESPNStub) GetAllLeagues(context.Context) ([]db.GetAllLeaguesRow, error) {
	if s.onList != nil {
		s.onList()
	}
	if s.listErr != nil {
		return nil, s.listErr
	}
	return s.leagues, nil
}

func (s ownerIdentityESPNStub) GetTeamsByLeagueYear(_ context.Context, id int32) ([]db.GetTeamsByLeagueYearRow, error) {
	if err := s.teamErrs[id]; err != nil {
		return nil, err
	}
	if rows, ok := s.teams[id]; ok {
		return rows, nil
	}
	return nil, sql.ErrNoRows
}

type ownerIdentitySleeperStub struct {
	reports  []sleeperdb.ListLeagueReportsRow
	teams    map[int64][]sleeperdb.Team
	listErr  error
	teamErrs map[int64]error
}

func (s ownerIdentitySleeperStub) ListLeagueReports(context.Context) ([]sleeperdb.ListLeagueReportsRow, error) {
	if s.listErr != nil {
		return nil, s.listErr
	}
	return s.reports, nil
}

func (s ownerIdentitySleeperStub) ListTeamsByLeague(_ context.Context, id int64) ([]sleeperdb.Team, error) {
	if err := s.teamErrs[id]; err != nil {
		return nil, err
	}
	if rows, ok := s.teams[id]; ok {
		return rows, nil
	}
	return nil, sql.ErrNoRows
}

func writeOwnerIdentitiesTestFile(t *testing.T, raw string) string {
	t.Helper()
	path := filepath.Join(t.TempDir(), "owner-identities.json")
	if err := os.WriteFile(path, []byte(raw), 0o600); err != nil {
		t.Fatalf("WriteFile returned error: %v", err)
	}
	return path
}
