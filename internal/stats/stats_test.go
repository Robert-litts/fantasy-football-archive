package stats

import (
	"database/sql"
	"math"
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

	pageData := BuildPageData(
		[]db.GetAllLeaguesRow{league},
		map[int32][]db.GetTeamsByLeagueYearRow{1: teams},
		map[int32][]db.GetMatchupsByLeagueIdRow{1: matchups},
		nil,
	)

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
	if alice.Titles != 1 || alice.PlayoffAppearances != 1 || alice.Wins != 10 || !nearlyEqual(alice.AveragePointsFor, 1600, 0.001) {
		t.Fatalf("Alice owner total = %#v, want titles=1 appearances=1 wins=10 averagePointsFor=1600", alice)
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
	if playoffAlice.Appearances != 1 || playoffAlice.FinalsAppearances != 1 || playoffAlice.Wins != 2 || playoffAlice.Losses != 0 || playoffAlice.Titles != 1 || !nearlyEqual(playoffAlice.TitleConversion, 1, 0.001) {
		t.Fatalf("Alice playoff total = %#v, want appearances=1 finals=1 wins=2 losses=0 titles=1 conversion=1", playoffAlice)
	}

	playoffBob := requirePlayoffOwnerTotal(t, pageData.PlayoffOwnerTotals, "Bob")
	if playoffBob.Appearances != 1 || playoffBob.FinalsAppearances != 1 || playoffBob.Wins != 0 || playoffBob.Losses != 2 || !nearlyEqual(playoffBob.TitleConversion, 0, 0.001) {
		t.Fatalf("Bob playoff total = %#v, want appearances=1 finals=1 wins=0 losses=2 conversion=0", playoffBob)
	}

	playoffHighest := requireHighlightCard(t, pageData.PlayoffHighlightCards, "Highest playoff score")
	if playoffHighest.Owner != "Alice" || !nearlyEqual(playoffHighest.Value, 130, 0.001) {
		t.Fatalf("highest playoff score = %#v, want owner Alice and value 130", playoffHighest)
	}

	finalsLeader := requireHighlightCard(t, pageData.PlayoffHighlightCards, "Most finals appearances")
	if finalsLeader.Owner != "Alice" || !nearlyEqual(finalsLeader.Value, 1, 0.001) {
		t.Fatalf("most finals appearances = %#v, want owner Alice and value 1", finalsLeader)
	}

	bestConversion := requireHighlightCard(t, pageData.PlayoffHighlightCards, "Best title conversion")
	if bestConversion.Owner != "Alice" || !nearlyEqual(bestConversion.Value, 100, 0.001) {
		t.Fatalf("best title conversion = %#v, want owner Alice and value 100", bestConversion)
	}

	championshipHighest := requireHighlightCard(t, pageData.ChampionshipHighlightCards, "Highest championship score")
	if championshipHighest.Owner != "Alice" || !nearlyEqual(championshipHighest.Value, 130, 0.001) {
		t.Fatalf("highest championship score = %#v, want owner Alice and value 130", championshipHighest)
	}

	championshipClosest := requireHighlightCard(t, pageData.ChampionshipHighlightCards, "Closest championship win")
	if championshipClosest.Owner != "Alice" || !nearlyEqual(championshipClosest.Value, 5, 0.001) {
		t.Fatalf("closest championship win = %#v, want owner Alice and value 5", championshipClosest)
	}

	if len(pageData.Champions) != 1 {
		t.Fatalf("len(Champions) = %d, want 1", len(pageData.Champions))
	}
	if pageData.Champions[0].Owner != "Alice" || pageData.Champions[0].Year != 2023 {
		t.Fatalf("champion = %#v, want owner Alice year 2023", pageData.Champions[0])
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

	pageData := BuildPageData(
		[]db.GetAllLeaguesRow{league},
		map[int32][]db.GetTeamsByLeagueYearRow{2: teams},
		map[int32][]db.GetMatchupsByLeagueIdRow{2: matchups},
		nil,
	)

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

func TestBuildPageDataHandlesEmptyInput(t *testing.T) {
	pageData := BuildPageData(nil, map[int32][]db.GetTeamsByLeagueYearRow{}, map[int32][]db.GetMatchupsByLeagueIdRow{}, nil)

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
	for _, total := range totals {
		if total.Owner == owner {
			return total
		}
	}
	t.Fatalf("missing owner total %q in %#v", owner, totals)
	return OwnerTotal{}
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
