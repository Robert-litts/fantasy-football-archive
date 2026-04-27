package main

import (
	"context"
	"database/sql"
	"encoding/json"
	"errors"
	"testing"

	"github.com/Robert-litts/fantasy-football-archive/internal/archive"
	"github.com/Robert-litts/fantasy-football-archive/internal/db"
	draftsview "github.com/Robert-litts/fantasy-football-archive/internal/draftsview"
	"github.com/Robert-litts/fantasy-football-archive/internal/sleeperdb"
)

func TestBuildDraftsPageDataDefaultsToFirstArchiveLeague(t *testing.T) {
	page, err := buildDraftsPageData(
		context.Background(),
		draftsArchiveStub{
			leagueList: archive.LeagueList{
				Leagues: []archive.LeagueSummary{
					{Provider: archive.ProviderESPN, ID: 11, Season: 2021, Name: "ESPN 2021", TeamCount: 2},
					{Provider: archive.ProviderSleeper, ID: 2001, Season: 2022, Name: "Sleeper 2022", TeamCount: 2},
				},
			},
		},
		draftsESPNStub{
			rows: map[int32][]db.GetDraftBoardWithSummaryRow{
				11: {
					{OverallPick: 1, RoundNum: 1, RoundPick: 1, TeamName: "Alpha", PlayerName: "First Player", PlayerEspnID: 123, PlayerPosition: sqlNullString("qb"), TeamCount: 2},
					{OverallPick: 2, RoundNum: 1, RoundPick: 2, TeamName: "Beta", PlayerName: "Second Player", PlayerEspnID: 456, PlayerPosition: sqlNullString("te"), TeamCount: 2},
				},
			},
		},
		draftsSleeperStub{},
		"",
	)
	if err != nil {
		t.Fatalf("buildDraftsPageData returned error: %v", err)
	}

	if page.SelectedLeague.Provider != archive.ProviderESPN || page.SelectedLeague.ID != 11 {
		t.Fatalf("selected league = %#v, want ESPN league 11", page.SelectedLeague)
	}
	if len(page.Picks) != 2 {
		t.Fatalf("len(Picks) = %d, want 2", len(page.Picks))
	}
	if page.MaxRounds != 1 || page.MaxPicks != 2 || page.TeamCount != 2 {
		t.Fatalf("draft dimensions = rounds %d picks %d teams %d, want 1/2/2", page.MaxRounds, page.MaxPicks, page.TeamCount)
	}
	if page.Picks[0].Position != "QB" {
		t.Fatalf("first pick position = %q, want QB", page.Picks[0].Position)
	}
}

func TestBuildDraftsPageDataUsesProviderAwareSelectionKey(t *testing.T) {
	page, err := buildDraftsPageData(
		context.Background(),
		draftsArchiveStub{
			leagueList: archive.LeagueList{
				Leagues: []archive.LeagueSummary{
					{Provider: archive.ProviderESPN, ID: 8, Season: 2018, Name: "ESPN 2018", TeamCount: 2},
					{Provider: archive.ProviderSleeper, ID: 8, Season: 2025, Name: "Sleeper 2025", TeamCount: 2},
				},
				SleeperAvailable: true,
			},
		},
		draftsESPNStub{
			rows: map[int32][]db.GetDraftBoardWithSummaryRow{
				8: {
					{OverallPick: 1, RoundNum: 1, RoundPick: 1, TeamName: "ESPN Team", PlayerName: "ESPN Player", PlayerEspnID: 100, TeamCount: 2},
				},
			},
		},
		draftsSleeperStub{
			rows: map[int64][]sleeperdb.ListDraftPicksByLeagueRow{
				8: {
					{OverallPick: 1, RoundNum: 1, RoundPick: 1, TeamName: "Sleeper Team", PlayerName: "sleeperplayer", FirstName: sqlNullString("Sleeper"), LastName: sqlNullString("Player"), EspnID: sqlNullString("200"), Position: sqlNullString("wr")},
					{OverallPick: 2, RoundNum: 1, RoundPick: 2, TeamName: "Sleeper Team 2", PlayerName: "anothersleeper", FirstName: sqlNullString("Another"), LastName: sqlNullString("Sleeper"), Position: sqlNullString("rb")},
				},
			},
		},
		"sleeper:8",
	)
	if err != nil {
		t.Fatalf("buildDraftsPageData returned error: %v", err)
	}

	if page.SelectedLeague.Provider != archive.ProviderSleeper || page.SelectedLeague.Season != 2025 {
		t.Fatalf("selected league = %#v, want Sleeper 2025", page.SelectedLeague)
	}
	if page.SelectedLeagueKey != "sleeper:8" {
		t.Fatalf("SelectedLeagueKey = %q, want sleeper:8", page.SelectedLeagueKey)
	}
	if len(page.Picks) != 2 {
		t.Fatalf("len(Picks) = %d, want 2 sleeper picks", len(page.Picks))
	}
	if page.Picks[0].PlayerName != "Sleeper Player" || page.Picks[0].Position != "WR" {
		t.Fatalf("first pick = %#v, want normalized Sleeper display name and uppercase position", page.Picks[0])
	}
}

func TestBuildDraftsPageDataHandlesSleeperUnavailableGracefully(t *testing.T) {
	page, err := buildDraftsPageData(
		context.Background(),
		draftsArchiveStub{
			leagueList: archive.LeagueList{
				Leagues:          []archive.LeagueSummary{{Provider: archive.ProviderSleeper, ID: 2001, Season: 2022, Name: "Dynasty Ship", TeamCount: 12}},
				SleeperAvailable: true,
			},
		},
		draftsESPNStub{},
		draftsSleeperStub{err: errors.New("sleeper down")},
		"sleeper:2001",
	)
	if err != nil {
		t.Fatalf("buildDraftsPageData returned error: %v", err)
	}

	if page.SleeperMessage != "Sleeper draft data is temporarily unavailable" {
		t.Fatalf("SleeperMessage = %q, want temporary-unavailable notice", page.SleeperMessage)
	}
	if len(page.Picks) != 0 {
		t.Fatalf("len(Picks) = %d, want 0", len(page.Picks))
	}
}

func TestNormalizeDraftSelectionKeyKeepsLegacyNumericIDsOnESPN(t *testing.T) {
	got, err := normalizeDraftSelectionKey("42")
	if err != nil {
		t.Fatalf("normalizeDraftSelectionKey returned error: %v", err)
	}
	if got != "espn:42" {
		t.Fatalf("selection key = %q, want espn:42", got)
	}
}

func TestNormalizeDraftPositionHandlesProviderAliases(t *testing.T) {
	tests := map[string]string{
		"quarterback":           "QB",
		"running_back":          "RB",
		"wide receiver":         "WR",
		"tight-end":             "TE",
		"D/ST":                  "D/ST",
		"defense special teams": "D/ST",
		"17":                    "K",
		"wr":                    "WR",
	}

	for input, want := range tests {
		if got := normalizeDraftPosition(input); got != want {
			t.Fatalf("normalizeDraftPosition(%q) = %q, want %q", input, got, want)
		}
	}
}

func TestESPNAthletePositionParsesAPIShapes(t *testing.T) {
	objectValue := json.RawMessage(`{"abbreviation":"RB","name":"Running Back"}`)
	if got := espnAthletePosition(objectValue); got != "RB" {
		t.Fatalf("espnAthletePosition(object) = %q, want RB", got)
	}

	stringValue := json.RawMessage(`"wide receiver"`)
	if got := espnAthletePosition(stringValue); got != "WR" {
		t.Fatalf("espnAthletePosition(string) = %q, want WR", got)
	}
}

func TestApplyESPNDraftPositionFallbackUsesSleeperDBFirst(t *testing.T) {
	picks := []draftsview.PickRow{
		{PlayerESPNID: "100"},
		{PlayerESPNID: "200"},
		{PlayerESPNID: "300", Position: "QB"},
	}
	var apiIDs []string
	originalLoader := loadESPNAthletePositionsFunc
	loadESPNAthletePositionsFunc = func(_ context.Context, ids []string) (map[string]string, error) {
		apiIDs = append(apiIDs, ids...)
		return map[string]string{"200": "TE"}, nil
	}
	defer func() {
		loadESPNAthletePositionsFunc = originalLoader
	}()

	applyESPNDraftPositionFallback(
		context.Background(),
		picks,
		draftsSleeperPositionStub{
			rows: []sleeperdb.PlayerPositionByESPNID{
				{ESPNID: "100", Position: sqlNullString("wide receiver")},
			},
		},
	)

	if picks[0].Position != "WR" {
		t.Fatalf("fallback position = %q, want WR from Sleeper DB", picks[0].Position)
	}
	if picks[1].Position != "TE" {
		t.Fatalf("api fallback position = %q, want TE", picks[1].Position)
	}
	if picks[2].Position != "QB" {
		t.Fatalf("existing position = %q, want unchanged QB", picks[2].Position)
	}
	if len(apiIDs) != 1 || apiIDs[0] != "200" {
		t.Fatalf("api fallback IDs = %#v, want only missing ID 200", apiIDs)
	}
}

type draftsArchiveStub struct {
	leagueList archive.LeagueList
	err        error
}

func (s draftsArchiveStub) ListLeagueSummaries(context.Context) (archive.LeagueList, error) {
	return s.leagueList, s.err
}

type draftsESPNStub struct {
	rows map[int32][]db.GetDraftBoardWithSummaryRow
	err  error
}

func (s draftsESPNStub) GetDraftBoardWithSummary(_ context.Context, id int32) ([]db.GetDraftBoardWithSummaryRow, error) {
	if s.err != nil {
		return nil, s.err
	}
	if rows, ok := s.rows[id]; ok {
		return rows, nil
	}
	return nil, sql.ErrNoRows
}

type draftsSleeperStub struct {
	rows map[int64][]sleeperdb.ListDraftPicksByLeagueRow
	err  error
}

func (s draftsSleeperStub) ListDraftPicksByLeague(_ context.Context, id int64) ([]sleeperdb.ListDraftPicksByLeagueRow, error) {
	if s.err != nil {
		return nil, s.err
	}
	if rows, ok := s.rows[id]; ok {
		return rows, nil
	}
	return nil, sql.ErrNoRows
}

type draftsSleeperPositionStub struct {
	rows []sleeperdb.PlayerPositionByESPNID
	err  error
}

func (s draftsSleeperPositionStub) ListPlayerPositionsByESPNIDs(context.Context, []string) ([]sleeperdb.PlayerPositionByESPNID, error) {
	return s.rows, s.err
}
