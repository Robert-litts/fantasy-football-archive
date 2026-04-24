package stats

import (
	"math"
	"sort"
	"strings"

	"github.com/Robert-litts/fantasy-football-archive/internal/db"
)

type PageData struct {
	SeasonCount              int
	OwnerCount               int
	MatchupCount             int
	HighlightCards           []HighlightCard
	OwnerTotals              []OwnerTotal
	RegularSeasonOwnerTotals []OwnerTotal
	BestRegularSeasons       []SeasonRecord
	PlayoffHighlightCards    []HighlightCard
	PlayoffOwnerTotals       []PlayoffOwnerTotal
	Champions                []ChampionRecord
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
	PointsFor          int
	PointsAgainst      int
	WinPct             float64
}

type PlayoffOwnerTotal struct {
	Rank        int
	Owner       string
	Appearances int
	Wins        int
	Losses      int
	Titles      int
	WinPct      float64
}

type SeasonRecord struct {
	Rank          int
	Owner         string
	Year          int
	Wins          int
	Losses        int
	Ties          int
	FinalStanding int
	PointsFor     int
	PointsAgainst int
	WinPct        float64
}

type ChampionRecord struct {
	Year         int
	Owner        string
	TeamName     string
	Opponent     string
	WinningScore float64
	LosingScore  float64
}

type singleGameRecord struct {
	Score    float64
	Margin   float64
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

func BuildPageData(leagues []db.GetAllLeaguesRow, teamsByLeague map[int32][]db.GetTeamsByLeagueYearRow, matchupsByLeague map[int32][]db.GetMatchupsByLeagueIdRow, ownerAliases map[string]string) PageData {
	ownerTotalsByName := make(map[string]*OwnerTotal)
	playoffTotalsByName := make(map[string]*PlayoffOwnerTotal)
	bestRegularSeasons := make([]SeasonRecord, 0)
	champions := make([]ChampionRecord, 0)
	allRecords := &recordBook{}
	playoffRecords := &recordBook{}
	matchupCount := 0

	getOwnerTotal := func(owner string) *OwnerTotal {
		normalizedOwner := normalizeOwner(owner, ownerAliases)
		if normalizedOwner == "" {
			normalizedOwner = "Unknown"
		}
		if total, ok := ownerTotalsByName[normalizedOwner]; ok {
			return total
		}
		total := &OwnerTotal{Owner: normalizedOwner}
		ownerTotalsByName[normalizedOwner] = total
		return total
	}

	getPlayoffOwnerTotal := func(owner string) *PlayoffOwnerTotal {
		normalizedOwner := normalizeOwner(owner, ownerAliases)
		if normalizedOwner == "" {
			normalizedOwner = "Unknown"
		}
		if total, ok := playoffTotalsByName[normalizedOwner]; ok {
			return total
		}
		total := &PlayoffOwnerTotal{Owner: normalizedOwner}
		playoffTotalsByName[normalizedOwner] = total
		return total
	}

	for _, league := range leagues {
		teams := teamsByLeague[league.ID]
		for _, team := range teams {
			total := getOwnerTotal(team.Owners)
			total.Seasons++
			total.Wins += int(team.Wins)
			total.Losses += int(team.Losses)
			total.Ties += int(team.Ties)
			total.PointsFor += int(team.PointsFor)
			total.PointsAgainst += int(team.PointsAgainst)

			bestRegularSeasons = append(bestRegularSeasons, SeasonRecord{
				Owner:         total.Owner,
				Year:          int(league.Year),
				Wins:          int(team.Wins),
				Losses:        int(team.Losses),
				Ties:          int(team.Ties),
				FinalStanding: int(team.FinalStanding),
				PointsFor:     int(team.PointsFor),
				PointsAgainst: int(team.PointsAgainst),
				WinPct:        calculateWinPct(int(team.Wins), int(team.Losses), int(team.Ties)),
			})
		}

		matchups := matchupsByLeague[league.ID]
		for owner := range collectPlayoffOwners(matchups, ownerAliases) {
			getOwnerTotal(owner).PlayoffAppearances++
			getPlayoffOwnerTotal(owner).Appearances++
		}

		if championship := findChampionshipMatch(matchups); championship != nil {
			winnerOwner, winnerTeam, loserTeam, winnerScore, loserScore := championshipWinner(*championship)
			if winnerOwner != "" {
				getOwnerTotal(winnerOwner).Titles++
				getPlayoffOwnerTotal(winnerOwner).Titles++
				champions = append(champions, ChampionRecord{
					Year:         int(championship.LeagueYear),
					Owner:        normalizeOwner(winnerOwner, ownerAliases),
					TeamName:     winnerTeam,
					Opponent:     loserTeam,
					WinningScore: winnerScore,
					LosingScore:  loserScore,
				})
			}
		}

		for _, matchup := range matchups {
			if !matchup.HomeTeamID.Valid || !matchup.AwayTeamID.Valid {
				continue
			}

			matchupCount++
			homeGame, awayGame := buildSingleGameRecords(matchup, ownerAliases)
			updateRecordBook(allRecords, homeGame, awayGame)

			if matchup.IsPlayoff && matchup.MatchupType == "WINNERS_BRACKET" {
				updateRecordBook(playoffRecords, homeGame, awayGame)
				applyPlayoffResult(getPlayoffOwnerTotal, homeGame, awayGame)
			}
		}
	}

	ownerTotals := make([]OwnerTotal, 0, len(ownerTotalsByName))
	for _, total := range ownerTotalsByName {
		total.WinPct = calculateWinPct(total.Wins, total.Losses, total.Ties)
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
		SeasonCount:              len(leagues),
		OwnerCount:               len(ownerTotals),
		MatchupCount:             matchupCount,
		HighlightCards:           buildOverviewHighlightCards(allRecords, ownerTotals),
		OwnerTotals:              ownerTotals,
		RegularSeasonOwnerTotals: regularSeasonOwnerTotals,
		BestRegularSeasons:       bestRegularSeasons,
		PlayoffHighlightCards:    buildPlayoffHighlightCards(playoffRecords, playoffOwnerTotals),
		PlayoffOwnerTotals:       playoffOwnerTotals,
		Champions:                champions,
	}
}

func normalizeOwner(owner string, ownerAliases map[string]string) string {
	normalized := strings.Join(strings.Fields(strings.TrimSpace(owner)), " ")
	if canonical, ok := ownerAliases[normalized]; ok {
		return canonical
	}
	return normalized
}

func calculateWinPct(wins, losses, ties int) float64 {
	totalGames := wins + losses + ties
	if totalGames == 0 {
		return 0
	}
	return (float64(wins) + float64(ties)*0.5) / float64(totalGames)
}

func buildSingleGameRecords(matchup db.GetMatchupsByLeagueIdRow, ownerAliases map[string]string) (singleGameRecord, singleGameRecord) {
	homeGame := singleGameRecord{
		Score:    matchup.HomeScore,
		Owner:    normalizeOwner(matchup.HomeTeamOwners, ownerAliases),
		TeamName: matchup.HomeTeamName,
		Opponent: matchup.AwayTeamName,
		Year:     int(matchup.LeagueYear),
		Week:     int(matchup.Week),
		Detail:   formatGameType(matchup.IsPlayoff, matchup.MatchupType),
	}
	awayGame := singleGameRecord{
		Score:    matchup.AwayScore,
		Owner:    normalizeOwner(matchup.AwayTeamOwners, ownerAliases),
		TeamName: matchup.AwayTeamName,
		Opponent: matchup.HomeTeamName,
		Year:     int(matchup.LeagueYear),
		Week:     int(matchup.Week),
		Detail:   formatGameType(matchup.IsPlayoff, matchup.MatchupType),
	}
	return homeGame, awayGame
}

func updateRecordBook(records *recordBook, homeGame, awayGame singleGameRecord) {
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
	if homeGame.Score == awayGame.Score {
		return
	}

	margin := math.Abs(homeGame.Score - awayGame.Score)
	winner := homeGame
	loser := awayGame
	if awayGame.Score > homeGame.Score {
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

func applyPlayoffResult(getPlayoffOwnerTotal func(string) *PlayoffOwnerTotal, homeGame, awayGame singleGameRecord) {
	if homeGame.Score == awayGame.Score {
		return
	}
	if homeGame.Score > awayGame.Score {
		getPlayoffOwnerTotal(homeGame.Owner).Wins++
		getPlayoffOwnerTotal(awayGame.Owner).Losses++
		return
	}
	getPlayoffOwnerTotal(awayGame.Owner).Wins++
	getPlayoffOwnerTotal(homeGame.Owner).Losses++
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
		highlightCards = append(highlightCards, HighlightCard{Label: "Most playoff trips", Value: float64(mostPlayoffs.PlayoffAppearances), ValueText: "appearances", Owner: mostPlayoffs.Owner, Detail: "First-week winners-bracket appearances"})
	}
	if mostPointsFor := findMostPointsForLeader(ownerTotals); mostPointsFor != nil {
		highlightCards = append(highlightCards, HighlightCard{Label: "Most points scored", Value: float64(mostPointsFor.PointsFor), ValueText: "points", Owner: mostPointsFor.Owner, Detail: "All seasons combined"})
	}
	if mostPointsAgainst := findMostPointsAgainstLeader(ownerTotals); mostPointsAgainst != nil {
		highlightCards = append(highlightCards, HighlightCard{Label: "Most points allowed", Value: float64(mostPointsAgainst.PointsAgainst), ValueText: "points", Owner: mostPointsAgainst.Owner, Detail: "All seasons combined"})
	}
	if mostTitles := findMostTitlesLeader(ownerTotals); mostTitles != nil {
		highlightCards = append(highlightCards, HighlightCard{Label: "Most championships", Value: float64(mostTitles.Titles), ValueText: "titles", Owner: mostTitles.Owner, Detail: "Winner of the final winners-bracket matchup"})
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
		highlightCards = append(highlightCards, HighlightCard{Label: "Most postseason titles", Value: float64(mostTitles.Titles), ValueText: "titles", Owner: mostTitles.Owner, Detail: "Winners of the final winners-bracket matchup"})
	}

	return highlightCards
}

func buildRecordCards(records *recordBook, labels map[string]string) []HighlightCard {
	highlightCards := make([]HighlightCard, 0, 6)
	if records.highestScore != nil {
		highlightCards = append(highlightCards, HighlightCard{Label: labels["highest"], Value: records.highestScore.Score, ValueText: "points", Owner: records.highestScore.Owner, TeamName: records.highestScore.TeamName, Opponent: records.highestScore.Opponent, Year: records.highestScore.Year, Week: records.highestScore.Week, Detail: records.highestScore.Detail})
	}
	if records.lowestScore != nil {
		highlightCards = append(highlightCards, HighlightCard{Label: labels["lowest"], Value: records.lowestScore.Score, ValueText: "points", Owner: records.lowestScore.Owner, TeamName: records.lowestScore.TeamName, Opponent: records.lowestScore.Opponent, Year: records.lowestScore.Year, Week: records.lowestScore.Week, Detail: records.lowestScore.Detail})
	}
	if records.biggestBlowout != nil {
		highlightCards = append(highlightCards, HighlightCard{Label: labels["blowout"], Value: records.biggestBlowout.Margin, ValueText: "point margin", Owner: records.biggestBlowout.Owner, TeamName: records.biggestBlowout.TeamName, Opponent: records.biggestBlowout.Opponent, Year: records.biggestBlowout.Year, Week: records.biggestBlowout.Week, Detail: records.biggestBlowout.Detail})
	}
	if records.closestWin != nil {
		highlightCards = append(highlightCards, HighlightCard{Label: labels["closest"], Value: records.closestWin.Margin, ValueText: "point margin", Owner: records.closestWin.Owner, TeamName: records.closestWin.TeamName, Opponent: records.closestWin.Opponent, Year: records.closestWin.Year, Week: records.closestWin.Week, Detail: records.closestWin.Detail})
	}
	return highlightCards
}

func findChampionshipMatch(matchups []db.GetMatchupsByLeagueIdRow) *db.GetMatchupsByLeagueIdRow {
	var championship *db.GetMatchupsByLeagueIdRow
	for i := range matchups {
		matchup := &matchups[i]
		if !matchup.HomeTeamID.Valid || !matchup.AwayTeamID.Valid {
			continue
		}
		if !matchup.IsPlayoff || matchup.MatchupType != "WINNERS_BRACKET" {
			continue
		}
		if championship == nil || matchup.Week > championship.Week {
			championship = matchup
		}
	}
	return championship
}

func collectPlayoffOwners(matchups []db.GetMatchupsByLeagueIdRow, ownerAliases map[string]string) map[string]struct{} {
	playoffOwners := make(map[string]struct{})
	firstPlayoffWeek, ok := findFirstPlayoffWeek(matchups)
	if !ok {
		return playoffOwners
	}

	for _, matchup := range matchups {
		if !matchup.IsPlayoff || matchup.Week != firstPlayoffWeek || matchup.MatchupType != "WINNERS_BRACKET" {
			continue
		}
		if matchup.HomeTeamID.Valid {
			if owner := normalizeOwner(matchup.HomeTeamOwners, ownerAliases); owner != "" {
				playoffOwners[owner] = struct{}{}
			}
		}
		if matchup.AwayTeamID.Valid {
			if owner := normalizeOwner(matchup.AwayTeamOwners, ownerAliases); owner != "" {
				playoffOwners[owner] = struct{}{}
			}
		}
	}

	return playoffOwners
}

func findFirstPlayoffWeek(matchups []db.GetMatchupsByLeagueIdRow) (int32, bool) {
	var firstPlayoffWeek int32
	found := false
	for _, matchup := range matchups {
		if !matchup.IsPlayoff {
			continue
		}
		if !found || matchup.Week < firstPlayoffWeek {
			firstPlayoffWeek = matchup.Week
			found = true
		}
	}
	return firstPlayoffWeek, found
}

func championshipWinner(matchup db.GetMatchupsByLeagueIdRow) (winnerOwner, winnerTeam, loserTeam string, winnerScore, loserScore float64) {
	if matchup.HomeScore > matchup.AwayScore {
		return matchup.HomeTeamOwners, matchup.HomeTeamName, matchup.AwayTeamName, matchup.HomeScore, matchup.AwayScore
	}
	if matchup.AwayScore > matchup.HomeScore {
		return matchup.AwayTeamOwners, matchup.AwayTeamName, matchup.HomeTeamName, matchup.AwayScore, matchup.HomeScore
	}
	return "", "", "", 0, 0
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
