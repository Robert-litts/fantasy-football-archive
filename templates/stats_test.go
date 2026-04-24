package templates

import (
	"bytes"
	"context"
	"strings"
	"testing"

	appstats "github.com/Robert-litts/fantasy-football-archive/internal/stats"
)

func TestStatsTemplateRendersTabbedSectionsAndFixtureData(t *testing.T) {
	pageData := appstats.PageData{
		SeasonCount:  2,
		OwnerCount:   4,
		MatchupCount: 18,
		HighlightCards: []appstats.HighlightCard{
			{Label: "Highest weekly score", Value: 160, ValueText: "points", Owner: "Alice", TeamName: "Alice Alpha", Opponent: "Dave Delta", Year: 2023, Week: 3, Detail: "Regular season"},
		},
		OwnerTotals: []appstats.OwnerTotal{
			{Rank: 1, Owner: "Alice", Seasons: 2, Wins: 20, Losses: 8, Ties: 0, Titles: 1, PlayoffAppearances: 2, PointsFor: 3200, PointsAgainst: 2900, WinPct: 0.714},
		},
		RegularSeasonOwnerTotals: []appstats.OwnerTotal{
			{Rank: 1, Owner: "Alice", Seasons: 2, Wins: 20, Losses: 8, Ties: 0, PointsFor: 3200, PointsAgainst: 2900, WinPct: 0.714},
		},
		BestRegularSeasons: []appstats.SeasonRecord{
			{Rank: 1, Owner: "Alice", Year: 2023, Wins: 10, Losses: 4, Ties: 0, FinalStanding: 1, PointsFor: 1600, PointsAgainst: 1450, WinPct: 0.714},
		},
		PlayoffHighlightCards: []appstats.HighlightCard{
			{Label: "Highest playoff score", Value: 130, ValueText: "points", Owner: "Alice", TeamName: "Alice Alpha", Opponent: "Bob Brigade", Year: 2023, Week: 15, Detail: "Playoffs win"},
		},
		PlayoffOwnerTotals: []appstats.PlayoffOwnerTotal{
			{Rank: 1, Owner: "Alice", Appearances: 2, Wins: 3, Losses: 1, Titles: 1, WinPct: 0.75},
		},
		Champions: []appstats.ChampionRecord{
			{Year: 2023, Owner: "Alice", TeamName: "Alice Alpha", Opponent: "Bob Brigade", WinningScore: 130, LosingScore: 125},
		},
	}

	var output bytes.Buffer
	if err := Stats(pageData).Render(context.Background(), &output); err != nil {
		t.Fatalf("render Stats: %v", err)
	}

	html := output.String()
	assertContains(t, html, "Overview")
	assertContains(t, html, "Regular Season")
	assertContains(t, html, "Playoffs")
	assertContains(t, html, "League superlatives")
	assertContains(t, html, "Playoff archive")
	assertContains(t, html, "Playoff owner totals")
	assertContains(t, html, "Alice")
	assertContains(t, html, "2023")
	assertContains(t, html, "160")
	assertContains(t, html, "130")
}

func assertContains(t *testing.T, body string, want string) {
	t.Helper()
	if !strings.Contains(body, want) {
		t.Fatalf("rendered output missing %q", want)
	}
}
