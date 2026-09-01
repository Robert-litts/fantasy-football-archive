package stats

import (
	"database/sql"
	"math"
	"reflect"
	"testing"

	"github.com/Robert-litts/fantasy-football-archive/internal/db"
)

func TestBuildPageDataAggregatesOverviewAndPlayoffs(t *testing.T) {
	league := db.GetAllLeaguesRow{ID: 1, LeagueId: 2023, Year: 2023}
	teams := []db.GetTeamsByLeagueYearRow{
		{Owners: "Alice", Wins: 10, Losses: 4, PointsFor: 1600, PointsAgainst: 1450, FinalStanding: 1},
		{Owners: "Bob", Wins: 9, Losses: 5, PointsFor: 1550, PointsAgainst: 1500, FinalStanding: 2},
		{Owners: "Carol", Wins: 7, Losses: 7, PointsFor: 1480, PointsAgainst: 1495, FinalStanding: 3},
		{Owners: "Dave", Wins: 2, Losses: 12, PointsFor: 1200, PointsAgainst: 1385, FinalStanding: 4},
	}
	matchups := []db.GetMatchupsByLeagueIdRow{
		matchupRow(1, 3, 1, 4, 160, 70, false, "REGULAR_SEASON", "Alice Alpha", "Alice", "Dave Delta", "Dave", 2023, 1),
		matchupRow(2, 5, 3, 2, 88.4, 88.1, false, "REGULAR_SEASON", "Carol Comets", "Carol", "Bob Brigade", "Bob", 2023, 1),
		matchupRow(3, 8, 4, 1, 52, 101, false, "REGULAR_SEASON", "Dave Delta", "Dave", "Alice Alpha", "Alice", 2023, 1),
		matchupRow(4, 14, 1, 2, 120, 110, true, "WINNERS_BRACKET", "Alice Alpha", "Alice", "Bob Brigade", "Bob", 2023, 1),
		matchupRow(5, 14, 3, 4, 95, 90, true, "LOSERS_BRACKET", "Carol Comets", "Carol", "Dave Delta", "Dave", 2023, 1),
		matchupRow(6, 15, 1, 2, 130, 125, true, "WINNERS_BRACKET", "Alice Alpha", "Alice", "Bob Brigade", "Bob", 2023, 1),
	}

	pageData, err := BuildPageData(
		[]db.GetAllLeaguesRow{league},
		map[int32][]db.GetTeamsByLeagueYearRow{1: teams},
		map[int32][]db.GetMatchupsByLeagueIdRow{1: matchups},
		nil,
	)
	if err != nil {
		t.Fatalf("BuildPageData: %v", err)
	}

	if pageData.SeasonCount != 1 {
		t.Fatalf("SeasonCount = %d, want 1", pageData.SeasonCount)
	}
	if pageData.OwnerCount != 4 {
		t.Fatalf("OwnerCount = %d, want 4", pageData.OwnerCount)
	}
	if pageData.MatchupCount != 6 {
		t.Fatalf("MatchupCount = %d, want 6", pageData.MatchupCount)
	}

	highest := requireHighlightCard(t, pageData.HighlightCards, "Highest weekly score")
	if highest.Owner != "Alice" || !nearlyEqual(highest.Value, 160, 0.001) {
		t.Fatalf("highest weekly score = %#v, want owner Alice and value 160", highest)
	}

	lowest := requireHighlightCard(t, pageData.HighlightCards, "Lowest weekly score")
	if lowest.Owner != "Dave" || !nearlyEqual(lowest.Value, 52, 0.001) {
		t.Fatalf("lowest weekly score = %#v, want owner Dave and value 52", lowest)
	}

	closest := requireHighlightCard(t, pageData.HighlightCards, "Closest win")
	if closest.Owner != "Carol" || !nearlyEqual(closest.Value, 0.3, 0.001) {
		t.Fatalf("closest win = %#v, want owner Carol and value 0.3", closest)
	}

	biggest := requireHighlightCard(t, pageData.HighlightCards, "Biggest blowout")
	if biggest.Owner != "Alice" || !nearlyEqual(biggest.Value, 90, 0.001) {
		t.Fatalf("biggest blowout = %#v, want owner Alice and value 90", biggest)
	}

	alice := requireOwnerTotal(t, pageData.OwnerTotals, "Alice")
	if alice.Titles != 0 || alice.PlayoffAppearances != 1 || alice.Wins != 10 || !nearlyEqual(alice.AveragePointsFor, 1600, 0.001) {
		t.Fatalf("Alice owner total = %#v, want titles=0 appearances=1 wins=10 averagePointsFor=1600", alice)
	}

	bob := requireOwnerTotal(t, pageData.OwnerTotals, "Bob")
	if bob.PlayoffAppearances != 1 {
		t.Fatalf("Bob playoff appearances = %d, want 1", bob.PlayoffAppearances)
	}

	carol := requireOwnerTotal(t, pageData.OwnerTotals, "Carol")
	if carol.PlayoffAppearances != 0 {
		t.Fatalf("Carol playoff appearances = %d, want 0", carol.PlayoffAppearances)
	}

	if len(pageData.PlayoffOwnerTotals) != 2 {
		t.Fatalf("len(PlayoffOwnerTotals) = %d, want 2", len(pageData.PlayoffOwnerTotals))
	}

	playoffAlice := requirePlayoffOwnerTotal(t, pageData.PlayoffOwnerTotals, "Alice")
	if playoffAlice.Appearances != 1 || playoffAlice.FinalsAppearances != 0 || playoffAlice.Wins != 2 || playoffAlice.Losses != 0 || playoffAlice.Titles != 0 || !nearlyEqual(playoffAlice.TitleConversion, 0, 0.001) {
		t.Fatalf("Alice playoff total = %#v, want appearances=1 finals=0 wins=2 losses=0 titles=0 conversion=0", playoffAlice)
	}

	playoffBob := requirePlayoffOwnerTotal(t, pageData.PlayoffOwnerTotals, "Bob")
	if playoffBob.Appearances != 1 || playoffBob.FinalsAppearances != 0 || playoffBob.Wins != 0 || playoffBob.Losses != 2 || !nearlyEqual(playoffBob.TitleConversion, 0, 0.001) {
		t.Fatalf("Bob playoff total = %#v, want appearances=1 finals=0 wins=0 losses=2 conversion=0", playoffBob)
	}

	playoffHighest := requireHighlightCard(t, pageData.PlayoffHighlightCards, "Highest playoff score")
	if playoffHighest.Owner != "Alice" || !nearlyEqual(playoffHighest.Value, 130, 0.001) {
		t.Fatalf("highest playoff score = %#v, want owner Alice and value 130", playoffHighest)
	}

	if len(pageData.ChampionshipHighlightCards) != 0 || len(pageData.Champions) != 0 {
		t.Fatalf("legacy matchup data invented a championship: cards=%#v champions=%#v", pageData.ChampionshipHighlightCards, pageData.Champions)
	}

	if len(pageData.BestRegularSeasons) == 0 || pageData.BestRegularSeasons[0].Owner != "Alice" {
		t.Fatalf("best regular seasons first row = %#v, want Alice first", pageData.BestRegularSeasons)
	}
	if len(pageData.RegularSeasonOwnerTotals) == 0 || pageData.RegularSeasonOwnerTotals[0].Owner != "Alice" {
		t.Fatalf("regular season totals first row = %#v, want Alice first", pageData.RegularSeasonOwnerTotals)
	}
}

func TestBuildPageDataCountsWinnersBracketByeAsPlayoffAppearance(t *testing.T) {
	league := db.GetAllLeaguesRow{ID: 2, LeagueId: 2024, Year: 2024}
	teams := []db.GetTeamsByLeagueYearRow{
		{Owners: "Alice", Wins: 11, Losses: 3, PointsFor: 1650, PointsAgainst: 1400, FinalStanding: 1},
		{Owners: "Bob", Wins: 9, Losses: 5, PointsFor: 1500, PointsAgainst: 1475, FinalStanding: 2},
		{Owners: "Carol", Wins: 8, Losses: 6, PointsFor: 1490, PointsAgainst: 1455, FinalStanding: 3},
		{Owners: "Dave", Wins: 4, Losses: 10, PointsFor: 1310, PointsAgainst: 1505, FinalStanding: 4},
	}
	matchups := []db.GetMatchupsByLeagueIdRow{
		byeMatchupRow(10, 14, 1, 118, true, "WINNERS_BRACKET", "Alice Aces", "Alice", 2024, 2),
		matchupRow(11, 14, 2, 3, 115, 100, true, "WINNERS_BRACKET", "Bob Bolts", "Bob", "Carol Caps", "Carol", 2024, 2),
		byeMatchupRow(12, 14, 4, 90, true, "LOSERS_BRACKET", "Dave Darts", "Dave", 2024, 2),
	}

	pageData, err := BuildPageData(
		[]db.GetAllLeaguesRow{league},
		map[int32][]db.GetTeamsByLeagueYearRow{2: teams},
		map[int32][]db.GetMatchupsByLeagueIdRow{2: matchups},
		nil,
	)
	if err != nil {
		t.Fatalf("BuildPageData: %v", err)
	}

	alice := requireOwnerTotal(t, pageData.OwnerTotals, "Alice")
	if alice.PlayoffAppearances != 1 {
		t.Fatalf("Alice playoff appearances = %d, want 1", alice.PlayoffAppearances)
	}
	bob := requireOwnerTotal(t, pageData.OwnerTotals, "Bob")
	if bob.PlayoffAppearances != 1 {
		t.Fatalf("Bob playoff appearances = %d, want 1", bob.PlayoffAppearances)
	}
	carol := requireOwnerTotal(t, pageData.OwnerTotals, "Carol")
	if carol.PlayoffAppearances != 1 {
		t.Fatalf("Carol playoff appearances = %d, want 1", carol.PlayoffAppearances)
	}
	dave := requireOwnerTotal(t, pageData.OwnerTotals, "Dave")
	if dave.PlayoffAppearances != 0 {
		t.Fatalf("Dave playoff appearances = %d, want 0", dave.PlayoffAppearances)
	}

	if _, ok := findPlayoffOwnerTotal(pageData.PlayoffOwnerTotals, "Alice"); !ok {
		t.Fatal("expected Alice to appear in playoff owner totals because a winners-bracket bye counts as an appearance")
	}
	if _, ok := findPlayoffOwnerTotal(pageData.PlayoffOwnerTotals, "Dave"); ok {
		t.Fatal("did not expect Dave in playoff owner totals because losers-bracket byes should not count as appearances")
	}
}

func TestBuildPageDataFromSeasonsMergesProvidersAndAliases(t *testing.T) {
	pageData := BuildPageDataFromSeasons(
		[]SeasonInput{
			{
				Year: 2022,
				Teams: []TeamInput{
					{Owner: "Alice ESPN", Wins: 10, Losses: 4, PointsFor: PointsFromWhole(1600), PointsAgainst: PointsFromWhole(1450), FinalStanding: 1},
					{Owner: "Bob", Wins: 8, Losses: 6, PointsFor: PointsFromWhole(1500), PointsAgainst: PointsFromWhole(1475), FinalStanding: 2},
				},
				Matchups: []MatchupInput{
					{Week: 14, HomePresent: true, AwayPresent: true, HomeOwner: "Alice ESPN", HomeTeamName: "Aces", HomeScore: PointsFromWhole(120), AwayOwner: "Bob", AwayTeamName: "Bolts", AwayScore: PointsFromWhole(100), IsPlayoff: true, IsChampionship: true, ChampionshipWinner: MatchupWinnerHome, MatchupType: "WINNERS_BRACKET"},
				},
			},
			{
				Year: 2023,
				Teams: []TeamInput{
					{Owner: "Alice Sleeper", Wins: 9, Losses: 5, PointsFor: mustPoints(t, "1550.8"), PointsAgainst: mustPoints(t, "1499.4"), FinalStanding: 2},
					{Owner: "Carol", Wins: 11, Losses: 3, PointsFor: mustPoints(t, "1700.2"), PointsAgainst: mustPoints(t, "1425.7"), FinalStanding: 1},
				},
				Matchups: []MatchupInput{
					{Week: 15, HomePresent: true, AwayPresent: true, HomeOwner: "Carol", HomeTeamName: "Comets", HomeScore: mustPoints(t, "130.2"), AwayOwner: "Alice Sleeper", AwayTeamName: "Aces", AwayScore: mustPoints(t, "128.1"), IsPlayoff: true, IsChampionship: true, ChampionshipWinner: MatchupWinnerHome, MatchupType: "WINNERS_BRACKET"},
				},
			},
		},
		map[string]string{
			"Alice ESPN":    "Alice",
			"Alice Sleeper": "Alice",
		},
	)

	if pageData.SeasonCount != 2 {
		t.Fatalf("SeasonCount = %d, want 2", pageData.SeasonCount)
	}
	if pageData.OwnerCount != 3 {
		t.Fatalf("OwnerCount = %d, want 3 after alias rollup", pageData.OwnerCount)
	}

	alice := requireOwnerTotal(t, pageData.OwnerTotals, "Alice")
	if alice.Seasons != 2 || alice.Wins != 19 || alice.PlayoffAppearances != 2 || alice.Titles != 1 {
		t.Fatalf("Alice owner total = %#v, want merged seasons/wins/playoff appearances/title", alice)
	}

	carolPlayoffs := requirePlayoffOwnerTotal(t, pageData.PlayoffOwnerTotals, "Carol")
	if carolPlayoffs.Appearances != 1 || carolPlayoffs.FinalsAppearances != 1 || carolPlayoffs.Titles != 1 || carolPlayoffs.Wins != 1 {
		t.Fatalf("Carol playoff total = %#v, want sleeper championship totals", carolPlayoffs)
	}

	if len(pageData.Champions) != 2 {
		t.Fatalf("len(Champions) = %d, want 2", len(pageData.Champions))
	}
	if pageData.Champions[0].Year != 2023 || pageData.Champions[0].Owner != "Carol" {
		t.Fatalf("newest champion = %#v, want Carol 2023 first", pageData.Champions[0])
	}
	if pageData.Champions[1].Year != 2022 || pageData.Champions[1].Owner != "Alice" {
		t.Fatalf("older champion = %#v, want Alice 2022 second", pageData.Champions[1])
	}
}

func TestBuildPageDataFromSeasonsHandlesSleeperLikePartialPlayoffData(t *testing.T) {
	pageData := BuildPageDataFromSeasons(
		[]SeasonInput{
			{
				Year: 2024,
				Teams: []TeamInput{
					{Owner: "Alice", Wins: 10, Losses: 4, PointsFor: mustPoints(t, "1600.5"), PointsAgainst: mustPoints(t, "1500.5"), FinalStanding: 1},
					{Owner: "Bob", Wins: 9, Losses: 5, PointsFor: mustPoints(t, "1510.9"), PointsAgainst: mustPoints(t, "1490.1"), FinalStanding: 2},
				},
				Matchups: []MatchupInput{
					{Week: 1, HomePresent: true, AwayPresent: true, HomeOwner: "Alice", HomeTeamName: "Aces", HomeScore: mustPoints(t, "108.4"), AwayOwner: "Bob", AwayTeamName: "Bolts", AwayScore: mustPoints(t, "101.2"), MatchupType: "REGULAR_SEASON"},
					{Week: 15, HomePresent: true, AwayPresent: false, HomeOwner: "Alice", HomeTeamName: "Aces", HomeScore: mustPoints(t, "118.4"), IsPlayoff: true, MatchupType: "WINNERS_BRACKET"},
				},
			},
		},
		nil,
	)

	if pageData.MatchupCount != 1 {
		t.Fatalf("MatchupCount = %d, want only played matchups counted", pageData.MatchupCount)
	}
	alice := requireOwnerTotal(t, pageData.OwnerTotals, "Alice")
	if alice.PlayoffAppearances != 1 {
		t.Fatalf("Alice playoff appearances = %d, want bye to count as an appearance", alice.PlayoffAppearances)
	}
	if len(pageData.Champions) != 0 {
		t.Fatalf("len(Champions) = %d, want no invented champion from partial data", len(pageData.Champions))
	}
}

func TestBuildPageDataHandlesEmptyInput(t *testing.T) {
	pageData, err := BuildPageData(nil, map[int32][]db.GetTeamsByLeagueYearRow{}, map[int32][]db.GetMatchupsByLeagueIdRow{}, nil)
	if err != nil {
		t.Fatalf("BuildPageData: %v", err)
	}

	if pageData.SeasonCount != 0 || pageData.OwnerCount != 0 || pageData.MatchupCount != 0 {
		t.Fatalf("empty page data counts = %#v, want all zero", pageData)
	}
	if len(pageData.HighlightCards) != 0 {
		t.Fatalf("len(HighlightCards) = %d, want 0", len(pageData.HighlightCards))
	}
	if len(pageData.PlayoffHighlightCards) != 0 {
		t.Fatalf("len(PlayoffHighlightCards) = %d, want 0", len(pageData.PlayoffHighlightCards))
	}
}

func TestParsePoints(t *testing.T) {
	tests := []struct {
		input string
		want  Points
		text  string
	}{
		{input: "0", want: 0, text: "0"},
		{input: "+1", want: 100, text: "1"},
		{input: "-1", want: -100, text: "-1"},
		{input: "12.3", want: 1230, text: "12.3"},
		{input: "12.34", want: 1234, text: "12.34"},
		{input: "-0.01", want: -1, text: "-0.01"},
		{input: "0001.20", want: 120, text: "1.2"},
		{input: "92233720368547758.07", want: Points(math.MaxInt64), text: "92233720368547758.07"},
		{input: "-92233720368547758.08", want: Points(math.MinInt64), text: "-92233720368547758.08"},
	}

	for _, test := range tests {
		t.Run(test.input, func(t *testing.T) {
			got, err := ParsePoints(test.input)
			if err != nil {
				t.Fatalf("ParsePoints(%q): %v", test.input, err)
			}
			if got != test.want {
				t.Fatalf("ParsePoints(%q) = %d, want %d", test.input, got, test.want)
			}
			if got.String() != test.text {
				t.Fatalf("ParsePoints(%q).String() = %q, want %q", test.input, got.String(), test.text)
			}
		})
	}
}

func TestParsePointsRejectsInvalidValues(t *testing.T) {
	invalid := []string{
		"",
		" ",
		" 1",
		"1 ",
		"+",
		"-",
		".1",
		"1.",
		"1.234",
		"1..2",
		"1e2",
		"NaN",
		"Inf",
		"--1",
		"92233720368547758.08",
		"-92233720368547758.09",
	}

	for _, input := range invalid {
		t.Run(input, func(t *testing.T) {
			if _, err := ParsePoints(input); err == nil {
				t.Fatalf("ParsePoints(%q) succeeded, want error", input)
			}
		})
	}
}

func TestPointsConversions(t *testing.T) {
	got, err := PointsFromFloat64(123.45)
	if err != nil {
		t.Fatalf("PointsFromFloat64(123.45): %v", err)
	}
	if got != 12345 || got.Float64() != 123.45 {
		t.Fatalf("PointsFromFloat64(123.45) = %d (%v), want 12345 (123.45)", got, got.Float64())
	}
	if got := PointsFromWhole(-12); got != -1200 || got.String() != "-12" {
		t.Fatalf("PointsFromWhole(-12) = %d (%q), want -1200 (-12)", got, got.String())
	}

	for _, value := range []float64{math.NaN(), math.Inf(1), math.Inf(-1), 1.234, math.MaxFloat64} {
		if _, err := PointsFromFloat64(value); err == nil {
			t.Fatalf("PointsFromFloat64(%v) succeeded, want error", value)
		}
	}
}

func TestBuildPageDataRejectsOverpreciseLegacyScores(t *testing.T) {
	league := db.GetAllLeaguesRow{ID: 7, Year: 2025}
	matchup := matchupRow(1, 1, 1, 2, 100.001, 99, false, "REGULAR_SEASON", "A", "Alice", "B", "Bob", 2025, 7)

	if _, err := BuildPageData(
		[]db.GetAllLeaguesRow{league},
		map[int32][]db.GetTeamsByLeagueYearRow{},
		map[int32][]db.GetMatchupsByLeagueIdRow{7: {matchup}},
		nil,
	); err == nil {
		t.Fatal("BuildPageData accepted an overprecise legacy score")
	}
}

func TestBuildPageDataFromSeasonsUsesExactSumsSortingAndMargins(t *testing.T) {
	pageData := BuildPageDataFromSeasons([]SeasonInput{
		{
			Year: 2023,
			Teams: []TeamInput{
				{Owner: "Alice", Wins: 8, Losses: 6, PointsFor: mustPoints(t, "1000.01"), PointsAgainst: mustPoints(t, "900.01")},
				{Owner: "Bob", Wins: 8, Losses: 6, PointsFor: mustPoints(t, "1000"), PointsAgainst: mustPoints(t, "900")},
			},
			Matchups: []MatchupInput{
				{Week: 1, HomePresent: true, AwayPresent: true, HomeOwner: "Alice", HomeTeamName: "Aces", HomeScore: mustPoints(t, "100.01"), AwayOwner: "Bob", AwayTeamName: "Bolts", AwayScore: mustPoints(t, "100"), MatchupType: "REGULAR_SEASON"},
			},
		},
		{
			Year: 2024,
			Teams: []TeamInput{
				{Owner: "Alice", Wins: 8, Losses: 6, PointsFor: mustPoints(t, "1000.02"), PointsAgainst: mustPoints(t, "900.02")},
				{Owner: "Bob", Wins: 8, Losses: 6, PointsFor: mustPoints(t, "1000.04"), PointsAgainst: mustPoints(t, "900.04")},
			},
		},
	}, nil)

	alice := requireOwnerTotal(t, pageData.OwnerTotals, "Alice")
	if alice.PointsFor != mustPoints(t, "2000.03") || alice.PointsAgainst != mustPoints(t, "1800.03") {
		t.Fatalf("Alice exact totals = %s/%s, want 2000.03/1800.03", alice.PointsFor, alice.PointsAgainst)
	}
	bob := requireOwnerTotal(t, pageData.OwnerTotals, "Bob")
	if bob.PointsFor != mustPoints(t, "2000.04") {
		t.Fatalf("Bob exact PF = %s, want 2000.04", bob.PointsFor)
	}
	if pageData.RegularSeasonOwnerTotals[0].Owner != "Bob" {
		t.Fatalf("regular season points tiebreak leader = %q, want Bob", pageData.RegularSeasonOwnerTotals[0].Owner)
	}
	closest := requireHighlightCard(t, pageData.HighlightCards, "Closest win")
	if closest.Value != 0.01 {
		t.Fatalf("closest margin = %v, want 0.01", closest.Value)
	}
}

func TestBuildPageDataFromSeasonsRequiresExplicitChampionship(t *testing.T) {
	pageData := BuildPageDataFromSeasons([]SeasonInput{
		{
			Year: 2024,
			Teams: []TeamInput{
				{Owner: "Alice", PointsFor: PointsFromWhole(1)},
				{Owner: "Bob", PointsFor: PointsFromWhole(1)},
			},
			Matchups: []MatchupInput{
				{Week: 16, HomePresent: true, AwayPresent: true, HomeOwner: "Alice", HomeTeamName: "Aces", HomeScore: PointsFromWhole(130), AwayOwner: "Bob", AwayTeamName: "Bolts", AwayScore: PointsFromWhole(120), IsPlayoff: true, MatchupType: "WINNERS_BRACKET"},
			},
		},
	}, nil)

	if len(pageData.Champions) != 0 {
		t.Fatalf("Champions = %#v, want none without IsChampionship", pageData.Champions)
	}
	if requireOwnerTotal(t, pageData.OwnerTotals, "Alice").Titles != 0 {
		t.Fatal("unmarked winners-bracket matchup awarded a title")
	}
}

func TestBuildPageDataFromSeasonsOfficialWinnerOverridesTiedScore(t *testing.T) {
	pageData := BuildPageDataFromSeasons([]SeasonInput{
		{
			Year: 2025,
			Teams: []TeamInput{
				{Owner: "Alice", PointsFor: PointsFromWhole(1)},
				{Owner: "Bob", PointsFor: PointsFromWhole(1)},
			},
			Matchups: []MatchupInput{
				{
					Week:               17,
					HomePresent:        true,
					AwayPresent:        true,
					HomeOwner:          "Alice",
					HomeTeamName:       "Aces",
					HomeScore:          mustPoints(t, "121.25"),
					AwayOwner:          "Bob",
					AwayTeamName:       "Bolts",
					AwayScore:          mustPoints(t, "121.25"),
					IsPlayoff:          true,
					IsChampionship:     true,
					ChampionshipWinner: MatchupWinnerAway,
					MatchupType:        "WINNERS_BRACKET",
				},
			},
		},
	}, nil)

	if len(pageData.Champions) != 1 || pageData.Champions[0].Owner != "Bob" {
		t.Fatalf("Champions = %#v, want official away winner Bob", pageData.Champions)
	}
	if pageData.Champions[0].WinningScore != mustPoints(t, "121.25") || pageData.Champions[0].LosingScore != mustPoints(t, "121.25") {
		t.Fatalf("championship tied scores = %#v, want exact 121.25 scores", pageData.Champions[0])
	}
	bob := requirePlayoffOwnerTotal(t, pageData.PlayoffOwnerTotals, "Bob")
	alice := requirePlayoffOwnerTotal(t, pageData.PlayoffOwnerTotals, "Alice")
	if bob.Titles != 1 || bob.Wins != 1 || bob.FinalsAppearances != 1 || alice.Losses != 1 || alice.FinalsAppearances != 1 {
		t.Fatalf("official tied result totals: Bob=%#v Alice=%#v", bob, alice)
	}
	closest := requireHighlightCard(t, pageData.ChampionshipHighlightCards, "Closest championship win")
	if closest.Owner != "Bob" || closest.Value != 0 {
		t.Fatalf("official tied championship record = %#v, want Bob with zero-point margin", closest)
	}
}

func TestBuildPageDataFromSeasonsCountsAllWinnersBracketRoundsOnce(t *testing.T) {
	pageData := BuildPageDataFromSeasons([]SeasonInput{
		{
			Year: 2025,
			Teams: []TeamInput{
				{Owner: "Alice"}, {Owner: "Bob"}, {Owner: "Carol"}, {Owner: "Dave"}, {Owner: "Eve"},
			},
			Matchups: []MatchupInput{
				{Week: 14, HomePresent: true, AwayPresent: true, HomeOwner: "Alice", HomeScore: PointsFromWhole(100), AwayOwner: "Bob", AwayScore: PointsFromWhole(90), IsPlayoff: true, MatchupType: "WINNERS_BRACKET"},
				{Week: 15, HomePresent: true, AwayPresent: true, HomeOwner: "Carol", HomeScore: PointsFromWhole(110), AwayOwner: "Alice", AwayScore: PointsFromWhole(105), IsPlayoff: true, MatchupType: "WINNERS_BRACKET"},
				{Week: 16, HomePresent: true, HomeOwner: "Dave", HomeScore: PointsFromWhole(115), IsPlayoff: true, MatchupType: "WINNERS_BRACKET"},
				{Week: 16, HomePresent: true, HomeOwner: "Eve", HomeScore: PointsFromWhole(80), IsPlayoff: true, MatchupType: "LOSERS_BRACKET"},
			},
		},
	}, nil)

	for _, owner := range []string{"Alice", "Bob", "Carol", "Dave"} {
		if got := requireOwnerTotal(t, pageData.OwnerTotals, owner).PlayoffAppearances; got != 1 {
			t.Fatalf("%s playoff appearances = %d, want 1", owner, got)
		}
	}
	if got := requireOwnerTotal(t, pageData.OwnerTotals, "Eve").PlayoffAppearances; got != 0 {
		t.Fatalf("Eve playoff appearances = %d, want 0", got)
	}
}

func TestBuildPageDataFromSeasonsByeDoesNotCreatePlayedResultOrRecord(t *testing.T) {
	pageData := BuildPageDataFromSeasons([]SeasonInput{
		{
			Year:  2025,
			Teams: []TeamInput{{Owner: "Alice"}},
			Matchups: []MatchupInput{
				{Week: 14, HomePresent: true, HomeOwner: "Alice", HomeTeamName: "Aces", HomeScore: PointsFromWhole(125), IsPlayoff: true, MatchupType: "WINNERS_BRACKET"},
			},
		},
	}, nil)

	if pageData.MatchupCount != 0 {
		t.Fatalf("MatchupCount = %d, want 0 for a bye", pageData.MatchupCount)
	}
	// Aggregate leader cards still exist because a team exists; no score record cards may exist.
	for _, card := range append(pageData.HighlightCards, pageData.PlayoffHighlightCards...) {
		if card.Year != 0 {
			t.Fatalf("bye created game record card %#v", card)
		}
	}
	playoff := requirePlayoffOwnerTotal(t, pageData.PlayoffOwnerTotals, "Alice")
	if playoff.Appearances != 1 || playoff.Wins != 0 || playoff.Losses != 0 {
		t.Fatalf("bye playoff totals = %#v, want appearance only", playoff)
	}
}

func TestBuildPageDataFromSeasonsNormalizesAliasesOnceWithoutMutation(t *testing.T) {
	seasons := []SeasonInput{
		{
			Year: 2025,
			Teams: []TeamInput{
				{Owner: "  Alice Old  ", PointsFor: mustPoints(t, "100.01")},
				{Owner: "Bob", PointsFor: mustPoints(t, "99.99")},
			},
			Matchups: []MatchupInput{
				{Week: 17, HomePresent: true, AwayPresent: true, HomeOwner: "  Alice Old  ", HomeScore: PointsFromWhole(100), AwayOwner: "Bob", AwayScore: PointsFromWhole(90), IsPlayoff: true, IsChampionship: true, ChampionshipWinner: MatchupWinnerHome, MatchupType: "WINNERS_BRACKET"},
			},
		},
	}
	beforeTeams := append([]TeamInput(nil), seasons[0].Teams...)
	beforeMatchups := append([]MatchupInput(nil), seasons[0].Matchups...)

	pageData := BuildPageDataFromSeasons(seasons, map[string]string{
		"Alice Old": "Alice",
		"Alice":     "Wrong second alias",
	})

	if !reflect.DeepEqual(seasons[0].Teams, beforeTeams) || !reflect.DeepEqual(seasons[0].Matchups, beforeMatchups) {
		t.Fatalf("BuildPageDataFromSeasons mutated caller input: %#v", seasons)
	}
	if pageData.OwnerCount != 2 || requireOwnerTotal(t, pageData.OwnerTotals, "Alice").Titles != 1 {
		t.Fatalf("canonical Alice total missing or incorrect: %#v", pageData.OwnerTotals)
	}
	if _, ok := findOwnerTotal(pageData.OwnerTotals, "Wrong second alias"); ok {
		t.Fatalf("aliases were applied more than once: %#v", pageData.OwnerTotals)
	}
	if len(pageData.Champions) != 1 || pageData.Champions[0].Owner != "Alice" {
		t.Fatalf("champion identity = %#v, want canonical Alice", pageData.Champions)
	}
}

func matchupRow(id, week, homeID, awayID int32, homeScore, awayScore float64, isPlayoff bool, matchupType, homeTeamName, homeOwner, awayTeamName, awayOwner string, year, leagueID int32) db.GetMatchupsByLeagueIdRow {
	return db.GetMatchupsByLeagueIdRow{
		ID:             id,
		Week:           week,
		HomeTeamID:     validID(homeID),
		AwayTeamID:     validID(awayID),
		HomeScore:      homeScore,
		AwayScore:      awayScore,
		IsPlayoff:      isPlayoff,
		MatchupType:    matchupType,
		HomeTeamName:   homeTeamName,
		HomeTeamOwners: homeOwner,
		AwayTeamName:   awayTeamName,
		AwayTeamOwners: awayOwner,
		LeagueYear:     year,
		LeagueId:       leagueID,
	}
}

func byeMatchupRow(id, week, homeID int32, homeScore float64, isPlayoff bool, matchupType, homeTeamName, homeOwner string, year, leagueID int32) db.GetMatchupsByLeagueIdRow {
	return db.GetMatchupsByLeagueIdRow{
		ID:             id,
		Week:           week,
		HomeTeamID:     validID(homeID),
		AwayTeamID:     sql.NullInt32{},
		HomeScore:      homeScore,
		AwayScore:      0,
		IsPlayoff:      isPlayoff,
		MatchupType:    matchupType,
		HomeTeamName:   homeTeamName,
		HomeTeamOwners: homeOwner,
		AwayTeamName:   "",
		AwayTeamOwners: "",
		LeagueYear:     year,
		LeagueId:       leagueID,
	}
}

func validID(id int32) sql.NullInt32 {
	return sql.NullInt32{Int32: id, Valid: true}
}

func requireHighlightCard(t *testing.T, cards []HighlightCard, label string) HighlightCard {
	t.Helper()
	for _, card := range cards {
		if card.Label == label {
			return card
		}
	}
	t.Fatalf("missing highlight card %q in %#v", label, cards)
	return HighlightCard{}
}

func requireOwnerTotal(t *testing.T, totals []OwnerTotal, owner string) OwnerTotal {
	t.Helper()
	total, ok := findOwnerTotal(totals, owner)
	if ok {
		return total
	}
	t.Fatalf("missing owner total %q in %#v", owner, totals)
	return OwnerTotal{}
}

func findOwnerTotal(totals []OwnerTotal, owner string) (OwnerTotal, bool) {
	for _, total := range totals {
		if total.Owner == owner {
			return total, true
		}
	}
	return OwnerTotal{}, false
}

func requirePlayoffOwnerTotal(t *testing.T, totals []PlayoffOwnerTotal, owner string) PlayoffOwnerTotal {
	t.Helper()
	total, ok := findPlayoffOwnerTotal(totals, owner)
	if !ok {
		t.Fatalf("missing playoff owner total %q in %#v", owner, totals)
	}
	return total
}

func findPlayoffOwnerTotal(totals []PlayoffOwnerTotal, owner string) (PlayoffOwnerTotal, bool) {
	for _, total := range totals {
		if total.Owner == owner {
			return total, true
		}
	}
	return PlayoffOwnerTotal{}, false
}

func nearlyEqual(a, b, tolerance float64) bool {
	return math.Abs(a-b) <= tolerance
}

func mustPoints(t *testing.T, value string) Points {
	t.Helper()
	points, err := ParsePoints(value)
	if err != nil {
		t.Fatalf("ParsePoints(%q): %v", value, err)
	}
	return points
}
