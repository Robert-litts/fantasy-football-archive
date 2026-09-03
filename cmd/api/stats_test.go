package main

import (
	"context"
	"database/sql"
	"testing"

	"github.com/Robert-litts/fantasy-football-archive/internal/archive"
	"github.com/Robert-litts/fantasy-football-archive/internal/db"
	"github.com/Robert-litts/fantasy-football-archive/internal/sleeperdb"
	appstats "github.com/Robert-litts/fantasy-football-archive/internal/stats"
)

func TestBuildStatsPageDataAggregatesArchiveBackedESPNAndSleeper(t *testing.T) {
	sleeper := statsSleeperStub{
		teams: map[int64][]sleeperdb.Team{
			2001: {
				{LeagueID: 2001, RosterID: 1, OwnerID: "sleeper-alice", DisplayName: sqlNullString("A Sleeper Changed"), TeamName: "Aces", Wins: 9, Losses: 5, PointsFor: "1550.8", PointsAgainst: "1499.4", FinalStanding: 2},
				{LeagueID: 2001, RosterID: 2, OwnerID: "sleeper-carol", DisplayName: sqlNullString("Carol"), TeamName: "Comets", Wins: 11, Losses: 3, PointsFor: "1700.2", PointsAgainst: "1425.7", FinalStanding: 1},
			},
		},
		matchups: map[int64][]sleeperdb.Matchup{
			2001: {
				{LeagueID: 2001, Week: 15, MatchupID: 1, RosterID: 1, OpponentRosterID: sqlNullInt32(2), Points: "128.1", IsPlayoff: true, MatchupType: "WINNERS_BRACKET"},
				{LeagueID: 2001, Week: 15, MatchupID: 1, RosterID: 2, OpponentRosterID: sqlNullInt32(1), Points: "130.2", IsPlayoff: true, MatchupType: "WINNERS_BRACKET"},
			},
		},
		brackets: map[int64][]sleeperdb.PlayoffBracketMatchup{
			2001: {
				{LeagueID: 2001, BracketType: "winners", Placement: sqlNullInt32(1), WinnerRosterID: sqlNullInt32(2), LoserRosterID: sqlNullInt32(1)},
			},
		},
	}

	page, err := buildStatsPageData(
		context.Background(),
		statsArchiveStub{
			leagueList: archive.LeagueList{
				Leagues: []archive.LeagueSummary{
					{Provider: archive.ProviderESPN, ID: 1, Season: 2022, Name: "ESPN 2022"},
					{Provider: archive.ProviderSleeper, ID: 2001, Season: 2023, Name: "Sleeper 2023"},
				},
				SleeperAvailable: true,
			},
		},
		statsESPNStub{
			teams: map[int32][]db.GetTeamsByLeagueYearRow{
				1: {
					{Owners: "Alice ESPN", Wins: 10, Losses: 4, PointsFor: 1600, PointsAgainst: 1450, FinalStanding: 1},
					{Owners: "Bob", Wins: 8, Losses: 6, PointsFor: 1500, PointsAgainst: 1480, FinalStanding: 2},
				},
			},
			matchups: map[int32][]db.GetMatchupsByLeagueIdRow{
				1: {
					{
						Week: 14, HomeTeamID: sqlNullInt32(1), AwayTeamID: sqlNullInt32(2),
						HomeScore: 122, AwayScore: 110, IsPlayoff: true, MatchupType: "WINNERS_BRACKET",
						HomeFinalStanding: 1, AwayFinalStanding: 2,
						HomeTeamName: "Aces", HomeTeamOwners: "Alice ESPN", AwayTeamName: "Bolts", AwayTeamOwners: "Bob",
					},
				},
			},
		},
		sleeper,
		sleeper,
		sleeper,
		map[string]string{
			"Alice ESPN":    "Alice",
			"sleeper-alice": "Alice",
			"sleeper-carol": "Carol",
		},
	)
	if err != nil {
		t.Fatalf("buildStatsPageData returned error: %v", err)
	}

	if page.SeasonCount != 2 {
		t.Fatalf("SeasonCount = %d, want 2", page.SeasonCount)
	}
	alice := requireStatsOwnerTotal(t, page.OwnerTotals, "Alice")
	if alice.Seasons != 2 || alice.Wins != 19 || alice.PlayoffAppearances != 2 || alice.Titles != 1 {
		t.Fatalf("Alice owner total = %#v, want merged ESPN/Sleeper alias totals", alice)
	}
	carol := requireStatsPlayoffOwnerTotal(t, page.PlayoffOwnerTotals, "Carol")
	if carol.Appearances != 1 || carol.FinalsAppearances != 1 || carol.Titles != 1 || carol.Wins != 1 {
		t.Fatalf("Carol playoff total = %#v, want Sleeper championship totals", carol)
	}
	if len(page.Champions) != 2 {
		t.Fatalf("len(Champions) = %d, want 2", len(page.Champions))
	}
	if page.Champions[0].Year != 2023 || page.Champions[0].Owner != "Carol" {
		t.Fatalf("newest champion = %#v, want Carol 2023", page.Champions[0])
	}
}

type statsArchiveStub struct {
	leagueList archive.LeagueList
	err        error
}

func (s statsArchiveStub) ListCanonicalLeagueSummaries(context.Context) (archive.LeagueList, error) {
	return s.leagueList, s.err
}

type statsESPNStub struct {
	teams    map[int32][]db.GetTeamsByLeagueYearRow
	matchups map[int32][]db.GetMatchupsByLeagueIdRow
	err      error
}

func (s statsESPNStub) GetTeamsByLeagueYear(_ context.Context, id int32) ([]db.GetTeamsByLeagueYearRow, error) {
	if s.err != nil {
		return nil, s.err
	}
	if rows, ok := s.teams[id]; ok {
		return rows, nil
	}
	return nil, sql.ErrNoRows
}

func (s statsESPNStub) GetMatchupsByLeagueId(_ context.Context, id int32) ([]db.GetMatchupsByLeagueIdRow, error) {
	if s.err != nil {
		return nil, s.err
	}
	if rows, ok := s.matchups[id]; ok {
		return rows, nil
	}
	return nil, sql.ErrNoRows
}

type statsSleeperStub struct {
	teams    map[int64][]sleeperdb.Team
	matchups map[int64][]sleeperdb.Matchup
	brackets map[int64][]sleeperdb.PlayoffBracketMatchup
	err      error
}

func (s statsSleeperStub) ListTeamsByLeague(_ context.Context, id int64) ([]sleeperdb.Team, error) {
	if s.err != nil {
		return nil, s.err
	}
	if rows, ok := s.teams[id]; ok {
		return rows, nil
	}
	return nil, sql.ErrNoRows
}

func (s statsSleeperStub) ListMatchupsByLeague(_ context.Context, id int64) ([]sleeperdb.Matchup, error) {
	if s.err != nil {
		return nil, s.err
	}
	if rows, ok := s.matchups[id]; ok {
		return rows, nil
	}
	return nil, sql.ErrNoRows
}

func (s statsSleeperStub) ListPlayoffBracketMatchupsByLeague(_ context.Context, id int64) ([]sleeperdb.PlayoffBracketMatchup, error) {
	if s.err != nil {
		return nil, s.err
	}
	if rows, ok := s.brackets[id]; ok {
		return rows, nil
	}
	return nil, sql.ErrNoRows
}

func requireStatsOwnerTotal(t *testing.T, totals []appstats.OwnerTotal, owner string) appstats.OwnerTotal {
	t.Helper()
	for _, total := range totals {
		if total.Owner == owner {
			return total
		}
	}
	t.Fatalf("missing owner total %q in %#v", owner, totals)
	return appstats.OwnerTotal{}
}

func requireStatsPlayoffOwnerTotal(t *testing.T, totals []appstats.PlayoffOwnerTotal, owner string) appstats.PlayoffOwnerTotal {
	t.Helper()
	for _, total := range totals {
		if total.Owner == owner {
			return total
		}
	}
	t.Fatalf("missing playoff owner total %q in %#v", owner, totals)
	return appstats.PlayoffOwnerTotal{}
}

func TestBuildStatsPageDataIncludesSleeperWithOrphanByeRows(t *testing.T) {
	orphan := statsSleeperStub{
		teams: map[int64][]sleeperdb.Team{
			2001: {
				{LeagueID: 2001, RosterID: 1, OwnerID: "sleeper-alice", DisplayName: sqlNullString("Alice"), TeamName: "Aces", Wins: 10, Losses: 4, PointsFor: "1550.8", PointsAgainst: "1499.4", FinalStanding: 2},
				{LeagueID: 2001, RosterID: 2, OwnerID: "sleeper-carol", DisplayName: sqlNullString("Carol"), TeamName: "Comets", Wins: 11, Losses: 3, PointsFor: "1700.2", PointsAgainst: "1425.7", FinalStanding: 1},
			},
		},
		matchups: map[int64][]sleeperdb.Matchup{
			2001: {
				{LeagueID: 2001, Week: 15, MatchupID: 1, RosterID: 1, OpponentRosterID: sqlNullInt32(2), Points: "128.1", IsPlayoff: true, MatchupType: "WINNERS_BRACKET"},
				{LeagueID: 2001, Week: 15, MatchupID: 1, RosterID: 2, OpponentRosterID: sqlNullInt32(1), Points: "130.2", IsPlayoff: true, MatchupType: "WINNERS_BRACKET"},
				{LeagueID: 2001, Week: 15, MatchupID: -10, RosterID: 3, Points: "97.32", IsPlayoff: true, MatchupType: "WINNERS_BRACKET"},
			},
		},
	}

	page, err := buildStatsPageData(
		context.Background(),
		statsArchiveStub{
			leagueList: archive.LeagueList{
				Leagues: []archive.LeagueSummary{
					{Provider: archive.ProviderSleeper, ID: 2001, Season: 2023, Name: "Sleeper 2023"},
				},
				SleeperAvailable: true,
			},
		},
		statsESPNStub{},
		orphan,
		orphan,
		orphan,
		map[string]string{
			"sleeper-alice": "Alice",
			"sleeper-carol": "Carol",
		},
	)
	if err != nil {
		t.Fatalf("buildStatsPageData returned error: %v", err)
	}
	if page.SeasonCount != 1 {
		t.Fatalf("SeasonCount = %d, want 1", page.SeasonCount)
	}
	carol := requireStatsPlayoffOwnerTotal(t, page.PlayoffOwnerTotals, "Carol")
	if carol.Titles != 1 {
		t.Fatalf("Carol playoff titles = %d, want 1", carol.Titles)
	}
}

func TestParseOptionalStatsPointsErrorsOnlyForPresentBlanks(t *testing.T) {
	if _, err := parseOptionalStatsPoints("", true); err == nil {
		t.Fatal("parseOptionalStatsPoints(\"\", true) returned nil error")
	}
	if got, err := parseOptionalStatsPoints("", false); err != nil || got != 0 {
		t.Fatalf("parseOptionalStatsPoints(\"\", false) = (%d, %v), want (0, nil)", got, err)
	}
	if got, err := parseOptionalStatsPoints("97.32", true); err != nil || got != 9732 {
		t.Fatalf("parseOptionalStatsPoints(\"97.32\", true) = (%d, %v), want (9732, nil)", got, err)
	}
}
