package archive

import (
	"context"
	"fmt"
	"sort"
	"strconv"
	"strings"

	"github.com/Robert-litts/fantasy-football-archive/internal/db"
	"github.com/Robert-litts/fantasy-football-archive/internal/sleeperdb"
)

type Provider string

const (
	ProviderESPN    Provider = "espn"
	ProviderSleeper Provider = "sleeper"
)

type LeagueSummary struct {
	Provider      Provider
	ID            int64
	ExternalID    string
	Season        int32
	Name          string
	TeamCount     int32
	Champion      string
	ChampionOwner string
	RunnerUp      string
	RunnerUpOwner string
}

type LeagueList struct {
	Leagues          []LeagueSummary
	SleeperAvailable bool
	SleeperMessage   string
}

type SeasonResultList struct {
	Seasons          []SeasonResult
	SleeperAvailable bool
	SleeperMessage   string
}

type SeasonResult struct {
	Provider      Provider
	Season        int32
	LeagueName    string
	TeamCount     int32
	Champion      string
	ChampionOwner string
	RunnerUp      string
	RunnerUpOwner string
}

type ESPNLeagueLister interface {
	GetLeaguesAsc(context.Context, db.GetLeaguesAscParams) ([]db.League, error)
}

type ESPNMatchupLister interface {
	GetMatchupsByLeagueId(context.Context, int32) ([]db.GetMatchupsByLeagueIdRow, error)
}

type SleeperLeagueReporter interface {
	ListLeagueReports(context.Context) ([]sleeperdb.ListLeagueReportsRow, error)
}

type SleeperTeamLister interface {
	ListTeamsByLeague(context.Context, int64) ([]sleeperdb.Team, error)
}

type Service struct {
	espn                ESPNLeagueLister
	espnMatchups        ESPNMatchupLister
	sleeper             SleeperLeagueReporter
	sleeperTeams        SleeperTeamLister
	ownerAliases        map[string]string
	mainSleeperLeagueID string
}

func New(espn ESPNLeagueLister, espnMatchups ESPNMatchupLister, sleeper SleeperLeagueReporter, sleeperTeams SleeperTeamLister, ownerAliases map[string]string, mainSleeperLeagueID string) *Service {
	return &Service{
		espn:                espn,
		espnMatchups:        espnMatchups,
		sleeper:             sleeper,
		sleeperTeams:        sleeperTeams,
		ownerAliases:        ownerAliases,
		mainSleeperLeagueID: strings.TrimSpace(mainSleeperLeagueID),
	}
}

func (s *Service) ListLeagueSummaries(ctx context.Context) (LeagueList, error) {
	return s.listLeagueSummaries(ctx, false)
}

func (s *Service) ListCanonicalLeagueSummaries(ctx context.Context) (LeagueList, error) {
	return s.listLeagueSummaries(ctx, true)
}

func (s *Service) ListSeasonResults(ctx context.Context) (SeasonResultList, error) {
	leagueList, err := s.ListCanonicalLeagueSummaries(ctx)
	if err != nil {
		return SeasonResultList{}, err
	}

	results := SeasonResultList{
		Seasons:          make([]SeasonResult, 0, len(leagueList.Leagues)),
		SleeperAvailable: leagueList.SleeperAvailable,
		SleeperMessage:   leagueList.SleeperMessage,
	}
	for _, league := range leagueList.Leagues {
		results.Seasons = append(results.Seasons, SeasonResult{
			Provider:      league.Provider,
			Season:        league.Season,
			LeagueName:    league.Name,
			TeamCount:     league.TeamCount,
			Champion:      league.Champion,
			ChampionOwner: league.ChampionOwner,
			RunnerUp:      league.RunnerUp,
			RunnerUpOwner: league.RunnerUpOwner,
		})
	}

	return results, nil
}

func (s *Service) listLeagueSummaries(ctx context.Context, canonicalOnly bool) (LeagueList, error) {
	result := LeagueList{
		Leagues: make([]LeagueSummary, 0),
	}

	if s == nil || s.espn == nil {
		return result, fmt.Errorf("archive service is not configured")
	}

	espnLeagues, err := s.espn.GetLeaguesAsc(ctx, defaultESPNLeagueParams())
	if err != nil {
		return result, err
	}
	for _, league := range espnLeagues {
		summary := LeagueSummary{
			Provider:   ProviderESPN,
			ID:         int64(league.ID),
			ExternalID: strconv.Itoa(int(league.LeagueId)),
			Season:     league.Year,
			Name:       fmt.Sprintf("ESPN %d", league.LeagueId),
			TeamCount:  league.TeamCount,
		}

		if s.espnMatchups != nil {
			if champion, championOwner, runnerUp, runnerUpOwner, ok, err := s.espnFinalists(ctx, league.ID); err != nil {
				return result, err
			} else if ok {
				summary.Champion = champion
				summary.ChampionOwner = championOwner
				summary.RunnerUp = runnerUp
				summary.RunnerUpOwner = runnerUpOwner
			}
		}

		result.Leagues = append(result.Leagues, summary)
	}

	if s.sleeper == nil {
		result.SleeperMessage = "Sleeper archive database is not configured"
		sortLeagueSummaries(result.Leagues)
		return result, nil
	}

	sleeperLeagues, err := s.sleeper.ListLeagueReports(ctx)
	if err != nil {
		result.SleeperMessage = "Sleeper archive database is temporarily unavailable"
		sortLeagueSummaries(result.Leagues)
		return result, nil
	}

	result.SleeperAvailable = true
	for _, league := range sleeperLeagues {
		if canonicalOnly && !s.includesMainSleeperLeague(league.CanonicalLeagueID) {
			continue
		}
		championOwner, runnerUpOwner := "", ""
		if s.sleeperTeams != nil {
			championOwner, runnerUpOwner = s.sleeperFinalists(ctx, league.LeagueID)
		}
		result.Leagues = append(result.Leagues, LeagueSummary{
			Provider:      ProviderSleeper,
			ID:            league.LeagueID,
			ExternalID:    league.SleeperLeagueID,
			Season:        league.Season,
			Name:          league.Name,
			TeamCount:     int32(league.TeamCount),
			Champion:      league.ChampionTeamName,
			ChampionOwner: championOwner,
			RunnerUp:      league.RunnerUpTeamName,
			RunnerUpOwner: runnerUpOwner,
		})
	}

	sortLeagueSummaries(result.Leagues)
	return result, nil
}

func (s *Service) includesMainSleeperLeague(canonicalLeagueID string) bool {
	canonicalLeagueID = strings.TrimSpace(canonicalLeagueID)
	if s.mainSleeperLeagueID == "" {
		return canonicalLeagueID != ""
	}
	return canonicalLeagueID == s.mainSleeperLeagueID
}

func (s *Service) espnFinalists(ctx context.Context, leagueID int32) (champion, championOwner, runnerUp, runnerUpOwner string, ok bool, err error) {
	matchups, err := s.espnMatchups.GetMatchupsByLeagueId(ctx, leagueID)
	if err != nil {
		return "", "", "", "", false, err
	}

	championship := findChampionshipMatch(matchups)
	if championship == nil {
		return "", "", "", "", false, nil
	}

	winnerOwner, winnerTeam, loserTeam, _, _ := championshipWinner(*championship)
	if winnerOwner == "" {
		return "", "", "", "", false, nil
	}

	return winnerTeam, s.normalizeOwner(winnerOwner), loserTeam, s.normalizeOwner(championshipLoserOwner(*championship)), true, nil
}

func (s *Service) sleeperFinalists(ctx context.Context, leagueID int64) (championOwner, runnerUpOwner string) {
	teams, err := s.sleeperTeams.ListTeamsByLeague(ctx, leagueID)
	if err != nil {
		return "", ""
	}
	for _, team := range teams {
		switch team.FinalStanding {
		case 1:
			championOwner = sleeperTeamOwnerLabel(team)
		case 2:
			runnerUpOwner = sleeperTeamOwnerLabel(team)
		}
	}
	return championOwner, runnerUpOwner
}

func defaultESPNLeagueParams() db.GetLeaguesAscParams {
	return db.GetLeaguesAscParams{
		Limit:       1000,
		Offset:      0,
		Column9:     "year",
		ID:          -1,
		LeagueId:    -1,
		Year:        -1,
		TeamCount:   -1,
		CurrentWeek: -1,
		NflWeek:     -1,
	}
}

func sortLeagueSummaries(leagues []LeagueSummary) {
	sort.SliceStable(leagues, func(i, j int) bool {
		if leagues[i].Season != leagues[j].Season {
			return leagues[i].Season < leagues[j].Season
		}
		if leagues[i].Provider != leagues[j].Provider {
			return leagues[i].Provider < leagues[j].Provider
		}
		if leagues[i].Name != leagues[j].Name {
			return leagues[i].Name < leagues[j].Name
		}
		if leagues[i].ExternalID != leagues[j].ExternalID {
			return leagues[i].ExternalID < leagues[j].ExternalID
		}
		return leagues[i].ID < leagues[j].ID
	})
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

func championshipLoserOwner(matchup db.GetMatchupsByLeagueIdRow) string {
	if matchup.HomeScore > matchup.AwayScore {
		return matchup.AwayTeamOwners
	}
	if matchup.AwayScore > matchup.HomeScore {
		return matchup.HomeTeamOwners
	}
	return ""
}

func (s *Service) normalizeOwner(owner string) string {
	if owner == "" {
		return ""
	}
	normalized := strings.Join(strings.Fields(strings.TrimSpace(owner)), " ")
	if canonical, ok := s.ownerAliases[normalized]; ok {
		return canonical
	}
	return normalized
}

func sleeperTeamOwnerLabel(team sleeperdb.Team) string {
	if name := strings.TrimSpace(team.DisplayName.String); name != "" {
		return name
	}
	if name := strings.TrimSpace(team.Username.String); name != "" {
		return name
	}
	return strings.TrimSpace(team.OwnerID)
}
