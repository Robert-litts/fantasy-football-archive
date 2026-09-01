package stats

import (
	"fmt"
	"math"
	"sort"
	"strconv"
	"strings"

	"github.com/Robert-litts/fantasy-football-archive/internal/db"
)

type PageData struct {
	SeasonCount                int
	OwnerCount                 int
	MatchupCount               int
	SleeperAvailable           bool
	SleeperMessage             string
	Warnings                   []error
	HighlightCards             []HighlightCard
	OwnerTotals                []OwnerTotal
	RegularSeasonOwnerTotals   []OwnerTotal
	BestRegularSeasons         []SeasonRecord
	PlayoffHighlightCards      []HighlightCard
	PlayoffOwnerTotals         []PlayoffOwnerTotal
	ChampionshipHighlightCards []HighlightCard
	Champions                  []ChampionRecord
}

type HighlightCard struct {
	Label     string
	Value     float64
	ValueText string
	Owner     string
	TeamName  string
	Opponent  string
	Year      int
	Week      int
	Detail    string
}

type OwnerTotal struct {
	Rank               int
	Owner              string
	Seasons            int
	Wins               int
	Losses             int
	Ties               int
	Titles             int
	PlayoffAppearances int
	PointsFor          Points
	PointsAgainst      Points
	AveragePointsFor   float64
	WinPct             float64
}

type PlayoffOwnerTotal struct {
	Rank              int
	Owner             string
	Appearances       int
	FinalsAppearances int
	Wins              int
	Losses            int
	Titles            int
	TitleConversion   float64
	WinPct            float64
}

type SeasonRecord struct {
	Rank          int
	Owner         string
	Year          int
	Wins          int
	Losses        int
	Ties          int
	FinalStanding int
	PointsFor     Points
	PointsAgainst Points
	WinPct        float64
}

type ChampionRecord struct {
	Year         int
	Owner        string
	TeamName     string
	Opponent     string
	WinningScore Points
	LosingScore  Points
}

// Points stores a fantasy score in hundredths of a point.
type Points int64

func ParsePoints(value string) (Points, error) {
	if value == "" {
		return 0, fmt.Errorf("points cannot be blank")
	}

	negative := false
	digits := value
	if digits[0] == '+' || digits[0] == '-' {
		negative = digits[0] == '-'
		digits = digits[1:]
		if digits == "" {
			return 0, fmt.Errorf("invalid points %q", value)
		}
	}

	whole, fraction, hasDecimal := strings.Cut(digits, ".")
	if whole == "" || (hasDecimal && (len(fraction) == 0 || len(fraction) > 2)) || strings.Contains(fraction, ".") {
		return 0, fmt.Errorf("invalid points %q", value)
	}
	for _, digit := range whole + fraction {
		if digit < '0' || digit > '9' {
			return 0, fmt.Errorf("invalid points %q", value)
		}
	}

	if !hasDecimal {
		fraction = "00"
	} else if len(fraction) == 1 {
		fraction += "0"
	}
	magnitude, err := strconv.ParseUint(whole+fraction, 10, 64)
	if err != nil {
		return 0, fmt.Errorf("points %q overflow: %w", value, err)
	}

	if negative {
		const minMagnitude = uint64(^uint64(0)>>1) + 1
		if magnitude > minMagnitude {
			return 0, fmt.Errorf("points %q overflow", value)
		}
		if magnitude == minMagnitude {
			return Points(-1 << 63), nil
		}
		return -Points(magnitude), nil
	}
	if magnitude > uint64(^uint64(0)>>1) {
		return 0, fmt.Errorf("points %q overflow", value)
	}
	return Points(magnitude), nil
}

func PointsFromFloat64(value float64) (Points, error) {
	if math.IsNaN(value) || math.IsInf(value, 0) {
		return 0, fmt.Errorf("invalid points value %v", value)
	}
	return ParsePoints(strconv.FormatFloat(value, 'f', -1, 64))
}

func PointsFromWhole(value int64) Points {
	const maxWhole = int64(^uint64(0)>>1) / 100
	const minWhole = (-1 << 63) / 100
	if value > maxWhole || value < minWhole {
		panic("whole points overflow")
	}
	return Points(value * 100)
}

func (points Points) Float64() float64 {
	return float64(points) / 100
}

func (points Points) String() string {
	raw := int64(points)
	negative := raw < 0
	magnitude := uint64(raw)
	if negative {
		magnitude = uint64(-(raw + 1)) + 1
	}

	value := strconv.FormatUint(magnitude/100, 10)
	fraction := magnitude % 100
	if fraction != 0 {
		value += "."
		if fraction < 10 {
			value += "0"
		}
		value += strconv.FormatUint(fraction, 10)
		value = strings.TrimSuffix(value, "0")
	}
	if negative && magnitude != 0 {
		return "-" + value
	}
	return value
}

type MatchupWinner uint8

const (
	MatchupWinnerUnknown MatchupWinner = iota
	MatchupWinnerHome
	MatchupWinnerAway
)

type SeasonInput struct {
	Year     int
	Teams    []TeamInput
	Matchups []MatchupInput
}

type TeamInput struct {
	Owner         string
	Wins          int
	Losses        int
	Ties          int
	FinalStanding int
	PointsFor     Points
	PointsAgainst Points
}

type MatchupInput struct {
	Week               int
	HomePresent        bool
	AwayPresent        bool
	HomeOwner          string
	HomeTeamName       string
	HomeScore          Points
	AwayOwner          string
	AwayTeamName       string
	AwayScore          Points
	IsPlayoff          bool
	IsChampionship     bool
	ChampionshipWinner MatchupWinner
	MatchupType        string
}

type singleGameRecord struct {
	Score    Points
	Margin   Points
	Owner    string
	TeamName string
	Opponent string
	Year     int
	Week     int
	Detail   string
}

type recordBook struct {
	highestScore   *singleGameRecord
	lowestScore    *singleGameRecord
	biggestBlowout *singleGameRecord
	closestWin     *singleGameRecord
}

func BuildPageData(leagues []db.GetAllLeaguesRow, teamsByLeague map[int32][]db.GetTeamsByLeagueYearRow, matchupsByLeague map[int32][]db.GetMatchupsByLeagueIdRow, ownerAliases map[string]string) (PageData, error) {
	seasons := make([]SeasonInput, 0, len(leagues))
	for _, league := range leagues {
		season := SeasonInput{
			Year:     int(league.Year),
			Teams:    make([]TeamInput, 0, len(teamsByLeague[league.ID])),
			Matchups: make([]MatchupInput, 0, len(matchupsByLeague[league.ID])),
		}
		for _, team := range teamsByLeague[league.ID] {
			season.Teams = append(season.Teams, TeamInput{
				Owner:         team.Owners,
				Wins:          int(team.Wins),
				Losses:        int(team.Losses),
				Ties:          int(team.Ties),
				FinalStanding: int(team.FinalStanding),
				PointsFor:     PointsFromWhole(int64(team.PointsFor)),
				PointsAgainst: PointsFromWhole(int64(team.PointsAgainst)),
			})
		}
		for _, matchup := range matchupsByLeague[league.ID] {
			homeScore, err := PointsFromFloat64(matchup.HomeScore)
			if err != nil {
				return PageData{}, fmt.Errorf("league %d week %d home score: %w", league.ID, matchup.Week, err)
			}
			awayScore, err := PointsFromFloat64(matchup.AwayScore)
			if err != nil {
				return PageData{}, fmt.Errorf("league %d week %d away score: %w", league.ID, matchup.Week, err)
			}
			season.Matchups = append(season.Matchups, MatchupInput{
				Week:         int(matchup.Week),
				HomePresent:  matchup.HomeTeamID.Valid,
				AwayPresent:  matchup.AwayTeamID.Valid,
				HomeOwner:    matchup.HomeTeamOwners,
				HomeTeamName: matchup.HomeTeamName,
				HomeScore:    homeScore,
				AwayOwner:    matchup.AwayTeamOwners,
				AwayTeamName: matchup.AwayTeamName,
				AwayScore:    awayScore,
				IsPlayoff:    matchup.IsPlayoff,
				MatchupType:  matchup.MatchupType,
			})
		}
		seasons = append(seasons, season)
	}

	return BuildPageDataFromSeasons(seasons, ownerAliases), nil
}

func BuildPageDataFromSeasons(seasons []SeasonInput, ownerAliases map[string]string) PageData {
	ownerTotalsByName := make(map[string]*OwnerTotal)
	playoffTotalsByName := make(map[string]*PlayoffOwnerTotal)
	bestRegularSeasons := make([]SeasonRecord, 0)
	champions := make([]ChampionRecord, 0)
	allRecords := &recordBook{}
	playoffRecords := &recordBook{}
	championshipRecords := &recordBook{}
	matchupCount := 0

	getOwnerTotal := func(owner string) *OwnerTotal {
		if owner == "" {
			owner = "Unknown"
		}
		if total, ok := ownerTotalsByName[owner]; ok {
			return total
		}
		total := &OwnerTotal{Owner: owner}
		ownerTotalsByName[owner] = total
		return total
	}

	getPlayoffOwnerTotal := func(owner string) *PlayoffOwnerTotal {
		if owner == "" {
			owner = "Unknown"
		}
		if total, ok := playoffTotalsByName[owner]; ok {
			return total
		}
		total := &PlayoffOwnerTotal{Owner: owner}
		playoffTotalsByName[owner] = total
		return total
	}

	for _, inputSeason := range seasons {
		season := canonicalizeSeason(inputSeason, ownerAliases)
		for _, team := range season.Teams {
			total := getOwnerTotal(team.Owner)
			total.Seasons++
			total.Wins += team.Wins
			total.Losses += team.Losses
			total.Ties += team.Ties
			total.PointsFor += team.PointsFor
			total.PointsAgainst += team.PointsAgainst

			bestRegularSeasons = append(bestRegularSeasons, SeasonRecord{
				Owner:         total.Owner,
				Year:          season.Year,
				Wins:          team.Wins,
				Losses:        team.Losses,
				Ties:          team.Ties,
				FinalStanding: team.FinalStanding,
				PointsFor:     team.PointsFor,
				PointsAgainst: team.PointsAgainst,
				WinPct:        calculateWinPct(team.Wins, team.Losses, team.Ties),
			})
		}

		for owner := range collectPlayoffOwners(season.Matchups) {
			getOwnerTotal(owner).PlayoffAppearances++
			getPlayoffOwnerTotal(owner).Appearances++
		}

		if championship := findChampionshipMatch(season.Matchups); championship != nil {
			winnerOwner, winnerTeam, loserTeam, winnerScore, loserScore := championshipWinner(*championship)
			if winnerOwner != "" {
				getOwnerTotal(winnerOwner).Titles++
				getPlayoffOwnerTotal(winnerOwner).Titles++
				champions = append(champions, ChampionRecord{
					Year:         season.Year,
					Owner:        winnerOwner,
					TeamName:     winnerTeam,
					Opponent:     loserTeam,
					WinningScore: winnerScore,
					LosingScore:  loserScore,
				})
			}

			championHomeGame, championAwayGame := buildSingleGameRecords(*championship)
			championHomeGame.Year = season.Year
			championAwayGame.Year = season.Year
			updateRecordBook(championshipRecords, *championship, championHomeGame, championAwayGame)
			if championship.HomeOwner != "" {
				getPlayoffOwnerTotal(championship.HomeOwner).FinalsAppearances++
			}
			if championship.AwayOwner != "" && championship.AwayOwner != championship.HomeOwner {
				getPlayoffOwnerTotal(championship.AwayOwner).FinalsAppearances++
			}
		}

		for _, matchup := range season.Matchups {
			if !matchup.HomePresent || !matchup.AwayPresent {
				continue
			}

			matchupCount++
			homeGame, awayGame := buildSingleGameRecords(matchup)
			homeGame.Year = season.Year
			awayGame.Year = season.Year
			updateRecordBook(allRecords, matchup, homeGame, awayGame)

			if matchup.IsPlayoff && matchup.MatchupType == "WINNERS_BRACKET" {
				updateRecordBook(playoffRecords, matchup, homeGame, awayGame)
				applyPlayoffResult(getPlayoffOwnerTotal, matchup, homeGame, awayGame)
			}
		}
	}

	ownerTotals := make([]OwnerTotal, 0, len(ownerTotalsByName))
	for _, total := range ownerTotalsByName {
		total.WinPct = calculateWinPct(total.Wins, total.Losses, total.Ties)
		total.AveragePointsFor = calculateAverage(total.PointsFor, total.Seasons)
		ownerTotals = append(ownerTotals, *total)
	}

	regularSeasonOwnerTotals := make([]OwnerTotal, len(ownerTotals))
	copy(regularSeasonOwnerTotals, ownerTotals)
	sort.Slice(regularSeasonOwnerTotals, func(i, j int) bool {
		if regularSeasonOwnerTotals[i].Wins != regularSeasonOwnerTotals[j].Wins {
			return regularSeasonOwnerTotals[i].Wins > regularSeasonOwnerTotals[j].Wins
		}
		if regularSeasonOwnerTotals[i].WinPct != regularSeasonOwnerTotals[j].WinPct {
			return regularSeasonOwnerTotals[i].WinPct > regularSeasonOwnerTotals[j].WinPct
		}
		if regularSeasonOwnerTotals[i].PointsFor != regularSeasonOwnerTotals[j].PointsFor {
			return regularSeasonOwnerTotals[i].PointsFor > regularSeasonOwnerTotals[j].PointsFor
		}
		return regularSeasonOwnerTotals[i].Owner < regularSeasonOwnerTotals[j].Owner
	})
	for i := range regularSeasonOwnerTotals {
		regularSeasonOwnerTotals[i].Rank = i + 1
	}

	sort.Slice(ownerTotals, func(i, j int) bool {
		if ownerTotals[i].Wins != ownerTotals[j].Wins {
			return ownerTotals[i].Wins > ownerTotals[j].Wins
		}
		if ownerTotals[i].Titles != ownerTotals[j].Titles {
			return ownerTotals[i].Titles > ownerTotals[j].Titles
		}
		if ownerTotals[i].WinPct != ownerTotals[j].WinPct {
			return ownerTotals[i].WinPct > ownerTotals[j].WinPct
		}
		return ownerTotals[i].Owner < ownerTotals[j].Owner
	})
	for i := range ownerTotals {
		ownerTotals[i].Rank = i + 1
	}

	playoffOwnerTotals := make([]PlayoffOwnerTotal, 0, len(playoffTotalsByName))
	for _, total := range playoffTotalsByName {
		total.WinPct = calculateWinPct(total.Wins, total.Losses, 0)
		total.TitleConversion = calculateRatio(total.Titles, total.FinalsAppearances)
		playoffOwnerTotals = append(playoffOwnerTotals, *total)
	}
	sort.Slice(playoffOwnerTotals, func(i, j int) bool {
		if playoffOwnerTotals[i].Titles != playoffOwnerTotals[j].Titles {
			return playoffOwnerTotals[i].Titles > playoffOwnerTotals[j].Titles
		}
		if playoffOwnerTotals[i].Wins != playoffOwnerTotals[j].Wins {
			return playoffOwnerTotals[i].Wins > playoffOwnerTotals[j].Wins
		}
		if playoffOwnerTotals[i].Appearances != playoffOwnerTotals[j].Appearances {
			return playoffOwnerTotals[i].Appearances > playoffOwnerTotals[j].Appearances
		}
		if playoffOwnerTotals[i].WinPct != playoffOwnerTotals[j].WinPct {
			return playoffOwnerTotals[i].WinPct > playoffOwnerTotals[j].WinPct
		}
		return playoffOwnerTotals[i].Owner < playoffOwnerTotals[j].Owner
	})
	for i := range playoffOwnerTotals {
		playoffOwnerTotals[i].Rank = i + 1
	}

	sort.Slice(bestRegularSeasons, func(i, j int) bool {
		if bestRegularSeasons[i].WinPct != bestRegularSeasons[j].WinPct {
			return bestRegularSeasons[i].WinPct > bestRegularSeasons[j].WinPct
		}
		if bestRegularSeasons[i].Wins != bestRegularSeasons[j].Wins {
			return bestRegularSeasons[i].Wins > bestRegularSeasons[j].Wins
		}
		if bestRegularSeasons[i].PointsFor != bestRegularSeasons[j].PointsFor {
			return bestRegularSeasons[i].PointsFor > bestRegularSeasons[j].PointsFor
		}
		if bestRegularSeasons[i].FinalStanding != bestRegularSeasons[j].FinalStanding {
			return bestRegularSeasons[i].FinalStanding < bestRegularSeasons[j].FinalStanding
		}
		return bestRegularSeasons[i].Year > bestRegularSeasons[j].Year
	})
	if len(bestRegularSeasons) > 10 {
		bestRegularSeasons = bestRegularSeasons[:10]
	}
	for i := range bestRegularSeasons {
		bestRegularSeasons[i].Rank = i + 1
	}

	sort.Slice(champions, func(i, j int) bool {
		return champions[i].Year > champions[j].Year
	})

	return PageData{
		SeasonCount:                len(seasons),
		OwnerCount:                 len(ownerTotals),
		MatchupCount:               matchupCount,
		HighlightCards:             buildOverviewHighlightCards(allRecords, ownerTotals),
		OwnerTotals:                ownerTotals,
		RegularSeasonOwnerTotals:   regularSeasonOwnerTotals,
		BestRegularSeasons:         bestRegularSeasons,
		PlayoffHighlightCards:      buildPlayoffHighlightCards(playoffRecords, playoffOwnerTotals),
		PlayoffOwnerTotals:         playoffOwnerTotals,
		ChampionshipHighlightCards: buildChampionshipHighlightCards(championshipRecords),
		Champions:                  champions,
	}
}

func normalizeOwner(owner string, ownerAliases map[string]string) string {
	normalized := strings.Join(strings.Fields(strings.TrimSpace(owner)), " ")
	if canonical, ok := ownerAliases[normalized]; ok {
		return strings.Join(strings.Fields(strings.TrimSpace(canonical)), " ")
	}
	return normalized
}

func canonicalizeSeason(season SeasonInput, ownerAliases map[string]string) SeasonInput {
	canonical := season
	canonical.Teams = append([]TeamInput(nil), season.Teams...)
	for i := range canonical.Teams {
		canonical.Teams[i].Owner = normalizeOwner(canonical.Teams[i].Owner, ownerAliases)
	}
	canonical.Matchups = append([]MatchupInput(nil), season.Matchups...)
	for i := range canonical.Matchups {
		canonical.Matchups[i].HomeOwner = normalizeOwner(canonical.Matchups[i].HomeOwner, ownerAliases)
		canonical.Matchups[i].AwayOwner = normalizeOwner(canonical.Matchups[i].AwayOwner, ownerAliases)
	}
	return canonical
}

func calculateWinPct(wins, losses, ties int) float64 {
	totalGames := wins + losses + ties
	if totalGames == 0 {
		return 0
	}
	return (float64(wins) + float64(ties)*0.5) / float64(totalGames)
}

func calculateAverage(total Points, count int) float64 {
	if count == 0 {
		return 0
	}
	return total.Float64() / float64(count)
}

func calculateRatio(numerator, denominator int) float64 {
	if denominator == 0 {
		return 0
	}
	return float64(numerator) / float64(denominator)
}

func buildSingleGameRecords(matchup MatchupInput) (singleGameRecord, singleGameRecord) {
	homeGame := singleGameRecord{
		Score:    matchup.HomeScore,
		Owner:    matchup.HomeOwner,
		TeamName: matchup.HomeTeamName,
		Opponent: matchup.AwayTeamName,
		Week:     matchup.Week,
		Detail:   formatGameType(matchup.IsPlayoff, matchup.MatchupType),
	}
	awayGame := singleGameRecord{
		Score:    matchup.AwayScore,
		Owner:    matchup.AwayOwner,
		TeamName: matchup.AwayTeamName,
		Opponent: matchup.HomeTeamName,
		Week:     matchup.Week,
		Detail:   formatGameType(matchup.IsPlayoff, matchup.MatchupType),
	}
	return homeGame, awayGame
}

func updateRecordBook(records *recordBook, matchup MatchupInput, homeGame, awayGame singleGameRecord) {
	if records.highestScore == nil || homeGame.Score > records.highestScore.Score {
		copyHome := homeGame
		records.highestScore = &copyHome
	}
	if records.highestScore == nil || awayGame.Score > records.highestScore.Score {
		copyAway := awayGame
		records.highestScore = &copyAway
	}
	if records.lowestScore == nil || homeGame.Score < records.lowestScore.Score {
		copyHome := homeGame
		records.lowestScore = &copyHome
	}
	if records.lowestScore == nil || awayGame.Score < records.lowestScore.Score {
		copyAway := awayGame
		records.lowestScore = &copyAway
	}
	winnerSide := matchupResultWinner(matchup)
	if winnerSide == MatchupWinnerUnknown {
		return
	}

	margin := homeGame.Score - awayGame.Score
	if margin < 0 {
		margin = -margin
	}
	winner := homeGame
	loser := awayGame
	if winnerSide == MatchupWinnerAway {
		winner = awayGame
		loser = homeGame
	}
	winner.Margin = margin
	winner.Opponent = loser.TeamName
	winner.Detail = winner.Detail + " win"

	if records.biggestBlowout == nil || margin > records.biggestBlowout.Margin {
		copyWinner := winner
		records.biggestBlowout = &copyWinner
	}
	if records.closestWin == nil || margin < records.closestWin.Margin {
		copyWinner := winner
		records.closestWin = &copyWinner
	}
}

func applyPlayoffResult(getPlayoffOwnerTotal func(string) *PlayoffOwnerTotal, matchup MatchupInput, homeGame, awayGame singleGameRecord) {
	switch matchupResultWinner(matchup) {
	case MatchupWinnerHome:
		getPlayoffOwnerTotal(homeGame.Owner).Wins++
		getPlayoffOwnerTotal(awayGame.Owner).Losses++
	case MatchupWinnerAway:
		getPlayoffOwnerTotal(awayGame.Owner).Wins++
		getPlayoffOwnerTotal(homeGame.Owner).Losses++
	}
}

func buildOverviewHighlightCards(records *recordBook, ownerTotals []OwnerTotal) []HighlightCard {
	highlightCards := buildRecordCards(records, map[string]string{
		"highest": "Highest weekly score",
		"lowest":  "Lowest weekly score",
		"blowout": "Biggest blowout",
		"closest": "Closest win",
	})

	if mostWins := findMostWinsLeader(ownerTotals); mostWins != nil {
		highlightCards = append(highlightCards, HighlightCard{Label: "All-time wins leader", Value: float64(mostWins.Wins), ValueText: "wins", Owner: mostWins.Owner, Detail: "All seasons combined"})
	}
	if mostPlayoffs := findMostPlayoffAppearancesLeader(ownerTotals); mostPlayoffs != nil {
		highlightCards = append(highlightCards, HighlightCard{Label: "Most playoff trips", Value: float64(mostPlayoffs.PlayoffAppearances), ValueText: "appearances", Owner: mostPlayoffs.Owner, Detail: "Any winners-bracket participation"})
	}
	if mostPointsFor := findMostPointsForLeader(ownerTotals); mostPointsFor != nil {
		highlightCards = append(highlightCards, HighlightCard{Label: "Most points scored", Value: mostPointsFor.PointsFor.Float64(), ValueText: "points", Owner: mostPointsFor.Owner, Detail: "All seasons combined"})
	}
	if bestAverage := findBestAveragePointsLeader(ownerTotals); bestAverage != nil {
		highlightCards = append(highlightCards, HighlightCard{Label: "Best avg season scoring", Value: bestAverage.AveragePointsFor, ValueText: "points per season", Owner: bestAverage.Owner, Detail: "Average points scored per season played"})
	}
	if mostPointsAgainst := findMostPointsAgainstLeader(ownerTotals); mostPointsAgainst != nil {
		highlightCards = append(highlightCards, HighlightCard{Label: "Most points allowed", Value: mostPointsAgainst.PointsAgainst.Float64(), ValueText: "points", Owner: mostPointsAgainst.Owner, Detail: "All seasons combined"})
	}
	if mostTitles := findMostTitlesLeader(ownerTotals); mostTitles != nil {
		highlightCards = append(highlightCards, HighlightCard{Label: "Most championships", Value: float64(mostTitles.Titles), ValueText: "titles", Owner: mostTitles.Owner, Detail: "Verified championship winners"})
	}

	return highlightCards
}

func buildPlayoffHighlightCards(records *recordBook, playoffOwnerTotals []PlayoffOwnerTotal) []HighlightCard {
	highlightCards := buildRecordCards(records, map[string]string{
		"highest": "Highest playoff score",
		"lowest":  "Lowest playoff score",
		"blowout": "Biggest playoff blowout",
		"closest": "Closest playoff win",
	})

	if mostWins := findMostPlayoffWinsLeader(playoffOwnerTotals); mostWins != nil {
		highlightCards = append(highlightCards, HighlightCard{Label: "Most playoff wins", Value: float64(mostWins.Wins), ValueText: "wins", Owner: mostWins.Owner, Detail: "Winners-bracket games only"})
	}
	if mostTitles := findMostPlayoffTitlesLeader(playoffOwnerTotals); mostTitles != nil {
		highlightCards = append(highlightCards, HighlightCard{Label: "Most postseason titles", Value: float64(mostTitles.Titles), ValueText: "titles", Owner: mostTitles.Owner, Detail: "Verified championship winners"})
	}
	if mostFinals := findMostFinalsAppearancesLeader(playoffOwnerTotals); mostFinals != nil {
		highlightCards = append(highlightCards, HighlightCard{Label: "Most finals appearances", Value: float64(mostFinals.FinalsAppearances), ValueText: "finals", Owner: mostFinals.Owner, Detail: "Championship game appearances"})
	}
	if bestConversion := findBestTitleConversionLeader(playoffOwnerTotals); bestConversion != nil {
		highlightCards = append(highlightCards, HighlightCard{Label: "Best title conversion", Value: bestConversion.TitleConversion * 100, ValueText: "% titles per finals", Owner: bestConversion.Owner, Detail: "Among owners with at least one finals appearance"})
	}

	return highlightCards
}

func buildChampionshipHighlightCards(records *recordBook) []HighlightCard {
	return buildRecordCards(records, map[string]string{
		"highest": "Highest championship score",
		"lowest":  "Lowest championship score",
		"blowout": "Biggest championship blowout",
		"closest": "Closest championship win",
	})
}

func buildRecordCards(records *recordBook, labels map[string]string) []HighlightCard {
	highlightCards := make([]HighlightCard, 0, 6)
	if records.highestScore != nil {
		highlightCards = append(highlightCards, HighlightCard{Label: labels["highest"], Value: records.highestScore.Score.Float64(), ValueText: "points", Owner: records.highestScore.Owner, TeamName: records.highestScore.TeamName, Opponent: records.highestScore.Opponent, Year: records.highestScore.Year, Week: records.highestScore.Week, Detail: records.highestScore.Detail})
	}
	if records.lowestScore != nil {
		highlightCards = append(highlightCards, HighlightCard{Label: labels["lowest"], Value: records.lowestScore.Score.Float64(), ValueText: "points", Owner: records.lowestScore.Owner, TeamName: records.lowestScore.TeamName, Opponent: records.lowestScore.Opponent, Year: records.lowestScore.Year, Week: records.lowestScore.Week, Detail: records.lowestScore.Detail})
	}
	if records.biggestBlowout != nil {
		highlightCards = append(highlightCards, HighlightCard{Label: labels["blowout"], Value: records.biggestBlowout.Margin.Float64(), ValueText: "point margin", Owner: records.biggestBlowout.Owner, TeamName: records.biggestBlowout.TeamName, Opponent: records.biggestBlowout.Opponent, Year: records.biggestBlowout.Year, Week: records.biggestBlowout.Week, Detail: records.biggestBlowout.Detail})
	}
	if records.closestWin != nil {
		highlightCards = append(highlightCards, HighlightCard{Label: labels["closest"], Value: records.closestWin.Margin.Float64(), ValueText: "point margin", Owner: records.closestWin.Owner, TeamName: records.closestWin.TeamName, Opponent: records.closestWin.Opponent, Year: records.closestWin.Year, Week: records.closestWin.Week, Detail: records.closestWin.Detail})
	}
	return highlightCards
}

func findChampionshipMatch(matchups []MatchupInput) *MatchupInput {
	var championship *MatchupInput
	for i := range matchups {
		matchup := &matchups[i]
		if matchup.HomePresent && matchup.AwayPresent && matchup.IsChampionship {
			if championship == nil || matchup.Week > championship.Week {
				championship = matchup
			}
		}
	}
	return championship
}

func collectPlayoffOwners(matchups []MatchupInput) map[string]struct{} {
	playoffOwners := make(map[string]struct{})
	for _, matchup := range matchups {
		if !matchup.IsPlayoff || matchup.MatchupType != "WINNERS_BRACKET" {
			continue
		}
		if matchup.HomePresent {
			if matchup.HomeOwner != "" {
				playoffOwners[matchup.HomeOwner] = struct{}{}
			}
		}
		if matchup.AwayPresent {
			if matchup.AwayOwner != "" {
				playoffOwners[matchup.AwayOwner] = struct{}{}
			}
		}
	}

	return playoffOwners
}

func championshipWinner(matchup MatchupInput) (winnerOwner, winnerTeam, loserTeam string, winnerScore, loserScore Points) {
	switch matchupResultWinner(matchup) {
	case MatchupWinnerHome:
		return matchup.HomeOwner, matchup.HomeTeamName, matchup.AwayTeamName, matchup.HomeScore, matchup.AwayScore
	case MatchupWinnerAway:
		return matchup.AwayOwner, matchup.AwayTeamName, matchup.HomeTeamName, matchup.AwayScore, matchup.HomeScore
	}
	return "", "", "", 0, 0
}

func matchupResultWinner(matchup MatchupInput) MatchupWinner {
	if matchup.IsChampionship {
		switch matchup.ChampionshipWinner {
		case MatchupWinnerHome, MatchupWinnerAway:
			return matchup.ChampionshipWinner
		case MatchupWinnerUnknown:
		default:
			return MatchupWinnerUnknown
		}
	}
	if matchup.HomeScore > matchup.AwayScore {
		return MatchupWinnerHome
	}
	if matchup.AwayScore > matchup.HomeScore {
		return MatchupWinnerAway
	}
	return MatchupWinnerUnknown
}

func formatGameType(isPlayoff bool, matchupType string) string {
	if !isPlayoff {
		return "Regular season"
	}
	if matchupType == "WINNERS_BRACKET" {
		return "Playoffs"
	}
	return strings.ReplaceAll(strings.ToLower(matchupType), "_", " ")
}

func findMostWinsLeader(ownerTotals []OwnerTotal) *OwnerTotal {
	if len(ownerTotals) == 0 {
		return nil
	}
	leader := ownerTotals[0]
	return &leader
}

func findMostTitlesLeader(ownerTotals []OwnerTotal) *OwnerTotal {
	if len(ownerTotals) == 0 {
		return nil
	}
	leader := ownerTotals[0]
	for _, total := range ownerTotals[1:] {
		if total.Titles > leader.Titles || (total.Titles == leader.Titles && total.Wins > leader.Wins) {
			leader = total
		}
	}
	return &leader
}

func findMostPlayoffAppearancesLeader(ownerTotals []OwnerTotal) *OwnerTotal {
	if len(ownerTotals) == 0 {
		return nil
	}
	leader := ownerTotals[0]
	for _, total := range ownerTotals[1:] {
		if total.PlayoffAppearances > leader.PlayoffAppearances || (total.PlayoffAppearances == leader.PlayoffAppearances && total.Wins > leader.Wins) {
			leader = total
		}
	}
	return &leader
}

func findMostPointsForLeader(ownerTotals []OwnerTotal) *OwnerTotal {
	if len(ownerTotals) == 0 {
		return nil
	}
	leader := ownerTotals[0]
	for _, total := range ownerTotals[1:] {
		if total.PointsFor > leader.PointsFor || (total.PointsFor == leader.PointsFor && total.WinPct > leader.WinPct) {
			leader = total
		}
	}
	return &leader
}

func findMostPointsAgainstLeader(ownerTotals []OwnerTotal) *OwnerTotal {
	if len(ownerTotals) == 0 {
		return nil
	}
	leader := ownerTotals[0]
	for _, total := range ownerTotals[1:] {
		if total.PointsAgainst > leader.PointsAgainst || (total.PointsAgainst == leader.PointsAgainst && total.Wins < leader.Wins) {
			leader = total
		}
	}
	return &leader
}

func findBestAveragePointsLeader(ownerTotals []OwnerTotal) *OwnerTotal {
	if len(ownerTotals) == 0 {
		return nil
	}
	var leader *OwnerTotal
	for i := range ownerTotals {
		total := ownerTotals[i]
		if total.Seasons == 0 {
			continue
		}
		if leader == nil || total.AveragePointsFor > leader.AveragePointsFor || (total.AveragePointsFor == leader.AveragePointsFor && total.Seasons > leader.Seasons) {
			copyTotal := total
			leader = &copyTotal
		}
	}
	return leader
}

func findMostPlayoffWinsLeader(playoffOwnerTotals []PlayoffOwnerTotal) *PlayoffOwnerTotal {
	if len(playoffOwnerTotals) == 0 {
		return nil
	}
	leader := playoffOwnerTotals[0]
	for _, total := range playoffOwnerTotals[1:] {
		if total.Wins > leader.Wins || (total.Wins == leader.Wins && total.Titles > leader.Titles) {
			leader = total
		}
	}
	return &leader
}

func findMostPlayoffTitlesLeader(playoffOwnerTotals []PlayoffOwnerTotal) *PlayoffOwnerTotal {
	if len(playoffOwnerTotals) == 0 {
		return nil
	}
	leader := playoffOwnerTotals[0]
	for _, total := range playoffOwnerTotals[1:] {
		if total.Titles > leader.Titles || (total.Titles == leader.Titles && total.Wins > leader.Wins) {
			leader = total
		}
	}
	return &leader
}

func findMostFinalsAppearancesLeader(playoffOwnerTotals []PlayoffOwnerTotal) *PlayoffOwnerTotal {
	if len(playoffOwnerTotals) == 0 {
		return nil
	}
	leader := playoffOwnerTotals[0]
	for _, total := range playoffOwnerTotals[1:] {
		if total.FinalsAppearances > leader.FinalsAppearances || (total.FinalsAppearances == leader.FinalsAppearances && total.Titles > leader.Titles) {
			leader = total
		}
	}
	return &leader
}

func findBestTitleConversionLeader(playoffOwnerTotals []PlayoffOwnerTotal) *PlayoffOwnerTotal {
	var leader *PlayoffOwnerTotal
	for i := range playoffOwnerTotals {
		total := playoffOwnerTotals[i]
		if total.FinalsAppearances == 0 {
			continue
		}
		if leader == nil || total.TitleConversion > leader.TitleConversion || (total.TitleConversion == leader.TitleConversion && total.Titles > leader.Titles) {
			copyTotal := total
			leader = &copyTotal
		}
	}
	return leader
}
