package archive

import (
	"context"
	"database/sql"
	"errors"
	"testing"

	"github.com/Robert-litts/fantasy-football-archive/internal/db"
	"github.com/Robert-litts/fantasy-football-archive/internal/sleeperdb"
)

func TestListLeagueSummariesMergesESPNAndSleeper(t *testing.T) {
	svc := New(
		espnStub{leagues: []db.League{
			{ID: 11, LeagueId: 1001, Year: 2021, TeamCount: 10},
			{ID: 12, LeagueId: 1002, Year: 2022, TeamCount: 12},
		}},
		nil,
		sleeperStub{reports: []sleeperdb.ListLeagueReportsRow{
			{LeagueID: 2001, Season: 2022, Name: "Dynasty Ship", TeamCount: 12, ChampionTeamName: "Alice", RunnerUpTeamName: "Bob"},
			{LeagueID: 2002, Season: 2023, Name: "Rebuild Royale", TeamCount: 14, ChampionTeamName: "Carol", RunnerUpTeamName: "Dave"},
		}},
		nil,
		nil,
		"",
	)

	got, err := svc.ListLeagueSummaries(context.Background())
	if err != nil {
		t.Fatalf("ListLeagueSummaries returned error: %v", err)
	}

	wantOrder := []struct {
		season   int32
		provider Provider
		name     string
	}{
		{2021, ProviderESPN, "ESPN 1001"},
		{2022, ProviderESPN, "ESPN 1002"},
		{2022, ProviderSleeper, "Dynasty Ship"},
		{2023, ProviderSleeper, "Rebuild Royale"},
	}
	if len(got.Leagues) != len(wantOrder) {
		t.Fatalf("len(Leagues) = %d, want %d", len(got.Leagues), len(wantOrder))
	}
	for i, want := range wantOrder {
		league := got.Leagues[i]
		if league.Season != want.season || league.Provider != want.provider || league.Name != want.name {
			t.Fatalf("league[%d] = %#v, want season=%d provider=%s name=%q", i, league, want.season, want.provider, want.name)
		}
	}

	if !got.SleeperAvailable {
		t.Fatal("SleeperAvailable = false, want true")
	}
	if got.SleeperMessage != "" {
		t.Fatalf("SleeperMessage = %q, want empty", got.SleeperMessage)
	}
	if got.Leagues[2].Champion != "Alice" || got.Leagues[2].RunnerUp != "Bob" {
		t.Fatalf("sleeper champion/runner-up = %#v, want Alice/Bob", got.Leagues[2])
	}
}

func TestListLeagueSummariesHandlesMissingSleeperDatabase(t *testing.T) {
	svc := New(
		espnStub{leagues: []db.League{
			{ID: 11, LeagueId: 1001, Year: 2021, TeamCount: 10},
		}},
		nil,
		nil,
		nil,
		nil,
		"",
	)

	got, err := svc.ListLeagueSummaries(context.Background())
	if err != nil {
		t.Fatalf("ListLeagueSummaries returned error: %v", err)
	}

	if len(got.Leagues) != 1 {
		t.Fatalf("len(Leagues) = %d, want 1", len(got.Leagues))
	}
	if got.SleeperAvailable {
		t.Fatal("SleeperAvailable = true, want false")
	}
	if got.SleeperMessage == "" {
		t.Fatal("SleeperMessage = empty, want notice")
	}
}

func TestListLeagueSummariesReturnsESPNError(t *testing.T) {
	svc := New(
		espnStub{err: errors.New("espn down")},
		nil,
		nil,
		nil,
		nil,
		"",
	)

	if _, err := svc.ListLeagueSummaries(context.Background()); err == nil {
		t.Fatal("ListLeagueSummaries returned nil error, want ESPN failure")
	}
}

func TestListLeagueSummariesDerivesESPNChampions(t *testing.T) {
	svc := New(
		espnStub{leagues: []db.League{
			{ID: 99, LeagueId: 747376, Year: 2024, TeamCount: 12},
		}},
		espnMatchupStub{matchups: map[int32][]db.GetMatchupsByLeagueIdRow{
			99: []db.GetMatchupsByLeagueIdRow{
				{
					Week:           14,
					HomeTeamID:     validID(1),
					AwayTeamID:     validID(2),
					HomeScore:      125.4,
					AwayScore:      117.8,
					IsPlayoff:      true,
					MatchupType:    "WINNERS_BRACKET",
					HomeTeamName:   "Alpha Squad",
					HomeTeamOwners: "Alice",
					AwayTeamName:   "Beta Crew",
					AwayTeamOwners: "Bob",
				},
			},
		}},
		nil,
		nil,
		map[string]string{"alice": "Alice"},
		"",
	)

	got, err := svc.ListLeagueSummaries(context.Background())
	if err != nil {
		t.Fatalf("ListLeagueSummaries returned error: %v", err)
	}
	if len(got.Leagues) != 1 {
		t.Fatalf("len(Leagues) = %d, want 1", len(got.Leagues))
	}
	league := got.Leagues[0]
	if league.Name != "ESPN 747376" {
		t.Fatalf("league.Name = %q, want ESPN 747376", league.Name)
	}
	if league.Champion != "Alpha Squad" || league.ChampionOwner != "Alice" || league.RunnerUp != "Beta Crew" || league.RunnerUpOwner != "Bob" {
		t.Fatalf("league finals = %#v, want champion Alpha Squad (Alice) runner-up Beta Crew (Bob)", league)
	}
}

func TestListCanonicalLeagueSummariesFiltersSleeperCanonicalLeagueID(t *testing.T) {
	svc := New(
		espnStub{leagues: []db.League{
			{ID: 11, LeagueId: 1001, Year: 2021, TeamCount: 10},
		}},
		nil,
		sleeperStub{reports: []sleeperdb.ListLeagueReportsRow{
			{LeagueID: 2001, SleeperLeagueID: "main-sleeper", CanonicalLeagueID: "main-sleeper", Season: 2022, Name: "Main League", TeamCount: 12},
			{LeagueID: 2002, SleeperLeagueID: "side-sleeper", CanonicalLeagueID: "", Season: 2022, Name: "Other League", TeamCount: 10},
		}},
		nil,
		nil,
		"main-sleeper",
	)

	got, err := svc.ListCanonicalLeagueSummaries(context.Background())
	if err != nil {
		t.Fatalf("ListCanonicalLeagueSummaries returned error: %v", err)
	}

	if len(got.Leagues) != 2 {
		t.Fatalf("len(Leagues) = %d, want ESPN plus one main Sleeper league", len(got.Leagues))
	}
	if got.Leagues[0].Provider != ProviderESPN {
		t.Fatalf("first league = %#v, want ESPN league included", got.Leagues[0])
	}
	if got.Leagues[1].Provider != ProviderSleeper || got.Leagues[1].Name != "Main League" {
		t.Fatalf("second league = %#v, want main Sleeper league only", got.Leagues[1])
	}
}

func TestListLeagueSummariesStillShowsAllSleeperLeagues(t *testing.T) {
	svc := New(
		espnStub{},
		nil,
		sleeperStub{reports: []sleeperdb.ListLeagueReportsRow{
			{LeagueID: 2001, SleeperLeagueID: "main-sleeper", CanonicalLeagueID: "main-sleeper", Season: 2022, Name: "Main League", TeamCount: 12},
			{LeagueID: 2002, SleeperLeagueID: "side-sleeper", CanonicalLeagueID: "", Season: 2022, Name: "Other League", TeamCount: 10},
		}},
		nil,
		nil,
		"main-sleeper",
	)

	got, err := svc.ListLeagueSummaries(context.Background())
	if err != nil {
		t.Fatalf("ListLeagueSummaries returned error: %v", err)
	}

	if len(got.Leagues) != 2 {
		t.Fatalf("len(Leagues) = %d, want unfiltered league list", len(got.Leagues))
	}
}

func TestListCanonicalLeagueSummariesIncludesAnyCanonicalSleeperLeagueWithoutConfiguredSeed(t *testing.T) {
	svc := New(
		espnStub{},
		nil,
		sleeperStub{reports: []sleeperdb.ListLeagueReportsRow{
			{LeagueID: 2001, SleeperLeagueID: "main-sleeper", CanonicalLeagueID: "main-sleeper", Season: 2022, Name: "Main League", TeamCount: 12},
			{LeagueID: 2002, SleeperLeagueID: "side-sleeper", CanonicalLeagueID: "", Season: 2022, Name: "Other League", TeamCount: 10},
		}},
		nil,
		nil,
		"",
	)

	got, err := svc.ListCanonicalLeagueSummaries(context.Background())
	if err != nil {
		t.Fatalf("ListCanonicalLeagueSummaries returned error: %v", err)
	}

	if len(got.Leagues) != 1 {
		t.Fatalf("len(Leagues) = %d, want one canonical Sleeper league", len(got.Leagues))
	}
	if got.Leagues[0].Name != "Main League" {
		t.Fatalf("league = %#v, want main league", got.Leagues[0])
	}
}

func TestListSeasonResultsUsesCanonicalLeagueSummaries(t *testing.T) {
	svc := New(
		espnStub{leagues: []db.League{
			{ID: 11, LeagueId: 1001, Year: 2021, TeamCount: 10},
		}},
		espnMatchupStub{matchups: map[int32][]db.GetMatchupsByLeagueIdRow{
			11: {
				{
					Week:           15,
					HomeTeamID:     validID(1),
					AwayTeamID:     validID(2),
					HomeScore:      120,
					AwayScore:      100,
					IsPlayoff:      true,
					MatchupType:    "WINNERS_BRACKET",
					HomeTeamName:   "ESPN Champ",
					HomeTeamOwners: "Alice",
					AwayTeamName:   "ESPN Runner",
					AwayTeamOwners: "Bob",
				},
			},
		}},
		sleeperStub{reports: []sleeperdb.ListLeagueReportsRow{
			{LeagueID: 2001, SleeperLeagueID: "main-sleeper", CanonicalLeagueID: "main-sleeper", Season: 2022, Name: "Main League", TeamCount: 12, ChampionTeamName: "Sleeper Champ", RunnerUpTeamName: "Sleeper Runner"},
			{LeagueID: 2002, SleeperLeagueID: "side-sleeper", CanonicalLeagueID: "", Season: 2022, Name: "Other League", TeamCount: 10, ChampionTeamName: "Side Champ"},
		}},
		nil,
		map[string]string{"alice": "Alice"},
		"main-sleeper",
	)

	got, err := svc.ListSeasonResults(context.Background())
	if err != nil {
		t.Fatalf("ListSeasonResults returned error: %v", err)
	}

	if len(got.Seasons) != 2 {
		t.Fatalf("len(Seasons) = %d, want ESPN plus canonical Sleeper season", len(got.Seasons))
	}
	if got.Seasons[0].Season != 2021 || got.Seasons[0].Champion != "ESPN Champ" {
		t.Fatalf("season[0] = %#v, want ESPN 2021 result", got.Seasons[0])
	}
	if got.Seasons[1].Season != 2022 || got.Seasons[1].Champion != "Sleeper Champ" {
		t.Fatalf("season[1] = %#v, want Sleeper 2022 result", got.Seasons[1])
	}
}

type espnStub struct {
	leagues []db.League
	err     error
}

func (s espnStub) GetLeaguesAsc(context.Context, db.GetLeaguesAscParams) ([]db.League, error) {
	if s.err != nil {
		return nil, s.err
	}
	return s.leagues, nil
}

type espnMatchupStub struct {
	matchups map[int32][]db.GetMatchupsByLeagueIdRow
	err      error
}

func (s espnMatchupStub) GetMatchupsByLeagueId(_ context.Context, leagueID int32) ([]db.GetMatchupsByLeagueIdRow, error) {
	if s.err != nil {
		return nil, s.err
	}
	return s.matchups[leagueID], nil
}

type sleeperStub struct {
	reports []sleeperdb.ListLeagueReportsRow
	err     error
}

func (s sleeperStub) ListLeagueReports(context.Context) ([]sleeperdb.ListLeagueReportsRow, error) {
	if s.err != nil {
		return nil, s.err
	}
	return s.reports, nil
}

func (s sleeperStub) ListTeamsByLeague(context.Context, int64) ([]sleeperdb.Team, error) {
	return nil, nil
}

func validID(id int32) sql.NullInt32 {
	return sql.NullInt32{Int32: id, Valid: true}
}
