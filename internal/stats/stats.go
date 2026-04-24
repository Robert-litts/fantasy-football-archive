package stats

import (
	"math"
	"sort"
	"strings"

	"github.com/Robert-litts/fantasy-football-archive/internal/db"
)

type PageData struct {
	SeasonCount        int
	OwnerCount         int
	MatchupCount       int
	HighlightCards     []HighlightCard
	OwnerTotals        []OwnerTotal
	BestRegularSeasons []SeasonRecord
	Champions          []ChampionRecord
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

func BuildPageData(leagues []db.GetAllLeaguesRow, teamsByLeague map[int32][]db.GetTeamsByLeagueYearRow, matchupsByLeague map[int32][]db.GetMatchupsByLeagueIdRow, ownerAliases map[string]string) PageData {
	ownerTotalsByName := make(map[string]*OwnerTotal)
	bestRegularSeasons := make([]SeasonRecord, 0)
	champions := make([]ChampionRecord, 0)
	var highestScore *singleGameRecord
	var biggestBlowout *singleGameRecord
	var closestWin *singleGameRecord
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

		playoffOwners := make(map[string]struct{})
		matchups := matchupsByLeague[league.ID]
		if championship := findChampionshipMatch(matchups); championship != nil {
			winnerOwner, winnerTeam, loserTeam, winnerScore, loserScore := championshipWinner(*championship)
			if winnerOwner != "" {
				getOwnerTotal(winnerOwner).Titles++
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
			if matchup.IsPlayoff {
				if owner := normalizeOwner(matchup.HomeTeamOwners, ownerAliases); owner != "" {
					playoffOwners[owner] = struct{}{}
				}
				if owner := normalizeOwner(matchup.AwayTeamOwners, ownerAliases); owner != "" {
					playoffOwners[owner] = struct{}{}
				}
			}

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

			if highestScore == nil || homeGame.Score > highestScore.Score {
				highestScore = &homeGame
			}
			if highestScore == nil || awayGame.Score > highestScore.Score {
				highestScore = &awayGame
			}

			if matchup.HomeScore == matchup.AwayScore {
				continue
			}

			margin := math.Abs(matchup.HomeScore - matchup.AwayScore)
			winner := homeGame
			loser := awayGame
			if matchup.AwayScore > matchup.HomeScore {
				winner = awayGame
				loser = homeGame
			}

			winner.Margin = margin
			winner.Opponent = loser.TeamName
			winner.Detail = winner.Detail + " win"

			if biggestBlowout == nil || margin > biggestBlowout.Margin {
				copyWinner := winner
				biggestBlowout = &copyWinner
			}
			if closestWin == nil || margin < closestWin.Margin {
				copyWinner := winner
				closestWin = &copyWinner
			}
		}

		for owner := range playoffOwners {
			getOwnerTotal(owner).PlayoffAppearances++
		}
	}

	ownerTotals := make([]OwnerTotal, 0, len(ownerTotalsByName))
	for _, total := range ownerTotalsByName {
		total.WinPct = calculateWinPct(total.Wins, total.Losses, total.Ties)
		ownerTotals = append(ownerTotals, *total)
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

	highlightCards := make([]HighlightCard, 0, 5)
	if highestScore != nil {
		highlightCards = append(highlightCards, HighlightCard{
			Label:     "Highest weekly score",
			Value:     highestScore.Score,
			ValueText: "points",
			Owner:     highestScore.Owner,
			TeamName:  highestScore.TeamName,
			Opponent:  highestScore.Opponent,
			Year:      highestScore.Year,
			Week:      highestScore.Week,
			Detail:    highestScore.Detail,
		})
	}
	if biggestBlowout != nil {
		highlightCards = append(highlightCards, HighlightCard{
			Label:     "Biggest blowout",
			Value:     biggestBlowout.Margin,
			ValueText: "point margin",
			Owner:     biggestBlowout.Owner,
			TeamName:  biggestBlowout.TeamName,
			Opponent:  biggestBlowout.Opponent,
			Year:      biggestBlowout.Year,
			Week:      biggestBlowout.Week,
			Detail:    biggestBlowout.Detail,
		})
	}
	if closestWin != nil {
		highlightCards = append(highlightCards, HighlightCard{
			Label:     "Closest win",
			Value:     closestWin.Margin,
			ValueText: "point margin",
			Owner:     closestWin.Owner,
			TeamName:  closestWin.TeamName,
			Opponent:  closestWin.Opponent,
			Year:      closestWin.Year,
			Week:      closestWin.Week,
			Detail:    closestWin.Detail,
		})
	}
	if mostWins := findMostWinsLeader(ownerTotals); mostWins != nil {
		highlightCards = append(highlightCards, HighlightCard{
			Label:     "All-time wins leader",
			Value:     float64(mostWins.Wins),
			ValueText: "wins",
			Owner:     mostWins.Owner,
			Detail:    "All seasons combined",
		})
	}
	if mostTitles := findMostTitlesLeader(ownerTotals); mostTitles != nil {
		highlightCards = append(highlightCards, HighlightCard{
			Label:     "Most championships",
			Value:     float64(mostTitles.Titles),
			ValueText: "titles",
			Owner:     mostTitles.Owner,
			Detail:    "Winner of the final winners-bracket matchup",
		})
	}

	return PageData{
		SeasonCount:        len(leagues),
		OwnerCount:         len(ownerTotals),
		MatchupCount:       matchupCount,
		HighlightCards:     highlightCards,
		OwnerTotals:        ownerTotals,
		BestRegularSeasons: bestRegularSeasons,
		Champions:          champions,
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
