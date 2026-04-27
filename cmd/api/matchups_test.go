package main

import (
	"context"
	"database/sql"
	"errors"
	"testing"

	"github.com/Robert-litts/fantasy-football-archive/internal/archive"
	"github.com/Robert-litts/fantasy-football-archive/internal/db"
	"github.com/Robert-litts/fantasy-football-archive/internal/sleeperdb"
)

func TestBuildMatchupsPageDataUsesProviderAwareSelectionKey(t *testing.T) {
	page, err := buildMatchupsPageData(
		context.Background(),
		matchupsArchiveStub{
			leagueList: archive.LeagueList{
				Leagues: []archive.LeagueSummary{
					{Provider: archive.ProviderESPN, ID: 8, Season: 2018, Name: "ESPN 2018"},
					{Provider: archive.ProviderSleeper, ID: 8, Season: 2025, Name: "Sleeper 2025"},
				},
				SleeperAvailable: true,
			},
		},
		matchupsESPNStub{
			rows: map[int32][]db.GetMatchupsByLeagueIdRow{
				8: {
					{Week: 1, HomeTeamID: sqlNullInt32(1), AwayTeamID: sqlNullInt32(2), HomeTeamName: "ESPN A", AwayTeamName: "ESPN B", LeagueId: 8},
				},
			},
		},
		matchupsSleeperStub{
			rows: map[int64][]sleeperdb.Matchup{
				8: {
					{Week: 1, MatchupID: 1, RosterID: 1, OpponentRosterID: sqlNullInt32(2), Points: "101.5", MatchupType: "REGULAR_SEASON"},
					{Week: 1, MatchupID: 1, RosterID: 2, OpponentRosterID: sqlNullInt32(1), Points: "99.4", MatchupType: "REGULAR_SEASON"},
					{Week: 1, MatchupID: 2, RosterID: 3, OpponentRosterID: sqlNullInt32(4), Points: "120.1", MatchupType: "REGULAR_SEASON"},
					{Week: 1, MatchupID: 2, RosterID: 4, OpponentRosterID: sqlNullInt32(3), Points: "88.2", MatchupType: "REGULAR_SEASON"},
				},
			},
		},
		matchupsSleeperTeamsStub{
			rows: map[int64][]sleeperdb.Team{
				8: {
					{RosterID: 1, TeamName: "Sleeper A", DisplayName: sqlNullString("Alice")},
					{RosterID: 2, TeamName: "Sleeper B", DisplayName: sqlNullString("Bob")},
					{RosterID: 3, TeamName: "Sleeper C", DisplayName: sqlNullString("Casey")},
					{RosterID: 4, TeamName: "Sleeper D", DisplayName: sqlNullString("Drew")},
				},
			},
		},
		matchupsSleeperBracketsStub{},
		"sleeper:8",
		0,
	)
	if err != nil {
		t.Fatalf("buildMatchupsPageData returned error: %v", err)
	}

	if page.SelectedLeague.Provider != archive.ProviderSleeper || page.SelectedLeague.Season != 2025 {
		t.Fatalf("selected league = %#v, want Sleeper 2025", page.SelectedLeague)
	}
	if page.SelectedLeagueKey != "sleeper:8" {
		t.Fatalf("SelectedLeagueKey = %q, want sleeper:8", page.SelectedLeagueKey)
	}
	if len(page.SelectedWeekRows) != 2 {
		t.Fatalf("len(SelectedWeekRows) = %d, want 2 sleeper matchups", len(page.SelectedWeekRows))
	}
	if page.SelectedWeekRows[0].HomeTeamName != "Sleeper A" {
		t.Fatalf("first matchup = %#v, want sleeper rows not ESPN rows", page.SelectedWeekRows[0])
	}
}

func TestBuildMatchupsPageDataDefaultsToFirstAvailableWeek(t *testing.T) {
	page, err := buildMatchupsPageData(
		context.Background(),
		matchupsArchiveStub{
			leagueList: archive.LeagueList{
				Leagues: []archive.LeagueSummary{{Provider: archive.ProviderESPN, ID: 11, Season: 2021, Name: "ESPN 2021"}},
			},
		},
		matchupsESPNStub{
			rows: map[int32][]db.GetMatchupsByLeagueIdRow{
				11: {
					{Week: 3, HomeTeamID: sqlNullInt32(1), AwayTeamID: sqlNullInt32(2), HomeTeamName: "Week 3 A", AwayTeamName: "Week 3 B", LeagueId: 11},
					{Week: 2, HomeTeamID: sqlNullInt32(1), AwayTeamID: sqlNullInt32(2), HomeTeamName: "Week 2 A", AwayTeamName: "Week 2 B", LeagueId: 11},
				},
			},
		},
		matchupsSleeperStub{},
		matchupsSleeperTeamsStub{},
		matchupsSleeperBracketsStub{},
		"",
		0,
	)
	if err != nil {
		t.Fatalf("buildMatchupsPageData returned error: %v", err)
	}

	if page.ActiveWeek != 2 {
		t.Fatalf("ActiveWeek = %d, want first available week 2", page.ActiveWeek)
	}
	if len(page.SelectedWeekRows) != 1 || page.SelectedWeekRows[0].HomeTeamName != "Week 2 A" {
		t.Fatalf("SelectedWeekRows = %#v, want week 2 row", page.SelectedWeekRows)
	}
}

func TestBuildMatchupsPageDataHandlesSleeperUnavailableGracefully(t *testing.T) {
	page, err := buildMatchupsPageData(
		context.Background(),
		matchupsArchiveStub{
			leagueList: archive.LeagueList{
				Leagues:          []archive.LeagueSummary{{Provider: archive.ProviderSleeper, ID: 2001, Season: 2022, Name: "Dynasty Ship"}},
				SleeperAvailable: true,
			},
		},
		matchupsESPNStub{},
		matchupsSleeperStub{err: errors.New("sleeper down")},
		matchupsSleeperTeamsStub{},
		matchupsSleeperBracketsStub{},
		"sleeper:2001",
		0,
	)
	if err != nil {
		t.Fatalf("buildMatchupsPageData returned error: %v", err)
	}

	if page.SleeperMessage != "Sleeper matchup data is temporarily unavailable" {
		t.Fatalf("SleeperMessage = %q, want temporary-unavailable notice", page.SleeperMessage)
	}
	if len(page.Matchups) != 0 {
		t.Fatalf("len(Matchups) = %d, want 0", len(page.Matchups))
	}
}

func TestNormalizeSleeperMatchupsPairsRosterRows(t *testing.T) {
	got := normalizeSleeperMatchups(
		[]sleeperdb.Matchup{
			{Week: 14, MatchupID: 1, RosterID: 8, OpponentRosterID: sqlNullInt32(2), Points: "140.2", IsPlayoff: true, MatchupType: "WINNERS_BRACKET"},
			{Week: 14, MatchupID: 1, RosterID: 2, OpponentRosterID: sqlNullInt32(8), Points: "131.7", IsPlayoff: true, MatchupType: "WINNERS_BRACKET"},
		},
		[]sleeperdb.Team{
			{RosterID: 2, TeamName: "Lower Seed", DisplayName: sqlNullString("Taylor")},
			{RosterID: 8, TeamName: "Higher Seed", DisplayName: sqlNullString("Morgan")},
		},
		[]sleeperdb.PlayoffBracketMatchup{
			{
				BracketType:    "winners",
				Placement:      sqlNullInt32(1),
				WinnerRosterID: sqlNullInt32(8),
				LoserRosterID:  sqlNullInt32(2),
			},
		},
	)

	if len(got) != 1 {
		t.Fatalf("len(got) = %d, want 1 paired matchup", len(got))
	}
	if got[0].HomeTeamName != "Lower Seed" || got[0].AwayTeamName != "Higher Seed" {
		t.Fatalf("paired matchup = %#v, want lower roster as home and higher roster as away", got[0])
	}
	if got[0].AwayWinner != true || got[0].TypeLabel != "Championship" {
		t.Fatalf("paired matchup = %#v, want away winner championship row", got[0])
	}
}

func TestNormalizeSleeperMatchupsDropsInactiveAllByeWeek(t *testing.T) {
	got := normalizeSleeperMatchups(
		[]sleeperdb.Matchup{
			{Week: 17, MatchupID: 1, RosterID: 1, OpponentRosterID: sqlNullInt32(2), Points: "111.1", IsPlayoff: true, MatchupType: "WINNERS_BRACKET"},
			{Week: 17, MatchupID: 1, RosterID: 2, OpponentRosterID: sqlNullInt32(1), Points: "101.1", IsPlayoff: true, MatchupType: "WINNERS_BRACKET"},
			{Week: 18, MatchupID: 0, RosterID: 1, Points: "0", IsPlayoff: true, MatchupType: "WINNERS_BRACKET"},
			{Week: 18, MatchupID: 0, RosterID: 2, Points: "0", IsPlayoff: true, MatchupType: "WINNERS_BRACKET"},
		},
		nil,
		nil,
	)

	if len(got) != 1 {
		t.Fatalf("len(got) = %d, want only the played week", len(got))
	}
	if got[0].Week != 17 {
		t.Fatalf("Week = %d, want week 17", got[0].Week)
	}
	if got[0].TypeLabel != "Championship" {
		t.Fatalf("TypeLabel = %q, want Championship after dropping inactive week 18", got[0].TypeLabel)
	}
}

func TestNormalizeSleeperMatchupsUsesBracketForChampionshipMatchOnly(t *testing.T) {
	got := normalizeSleeperMatchups(
		[]sleeperdb.Matchup{
			{Week: 5, MatchupID: 1, RosterID: 1, OpponentRosterID: sqlNullInt32(2), Points: "101", IsPlayoff: false, MatchupType: "REGULAR_SEASON"},
			{Week: 5, MatchupID: 1, RosterID: 2, OpponentRosterID: sqlNullInt32(1), Points: "100", IsPlayoff: false, MatchupType: "REGULAR_SEASON"},
			{Week: 17, MatchupID: 1, RosterID: 1, OpponentRosterID: sqlNullInt32(2), Points: "121", IsPlayoff: true, MatchupType: "WINNERS_BRACKET"},
			{Week: 17, MatchupID: 1, RosterID: 2, OpponentRosterID: sqlNullInt32(1), Points: "120", IsPlayoff: true, MatchupType: "WINNERS_BRACKET"},
			{Week: 17, MatchupID: 2, RosterID: 3, OpponentRosterID: sqlNullInt32(4), Points: "110", IsPlayoff: true, MatchupType: "WINNERS_BRACKET"},
			{Week: 17, MatchupID: 2, RosterID: 4, OpponentRosterID: sqlNullInt32(3), Points: "109", IsPlayoff: true, MatchupType: "WINNERS_BRACKET"},
		},
		[]sleeperdb.Team{
			{RosterID: 1, TeamName: "Finalist A"},
			{RosterID: 2, TeamName: "Finalist B"},
			{RosterID: 3, TeamName: "Third Place A"},
			{RosterID: 4, TeamName: "Third Place B"},
		},
		[]sleeperdb.PlayoffBracketMatchup{
			{
				BracketType:    "winners",
				Placement:      sqlNullInt32(1),
				WinnerRosterID: sqlNullInt32(1),
				LoserRosterID:  sqlNullInt32(2),
			},
		},
	)

	if len(got) != 3 {
		t.Fatalf("len(got) = %d, want 3 matchups including regular-season rematch", len(got))
	}

	championshipCount := 0
	placementCount := 0
	for _, matchup := range got {
		if matchup.Week == 5 && matchup.TypeLabel == "Championship" {
			t.Fatalf("regular-season rematch = %#v, should not be labeled Championship", matchup)
		}
		if matchup.TypeLabel == "Championship" {
			championshipCount++
			if matchup.HomeTeamName != "Finalist A" {
				t.Fatalf("championship matchup = %#v, want Finalist A vs Finalist B", matchup)
			}
		}
		if matchup.Week == 17 && matchup.TypeLabel == "Placement Game" {
			placementCount++
		}
	}
	if championshipCount != 1 {
		t.Fatalf("championshipCount = %d, want exactly 1", championshipCount)
	}
	if placementCount != 1 {
		t.Fatalf("placementCount = %d, want exactly 1 final-week non-title placement game", placementCount)
	}
}

type matchupsArchiveStub struct {
	leagueList archive.LeagueList
	err        error
}

func (s matchupsArchiveStub) ListLeagueSummaries(context.Context) (archive.LeagueList, error) {
	return s.leagueList, s.err
}

type matchupsESPNStub struct {
	rows map[int32][]db.GetMatchupsByLeagueIdRow
	err  error
}

func (s matchupsESPNStub) GetMatchupsByLeagueId(_ context.Context, id int32) ([]db.GetMatchupsByLeagueIdRow, error) {
	if s.err != nil {
		return nil, s.err
	}
	if rows, ok := s.rows[id]; ok {
		return rows, nil
	}
	return nil, sql.ErrNoRows
}

type matchupsSleeperStub struct {
	rows map[int64][]sleeperdb.Matchup
	err  error
}

func (s matchupsSleeperStub) ListMatchupsByLeague(_ context.Context, id int64) ([]sleeperdb.Matchup, error) {
	if s.err != nil {
		return nil, s.err
	}
	if rows, ok := s.rows[id]; ok {
		return rows, nil
	}
	return nil, sql.ErrNoRows
}

type matchupsSleeperTeamsStub struct {
	rows map[int64][]sleeperdb.Team
	err  error
}

func (s matchupsSleeperTeamsStub) ListTeamsByLeague(_ context.Context, id int64) ([]sleeperdb.Team, error) {
	if s.err != nil {
		return nil, s.err
	}
	if rows, ok := s.rows[id]; ok {
		return rows, nil
	}
	return nil, sql.ErrNoRows
}

type matchupsSleeperBracketsStub struct {
	rows map[int64][]sleeperdb.PlayoffBracketMatchup
	err  error
}

func (s matchupsSleeperBracketsStub) ListPlayoffBracketMatchupsByLeague(_ context.Context, id int64) ([]sleeperdb.PlayoffBracketMatchup, error) {
	if s.err != nil {
		return nil, s.err
	}
	if rows, ok := s.rows[id]; ok {
		return rows, nil
	}
	return nil, sql.ErrNoRows
}

func sqlNullInt32(v int32) sql.NullInt32 {
	return sql.NullInt32{Int32: v, Valid: true}
}
