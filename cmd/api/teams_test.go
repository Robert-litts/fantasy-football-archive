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

func TestBuildTeamsPageDataDefaultsToFirstArchiveLeague(t *testing.T) {
	page, err := buildTeamsPageData(
		context.Background(),
		teamsArchiveStub{
			leagueList: archive.LeagueList{
				Leagues: []archive.LeagueSummary{
					{Provider: archive.ProviderESPN, ID: 11, Season: 2021, Name: "ESPN 1001"},
					{Provider: archive.ProviderSleeper, ID: 2001, Season: 2022, Name: "Dynasty Ship"},
				},
			},
		},
		teamsESPNStub{
			rows: map[int32][]db.GetTeamsByLeagueYearRow{
				11: {
					{
						Owners:        "Alice",
						TeamAbbrv:     "AS",
						TeamName:      "Alpha Squad",
						Wins:          10,
						Losses:        3,
						Ties:          0,
						PointsFor:     1450,
						PointsAgainst: 1200,
						FinalStanding: 1,
					},
				},
			},
		},
		teamsSleeperStub{},
		"",
	)
	if err != nil {
		t.Fatalf("buildTeamsPageData returned error: %v", err)
	}

	if page.SelectedLeague.Provider != archive.ProviderESPN {
		t.Fatalf("selected league provider = %s, want espn", page.SelectedLeague.Provider)
	}
	if page.SelectedLeague.ID != 11 {
		t.Fatalf("selected league id = %d, want 11", page.SelectedLeague.ID)
	}
	if len(page.Teams) != 1 {
		t.Fatalf("len(Teams) = %d, want 1", len(page.Teams))
	}
	if got := page.Teams[0]; got.OwnerLabel != "Alice" || got.TeamLabel != "Alpha Squad (AS)" {
		t.Fatalf("normalized ESPN team = %#v, want owner Alice and label Alpha Squad (AS)", got)
	}
}

func TestBuildTeamsPageDataSelectsSleeperLeague(t *testing.T) {
	page, err := buildTeamsPageData(
		context.Background(),
		teamsArchiveStub{
			leagueList: archive.LeagueList{
				Leagues: []archive.LeagueSummary{
					{Provider: archive.ProviderESPN, ID: 11, Season: 2021, Name: "ESPN 1001"},
					{Provider: archive.ProviderSleeper, ID: 2001, Season: 2022, Name: "Dynasty Ship"},
				},
				SleeperAvailable: true,
			},
		},
		teamsESPNStub{},
		teamsSleeperStub{
			rows: map[int64][]sleeperdb.Team{
				2001: {
					{
						RosterID:      3,
						DisplayName:   sqlNullString("Taylor"),
						Username:      sqlNullString("tay"),
						OwnerID:       "owner-3",
						TeamName:      "Stack Attack",
						Wins:          11,
						Losses:        2,
						Ties:          0,
						PointsFor:     "1523.5",
						PointsAgainst: "1301.2",
						FinalStanding: 1,
					},
				},
			},
		},
		"sleeper:2001",
	)
	if err != nil {
		t.Fatalf("buildTeamsPageData returned error: %v", err)
	}

	if page.SelectedLeague.Provider != archive.ProviderSleeper {
		t.Fatalf("selected league provider = %s, want sleeper", page.SelectedLeague.Provider)
	}
	if len(page.Teams) != 1 {
		t.Fatalf("len(Teams) = %d, want 1", len(page.Teams))
	}
	if got := page.Teams[0]; got.OwnerLabel != "Taylor" || got.TeamLabel != "Stack Attack" || got.PointsFor != "1523.5" {
		t.Fatalf("normalized Sleeper team = %#v, want display name Taylor and stack attack label", got)
	}
}

func TestBuildTeamsPageDataHandlesSleeperUnavailableGracefully(t *testing.T) {
	page, err := buildTeamsPageData(
		context.Background(),
		teamsArchiveStub{
			leagueList: archive.LeagueList{
				Leagues: []archive.LeagueSummary{
					{Provider: archive.ProviderSleeper, ID: 2001, Season: 2022, Name: "Dynasty Ship"},
				},
				SleeperAvailable: true,
			},
		},
		teamsESPNStub{},
		teamsSleeperStub{err: errors.New("sleeper down")},
		"sleeper:2001",
	)
	if err != nil {
		t.Fatalf("buildTeamsPageData returned error: %v", err)
	}

	if page.SleeperMessage != "Sleeper team data is temporarily unavailable" {
		t.Fatalf("SleeperMessage = %q, want temporary-unavailable notice", page.SleeperMessage)
	}
	if len(page.Teams) != 0 {
		t.Fatalf("len(Teams) = %d, want 0", len(page.Teams))
	}
}

func TestNormalizeESPNTeamRow(t *testing.T) {
	got := normalizeESPNTeamRow(db.GetTeamsByLeagueYearRow{
		Owners:        "Casey",
		TeamAbbrv:     "CB",
		TeamName:      "Chaos Ballers",
		Wins:          9,
		Losses:        4,
		Ties:          0,
		PointsFor:     1388,
		PointsAgainst: 1290,
		FinalStanding: 2,
	})

	if got.OwnerLabel != "Casey" {
		t.Fatalf("OwnerLabel = %q, want Casey", got.OwnerLabel)
	}
	if got.TeamLabel != "Chaos Ballers (CB)" {
		t.Fatalf("TeamLabel = %q, want Chaos Ballers (CB)", got.TeamLabel)
	}
	if got.PointsFor != "1388" || got.PointsAgainst != "1290" {
		t.Fatalf("points = %#v, want stringified values", got)
	}
}

func TestNormalizeSleeperTeamRow(t *testing.T) {
	got := normalizeSleeperTeamRow(sleeperdb.Team{
		RosterID:      7,
		DisplayName:   sqlNullString("Jordan"),
		Username:      sqlNullString("jordan"),
		OwnerID:       "owner-7",
		TeamName:      "Sunday Funday",
		Wins:          12,
		Losses:        1,
		Ties:          0,
		PointsFor:     "1600.75",
		PointsAgainst: "1201.25",
		FinalStanding: 1,
	})

	if got.OwnerLabel != "Jordan" {
		t.Fatalf("OwnerLabel = %q, want Jordan", got.OwnerLabel)
	}
	if got.TeamLabel != "Sunday Funday" {
		t.Fatalf("TeamLabel = %q, want Sunday Funday", got.TeamLabel)
	}
	if got.PointsFor != "1600.75" || got.PointsAgainst != "1201.25" {
		t.Fatalf("points = %#v, want original string values", got)
	}
}

func TestBuildTeamsPageDataUsesProviderAwareSelectionKey(t *testing.T) {
	page, err := buildTeamsPageData(
		context.Background(),
		teamsArchiveStub{
			leagueList: archive.LeagueList{
				Leagues: []archive.LeagueSummary{
					{Provider: archive.ProviderESPN, ID: 8, Season: 2018, Name: "ESPN 2018"},
					{Provider: archive.ProviderSleeper, ID: 8, Season: 2025, Name: "Sleeper 2025"},
				},
				SleeperAvailable: true,
			},
		},
		teamsESPNStub{
			rows: map[int32][]db.GetTeamsByLeagueYearRow{
				8: {
					{Owners: "ESPN Owner 1", TeamName: "ESPN Team 1", Wins: 8, FinalStanding: 1},
					{Owners: "ESPN Owner 2", TeamName: "ESPN Team 2", Wins: 7, FinalStanding: 2},
				},
			},
		},
		teamsSleeperStub{
			rows: map[int64][]sleeperdb.Team{
				8: {
					{DisplayName: sqlNullString("Sleeper 1"), TeamName: "Sleeper Team 1", Wins: 10, FinalStanding: 1},
					{DisplayName: sqlNullString("Sleeper 2"), TeamName: "Sleeper Team 2", Wins: 9, FinalStanding: 2},
					{DisplayName: sqlNullString("Sleeper 3"), TeamName: "Sleeper Team 3", Wins: 8, FinalStanding: 3},
				},
			},
		},
		"sleeper:8",
	)
	if err != nil {
		t.Fatalf("buildTeamsPageData returned error: %v", err)
	}

	if page.SelectedLeague.Provider != archive.ProviderSleeper || page.SelectedLeague.Season != 2025 {
		t.Fatalf("selected league = %#v, want Sleeper 2025", page.SelectedLeague)
	}
	if page.SelectedLeagueKey != "sleeper:8" {
		t.Fatalf("SelectedLeagueKey = %q, want sleeper:8", page.SelectedLeagueKey)
	}
	if len(page.Teams) != 3 {
		t.Fatalf("len(Teams) = %d, want 3 sleeper rows", len(page.Teams))
	}
	if page.Teams[0].OwnerLabel != "Sleeper 1" {
		t.Fatalf("first team = %#v, want sleeper team rows not ESPN rows", page.Teams[0])
	}
}

type teamsArchiveStub struct {
	leagueList archive.LeagueList
	err        error
}

func (s teamsArchiveStub) ListCanonicalLeagueSummaries(context.Context) (archive.LeagueList, error) {
	return s.leagueList, s.err
}

type teamsESPNStub struct {
	rows map[int32][]db.GetTeamsByLeagueYearRow
	err  error
}

func (s teamsESPNStub) GetTeamsByLeagueYear(_ context.Context, id int32) ([]db.GetTeamsByLeagueYearRow, error) {
	if s.err != nil {
		return nil, s.err
	}
	if rows, ok := s.rows[id]; ok {
		return rows, nil
	}
	return nil, sql.ErrNoRows
}

type teamsSleeperStub struct {
	rows map[int64][]sleeperdb.Team
	err  error
}

func (s teamsSleeperStub) ListTeamsByLeague(_ context.Context, id int64) ([]sleeperdb.Team, error) {
	if s.err != nil {
		return nil, s.err
	}
	if rows, ok := s.rows[id]; ok {
		return rows, nil
	}
	return nil, sql.ErrNoRows
}

func sqlNullString(v string) sql.NullString {
	return sql.NullString{String: v, Valid: true}
}
