package main

import (
	"bytes"
	"context"
	"database/sql"
	"encoding/json"
	"errors"
	"fmt"
	"io"
	"log/slog"
	"os"
	"path/filepath"
	"sort"
	"strings"
	"time"

	"github.com/Robert-litts/fantasy-football-archive/internal/db"
	"github.com/Robert-litts/fantasy-football-archive/internal/sleeperdb"
)

const (
	defaultOwnerIdentitiesFile       = "owner-identities.json"
	ownerIdentitiesSchemaVersion int = 1
)

type ownerIdentitiesESPNLister interface {
	GetAllLeagues(context.Context) ([]db.GetAllLeaguesRow, error)
	GetTeamsByLeagueYear(context.Context, int32) ([]db.GetTeamsByLeagueYearRow, error)
}

type ownerIdentitiesSleeperLister interface {
	ListLeagueReports(context.Context) ([]sleeperdb.ListLeagueReportsRow, error)
	ListTeamsByLeague(context.Context, int64) ([]sleeperdb.Team, error)
}

type ownerIdentitiesFile struct {
	SchemaVersion int              `json:"schema_version"`
	GeneratedAt   string           `json:"generated_at,omitempty"`
	Instructions  []string         `json:"instructions,omitempty"`
	Owners        *[]ownerIdentity `json:"owners"`
}

type ownerIdentity struct {
	Name    string               `json:"name"`
	ESPN    ownerIdentityESPN    `json:"espn,omitempty"`
	Sleeper ownerIdentitySleeper `json:"sleeper,omitempty"`
}

type ownerIdentityESPN struct {
	Names []string `json:"names,omitempty"`
}

type ownerIdentitySleeper struct {
	OwnerIDs     []string `json:"owner_ids,omitempty"`
	Usernames    []string `json:"usernames,omitempty"`
	DisplayNames []string `json:"display_names,omitempty"`
}

func ownerIdentitiesPathFromEnv() string {
	if path := strings.TrimSpace(os.Getenv("OWNER_IDENTITIES_FILE")); path != "" {
		return path
	}
	return defaultOwnerIdentitiesFile
}

func ensureOwnerIdentitiesFile(ctx context.Context, path string, espn ownerIdentitiesESPNLister, sleeper ownerIdentitiesSleeperLister, logger *slog.Logger) error {
	if strings.TrimSpace(path) == "" {
		return nil
	}
	if _, err := os.Stat(path); err == nil {
		return nil
	} else if !errors.Is(err, os.ErrNotExist) {
		return fmt.Errorf("inspect owner identities file: %w", err)
	}

	file, err := buildStarterOwnerIdentities(ctx, espn, sleeper)
	if err != nil {
		return fmt.Errorf("discover owner identities: %w", err)
	}

	dir := filepath.Dir(path)
	if err := os.MkdirAll(dir, 0o755); err != nil {
		return fmt.Errorf("create owner identities directory: %w", err)
	}

	data, err := json.MarshalIndent(file, "", "  ")
	if err != nil {
		return fmt.Errorf("encode owner identities starter file: %w", err)
	}
	data = append(data, '\n')

	temp, err := os.CreateTemp(dir, "."+filepath.Base(path)+".tmp-*")
	if err != nil {
		return fmt.Errorf("create owner identities temporary file: %w", err)
	}
	tempPath := temp.Name()
	tempClosed := false
	defer func() {
		if !tempClosed {
			_ = temp.Close()
		}
		if tempPath != "" {
			_ = os.Remove(tempPath)
		}
	}()

	n, err := temp.Write(data)
	if err != nil {
		return fmt.Errorf("write owner identities temporary file: %w", err)
	}
	if n != len(data) {
		return fmt.Errorf("write owner identities temporary file: %w", io.ErrShortWrite)
	}
	if err := temp.Chmod(0o644); err != nil {
		return fmt.Errorf("set owner identities file permissions: %w", err)
	}
	if err := temp.Sync(); err != nil {
		return fmt.Errorf("sync owner identities temporary file: %w", err)
	}
	if err := temp.Close(); err != nil {
		tempClosed = true
		return fmt.Errorf("close owner identities temporary file: %w", err)
	}
	tempClosed = true

	if err := os.Link(tempPath, path); err != nil {
		if errors.Is(err, os.ErrExist) {
			return nil
		}
		return fmt.Errorf("publish owner identities file: %w", err)
	}
	if err := os.Remove(tempPath); err != nil {
		return fmt.Errorf("remove owner identities temporary file: %w", err)
	}
	tempPath = ""

	dirFile, err := os.Open(dir)
	if err != nil {
		return fmt.Errorf("open owner identities directory for sync: %w", err)
	}
	if err := dirFile.Sync(); err != nil {
		_ = dirFile.Close()
		return fmt.Errorf("sync owner identities directory: %w", err)
	}
	if err := dirFile.Close(); err != nil {
		return fmt.Errorf("close owner identities directory: %w", err)
	}

	if logger != nil {
		logger.Info("owner identities starter file created", "path", path)
	}
	return nil
}

func buildStarterOwnerIdentities(ctx context.Context, espn ownerIdentitiesESPNLister, sleeper ownerIdentitiesSleeperLister) (ownerIdentitiesFile, error) {
	identitiesByName := make(map[string]*ownerIdentity)

	if espn != nil {
		leagues, err := espn.GetAllLeagues(ctx)
		if err != nil {
			if !errors.Is(err, sql.ErrNoRows) {
				return ownerIdentitiesFile{}, fmt.Errorf("list ESPN leagues: %w", err)
			}
			leagues = nil
		}
		for _, league := range leagues {
			teams, err := espn.GetTeamsByLeagueYear(ctx, league.ID)
			if err != nil {
				if errors.Is(err, sql.ErrNoRows) {
					continue
				}
				return ownerIdentitiesFile{}, fmt.Errorf("list ESPN teams for league %d: %w", league.ID, err)
			}
			for _, team := range teams {
				name := cleanOwnerIdentityValue(team.Owners)
				if name == "" {
					continue
				}
				identity := identityForName(identitiesByName, name)
				identity.ESPN.Names = appendUniqueSorted(identity.ESPN.Names, name)
			}
		}
	}

	if sleeper != nil {
		reports, err := sleeper.ListLeagueReports(ctx)
		if err != nil {
			if !errors.Is(err, sql.ErrNoRows) {
				return ownerIdentitiesFile{}, fmt.Errorf("list Sleeper leagues: %w", err)
			}
			reports = nil
		}
		sleeperOwnersByID := make(map[string]*ownerIdentitySleeper)
		for _, report := range reports {
			teams, err := sleeper.ListTeamsByLeague(ctx, report.LeagueID)
			if err != nil {
				if errors.Is(err, sql.ErrNoRows) {
					continue
				}
				return ownerIdentitiesFile{}, fmt.Errorf("list Sleeper teams for league %d: %w", report.LeagueID, err)
			}
			for _, team := range teams {
				ownerID := cleanOwnerIdentityValue(team.OwnerID)
				if ownerID == "" {
					continue
				}
				record := sleeperOwnersByID[ownerID]
				if record == nil {
					record = &ownerIdentitySleeper{}
					sleeperOwnersByID[ownerID] = record
				}
				record.OwnerIDs = appendUniqueSorted(record.OwnerIDs, ownerID)
				if displayName := cleanOwnerIdentityValue(team.DisplayName.String); displayName != "" {
					record.DisplayNames = appendUniqueSorted(record.DisplayNames, displayName)
				}
				if username := cleanOwnerIdentityValue(team.Username.String); username != "" {
					record.Usernames = appendUniqueSorted(record.Usernames, username)
				}
			}
		}

		ownerIDs := make([]string, 0, len(sleeperOwnersByID))
		for ownerID := range sleeperOwnersByID {
			ownerIDs = append(ownerIDs, ownerID)
		}
		sort.Strings(ownerIDs)
		for _, ownerID := range ownerIDs {
			sleeperIdentity := sleeperOwnersByID[ownerID]
			name := starterSleeperOwnerName(*sleeperIdentity)
			identity := identityForName(identitiesByName, name)
			identity.Sleeper.OwnerIDs = appendUniqueSorted(identity.Sleeper.OwnerIDs, sleeperIdentity.OwnerIDs...)
			identity.Sleeper.DisplayNames = appendUniqueSorted(identity.Sleeper.DisplayNames, sleeperIdentity.DisplayNames...)
			identity.Sleeper.Usernames = appendUniqueSorted(identity.Sleeper.Usernames, sleeperIdentity.Usernames...)
		}
	}

	owners := make([]ownerIdentity, 0, len(identitiesByName))
	for _, identity := range identitiesByName {
		owners = append(owners, *identity)
	}
	sort.Slice(owners, func(i, j int) bool {
		return owners[i].Name < owners[j].Name
	})

	return ownerIdentitiesFile{
		SchemaVersion: ownerIdentitiesSchemaVersion,
		GeneratedAt:   time.Now().UTC().Format(time.RFC3339),
		Instructions: []string{
			"Group identifiers that belong to the same person into one owner object.",
			"Set name to the canonical owner name you want displayed in stats.",
			"Sleeper owner_ids are the most stable identifiers; keep them when possible.",
			"After editing this file, restart the app so combined stats use the updated mapping.",
		},
		Owners: &owners,
	}, nil
}

func parseOwnerIdentitiesFile(path string) (map[string]string, error) {
	if strings.TrimSpace(path) == "" {
		return map[string]string{}, nil
	}
	data, err := os.ReadFile(path)
	if err != nil {
		if errors.Is(err, os.ErrNotExist) {
			return map[string]string{}, nil
		}
		return nil, err
	}

	decoder := json.NewDecoder(bytes.NewReader(data))
	decoder.DisallowUnknownFields()
	var file ownerIdentitiesFile
	if err := decoder.Decode(&file); err != nil {
		return nil, fmt.Errorf("invalid OWNER_IDENTITIES_FILE: %w", err)
	}
	if err := decoder.Decode(&struct{}{}); !errors.Is(err, io.EOF) {
		return nil, errors.New("invalid OWNER_IDENTITIES_FILE: file must contain exactly one JSON value")
	}
	if file.SchemaVersion != ownerIdentitiesSchemaVersion {
		return nil, fmt.Errorf("invalid OWNER_IDENTITIES_FILE: schema_version must be %d", ownerIdentitiesSchemaVersion)
	}
	if file.Owners == nil {
		return nil, errors.New("invalid OWNER_IDENTITIES_FILE: owners must be present and non-null")
	}

	aliases := make(map[string]string)
	for _, owner := range *file.Owners {
		canonical := cleanOwnerIdentityValue(owner.Name)
		if canonical == "" {
			return nil, errors.New("invalid OWNER_IDENTITIES_FILE: owner names must be non-empty")
		}
		for _, alias := range ownerAliasesForIdentity(owner) {
			if err := addOwnerIdentityAlias(aliases, alias, canonical); err != nil {
				return nil, err
			}
		}
	}

	return aliases, nil
}

func ownerAliasesForIdentity(owner ownerIdentity) []string {
	aliases := []string{owner.Name}
	aliases = append(aliases, owner.ESPN.Names...)
	aliases = append(aliases, owner.Sleeper.OwnerIDs...)
	aliases = append(aliases, owner.Sleeper.Usernames...)
	aliases = append(aliases, owner.Sleeper.DisplayNames...)
	return aliases
}

func addOwnerIdentityAlias(aliases map[string]string, alias, canonical string) error {
	alias = cleanOwnerIdentityValue(alias)
	canonical = cleanOwnerIdentityValue(canonical)
	if alias == "" {
		return errors.New("invalid OWNER_IDENTITIES_FILE: owner identifiers must be non-empty")
	}
	if canonical == "" {
		return errors.New("invalid OWNER_IDENTITIES_FILE: owner names must be non-empty")
	}
	if existing, ok := aliases[alias]; ok && existing != canonical {
		return fmt.Errorf("invalid OWNER_IDENTITIES_FILE: alias %q maps to both %q and %q", alias, existing, canonical)
	}
	aliases[alias] = canonical
	return nil
}

func mergeOwnerAliases(base, overrides map[string]string) (map[string]string, error) {
	normalizedBase, err := normalizeOwnerAliasMap(base, "owner identity aliases")
	if err != nil {
		return nil, err
	}
	normalizedOverrides, err := normalizeOwnerAliasMap(overrides, "OWNER_ALIASES_JSON")
	if err != nil {
		return nil, err
	}

	merged := make(map[string]string, len(normalizedBase)+len(normalizedOverrides))
	for alias, canonical := range normalizedBase {
		merged[alias] = canonical
	}
	for alias, canonical := range normalizedOverrides {
		merged[alias] = canonical
	}

	keys := make([]string, 0, len(merged))
	for alias := range merged {
		keys = append(keys, alias)
	}
	sort.Strings(keys)

	flattened := make(map[string]string, len(merged))
	for _, alias := range keys {
		canonical, err := resolveOwnerAlias(alias, merged)
		if err != nil {
			return nil, err
		}
		flattened[alias] = canonical
	}
	return flattened, nil
}

func normalizeOwnerAliasMap(aliases map[string]string, source string) (map[string]string, error) {
	keys := make([]string, 0, len(aliases))
	for alias := range aliases {
		keys = append(keys, alias)
	}
	sort.Strings(keys)

	normalized := make(map[string]string, len(aliases))
	for _, alias := range keys {
		normalizedAlias := cleanOwnerIdentityValue(alias)
		normalizedCanonical := cleanOwnerIdentityValue(aliases[alias])
		if normalizedAlias == "" || normalizedCanonical == "" {
			return nil, fmt.Errorf("invalid %s: aliases and canonical names must be non-empty", source)
		}
		if existing, ok := normalized[normalizedAlias]; ok && existing != normalizedCanonical {
			return nil, fmt.Errorf("invalid %s: normalized alias %q maps to both %q and %q", source, normalizedAlias, existing, normalizedCanonical)
		}
		normalized[normalizedAlias] = normalizedCanonical
	}
	return normalized, nil
}

func resolveOwnerAlias(alias string, aliases map[string]string) (string, error) {
	path := make([]string, 0)
	positions := make(map[string]int)
	current := alias
	for {
		positions[current] = len(path)
		path = append(path, current)

		next, ok := aliases[current]
		if !ok {
			return current, nil
		}
		if next == current {
			return current, nil
		}
		if start, ok := positions[next]; ok {
			cycle := append([]string(nil), path[start:]...)
			first := 0
			for i := 1; i < len(cycle); i++ {
				if cycle[i] < cycle[first] {
					first = i
				}
			}
			rotated := append(append([]string(nil), cycle[first:]...), cycle[:first]...)
			cycle = append(rotated, rotated[0])
			for i := range cycle {
				cycle[i] = fmt.Sprintf("%q", cycle[i])
			}
			return "", fmt.Errorf("owner alias cycle detected: %s", strings.Join(cycle, " -> "))
		}
		current = next
	}
}

func identityForName(identities map[string]*ownerIdentity, name string) *ownerIdentity {
	name = cleanOwnerIdentityValue(name)
	identity := identities[name]
	if identity == nil {
		identity = &ownerIdentity{Name: name}
		identities[name] = identity
	}
	return identity
}

func starterSleeperOwnerName(owner ownerIdentitySleeper) string {
	if len(owner.DisplayNames) > 0 {
		return owner.DisplayNames[0]
	}
	if len(owner.Usernames) > 0 {
		return owner.Usernames[0]
	}
	if len(owner.OwnerIDs) > 0 {
		return owner.OwnerIDs[0]
	}
	return "Unknown"
}

func appendUniqueSorted(values []string, additions ...string) []string {
	seen := make(map[string]bool, len(values)+len(additions))
	result := make([]string, 0, len(values)+len(additions))
	for _, value := range append(values, additions...) {
		cleaned := cleanOwnerIdentityValue(value)
		if cleaned == "" || seen[cleaned] {
			continue
		}
		seen[cleaned] = true
		result = append(result, cleaned)
	}
	sort.Strings(result)
	return result
}

func cleanOwnerIdentityValue(value string) string {
	return strings.Join(strings.Fields(strings.TrimSpace(value)), " ")
}
