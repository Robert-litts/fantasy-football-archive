package main

import (
	"context"
	"database/sql"
	"errors"
	"fmt"
	"net/http"
	"sort"
	"strconv"
	"strings"

	"github.com/Robert-litts/fantasy-football-archive/internal/archive"
	"github.com/Robert-litts/fantasy-football-archive/internal/db"
	matchupsview "github.com/Robert-litts/fantasy-football-archive/internal/matchupsview"
	"github.com/Robert-litts/fantasy-football-archive/internal/sleeperdb"
	"github.com/Robert-litts/fantasy-football-archive/templates"
)

type matchupsArchiveLister interface {
	ListLeagueSummaries(context.Context) (archive.LeagueList, error)
}

type matchupsESPNLister interface {
	GetMatchupsByLeagueId(context.Context, int32) ([]db.GetMatchupsByLeagueIdRow, error)
}

type matchupsSleeperLister interface {
	ListMatchupsByLeague(context.Context, int64) ([]sleeperdb.Matchup, error)
}

type matchupsSleeperTeamLister interface {
	ListTeamsByLeague(context.Context, int64) ([]sleeperdb.Team, error)
}

type matchupsSleeperBracketLister interface {
	ListPlayoffBracketMatchupsByLeague(context.Context, int64) ([]sleeperdb.PlayoffBracketMatchup, error)
}

var errInvalidMatchupsQuery = errors.New("invalid query parameters")

func (app *application) apiListLeagueMatchupsHandler(w http.ResponseWriter, r *http.Request) {
	id, err := app.readIDParam(r)
	if err != nil {
		app.notFoundResponse(w, r)
		return
	}

	matchups, err := app.queries.GetMatchupsByLeagueId(r.Context(), int32(id))
	if err != nil {
		app.logger.Error("database error", "error", err)
		if err == sql.ErrNoRows {
			app.notFoundResponse(w, r)
			return
		}
		app.serverErrorResponse(w, r, err)
		return
	}

	err = app.writeJSON(w, http.StatusOK, envelope{"matchups": matchups}, nil)
	if err != nil {
		app.serverErrorResponse(w, r, err)
	}
}

func (app *application) matchupTableHandler(w http.ResponseWriter, r *http.Request) {
	page, err := app.matchupsPageData(r, 0)
	if err != nil {
		app.handleMatchupsPageError(w, r, err)
		return
	}

	if r.Header.Get("HX-Request") == "true" {
		if err := templates.MatchupsContent(page).Render(r.Context(), w); err != nil {
			app.serverErrorResponse(w, r, err)
		}
		return
	}

	if err := templates.Base(templates.Matchups(page)).Render(r.Context(), w); err != nil {
		app.serverErrorResponse(w, r, err)
	}
}

func (app *application) appMatchupsPageHandler(w http.ResponseWriter, r *http.Request) {
	page, err := app.matchupsPageData(r, 0)
	if err != nil {
		app.handleMatchupsPageError(w, r, err)
		return
	}

	if err := templates.Matchups(page).Render(r.Context(), w); err != nil {
		app.serverErrorResponse(w, r, err)
	}
}

func (app *application) appMatchupsTableFragmentHandler(w http.ResponseWriter, r *http.Request) {
	page, err := app.matchupsPageData(r, 0)
	if err != nil {
		app.handleMatchupsPageError(w, r, err)
		return
	}

	if err := templates.MatchupsContent(page).Render(r.Context(), w); err != nil {
		app.serverErrorResponse(w, r, err)
	}
}

func (app *application) matchupWeekHandler(w http.ResponseWriter, r *http.Request) {
	week, err := app.readWeekParam(r)
	if err != nil {
		app.notFoundResponse(w, r)
		return
	}

	page, err := app.matchupsPageData(r, int32(week))
	if err != nil {
		app.handleMatchupsPageError(w, r, err)
		return
	}

	if r.Header.Get("HX-Request") == "true" {
		if err := templates.WeekTable(page.SelectedWeekRows).Render(r.Context(), w); err != nil {
			app.serverErrorResponse(w, r, err)
		}
		return
	}

	if err := templates.Base(templates.Matchups(page)).Render(r.Context(), w); err != nil {
		app.serverErrorResponse(w, r, err)
	}
}

func (app *application) appMatchupsWeekFragmentHandler(w http.ResponseWriter, r *http.Request) {
	week, err := app.readWeekParam(r)
	if err != nil {
		app.notFoundResponse(w, r)
		return
	}

	page, err := app.matchupsPageData(r, int32(week))
	if err != nil {
		app.handleMatchupsPageError(w, r, err)
		return
	}

	if err := templates.WeekTable(page.SelectedWeekRows).Render(r.Context(), w); err != nil {
		app.serverErrorResponse(w, r, err)
	}
}

func (app *application) matchupsPageData(r *http.Request, weekOverride int32) (matchupsview.PageData, error) {
	selectedLeagueKey := strings.TrimSpace(r.URL.Query().Get("id"))
	if selectedLeagueKey != "" {
		if _, _, err := parseArchiveLeagueSelectionKey(selectedLeagueKey); err != nil {
			return matchupsview.PageData{}, errInvalidMatchupsQuery
		}
	}

	selectedWeek := weekOverride
	if selectedWeek == 0 {
		weekValue := strings.TrimSpace(r.URL.Query().Get("week"))
		if weekValue != "" {
			week, err := strconv.ParseInt(weekValue, 10, 32)
			if err != nil || week < 1 {
				return matchupsview.PageData{}, errInvalidMatchupsQuery
			}
			selectedWeek = int32(week)
		}
	}

	return buildMatchupsPageData(
		r.Context(),
		app.archive,
		app.queries,
		app.sleeperQueries,
		app.sleeperQueries,
		app.sleeperQueries,
		selectedLeagueKey,
		selectedWeek,
	)
}

func (app *application) handleMatchupsPageError(w http.ResponseWriter, r *http.Request, err error) {
	if errors.Is(err, errInvalidMatchupsQuery) {
		app.badRequestResponse(w, r, err)
		return
	}
	app.serverErrorResponse(w, r, err)
}

func buildMatchupsPageData(
	ctx context.Context,
	archiveLister matchupsArchiveLister,
	espnLister matchupsESPNLister,
	sleeperLister matchupsSleeperLister,
	sleeperTeamLister matchupsSleeperTeamLister,
	sleeperBracketLister matchupsSleeperBracketLister,
	selectedLeagueKey string,
	selectedWeek int32,
) (matchupsview.PageData, error) {
	page := matchupsview.PageData{}

	if archiveLister == nil {
		return page, sql.ErrConnDone
	}

	leagueList, err := archiveLister.ListLeagueSummaries(ctx)
	if err != nil {
		return page, err
	}

	page.Leagues = leagueList.Leagues
	page.SleeperAvailable = leagueList.SleeperAvailable
	page.SleeperMessage = leagueList.SleeperMessage

	if len(page.Leagues) == 0 {
		return page, nil
	}

	selected := page.Leagues[0]
	if selectedLeagueKey != "" {
		if found, ok := findLeagueSummaryByKey(page.Leagues, selectedLeagueKey); ok {
			selected = found
		}
	}

	page.SelectedLeague = selected
	page.SelectedLeagueKey = archiveLeagueSelectionKey(selected)

	matchups, sleeperMessage, err := loadMatchupsForLeague(ctx, selected, espnLister, sleeperLister, sleeperTeamLister, sleeperBracketLister)
	if sleeperMessage != "" {
		page.SleeperMessage = sleeperMessage
	}
	if err != nil {
		return page, err
	}

	page.Matchups = matchups
	page.Weeks = buildMatchupWeekTabs(matchups)
	page.ActiveWeek = selectedWeek
	if page.ActiveWeek == 0 && len(page.Weeks) > 0 {
		page.ActiveWeek = page.Weeks[0].Week
	}
	page.SelectedWeekRows = filterMatchupsByWeek(matchups, page.ActiveWeek)
	page.SelectedWeekLoaded = page.ActiveWeek > 0

	return page, nil
}

func loadMatchupsForLeague(
	ctx context.Context,
	league archive.LeagueSummary,
	espnLister matchupsESPNLister,
	sleeperLister matchupsSleeperLister,
	sleeperTeamLister matchupsSleeperTeamLister,
	sleeperBracketLister matchupsSleeperBracketLister,
) ([]matchupsview.MatchupRow, string, error) {
	switch league.Provider {
	case archive.ProviderESPN:
		if espnLister == nil {
			return nil, "", sql.ErrConnDone
		}

		rows, err := espnLister.GetMatchupsByLeagueId(ctx, int32(league.ID))
		if err != nil {
			if errors.Is(err, sql.ErrNoRows) {
				return nil, "", nil
			}
			return nil, "", err
		}
		return normalizeESPNMatchups(rows), "", nil

	case archive.ProviderSleeper:
		if sleeperLister == nil || sleeperTeamLister == nil {
			return nil, "Sleeper archive database is not configured", nil
		}

		matchups, err := sleeperLister.ListMatchupsByLeague(ctx, league.ID)
		if err != nil {
			if errors.Is(err, sql.ErrNoRows) {
				return nil, "", nil
			}
			return nil, "Sleeper matchup data is temporarily unavailable", nil
		}

		teams, err := sleeperTeamLister.ListTeamsByLeague(ctx, league.ID)
		if err != nil && !errors.Is(err, sql.ErrNoRows) {
			return nil, "Sleeper team labels are temporarily unavailable", nil
		}

		var brackets []sleeperdb.PlayoffBracketMatchup
		if sleeperBracketLister != nil {
			brackets, err = sleeperBracketLister.ListPlayoffBracketMatchupsByLeague(ctx, league.ID)
			if err != nil && !errors.Is(err, sql.ErrNoRows) {
				brackets = nil
			}
		}

		return normalizeSleeperMatchups(matchups, teams, brackets), "", nil
	default:
		return nil, "", fmt.Errorf("unsupported league provider %q", league.Provider)
	}
}

func normalizeESPNMatchups(rows []db.GetMatchupsByLeagueIdRow) []matchupsview.MatchupRow {
	lastWeek := lastESPNWeek(rows)
	matchups := make([]matchupsview.MatchupRow, 0, len(rows))

	for _, row := range rows {
		homePresent := row.HomeTeamID.Valid
		awayPresent := row.AwayTeamID.Valid
		homeWinner := homePresent && awayPresent && row.HomeScore > row.AwayScore
		awayWinner := homePresent && awayPresent && row.AwayScore > row.HomeScore
		isChampionship := row.IsPlayoff && row.Week == lastWeek && row.MatchupType == "WINNERS_BRACKET"

		matchups = append(matchups, matchupsview.MatchupRow{
			Week:           row.Week,
			HomeTeamName:   fallback(row.HomeTeamName, "BYE"),
			HomeOwner:      strings.TrimSpace(row.HomeTeamOwners),
			HomeScore:      formatFloatScore(row.HomeScore),
			HomePresent:    homePresent,
			HomeWinner:     homeWinner,
			AwayTeamName:   fallback(row.AwayTeamName, "BYE"),
			AwayOwner:      strings.TrimSpace(row.AwayTeamOwners),
			AwayScore:      formatFloatScore(row.AwayScore),
			AwayPresent:    awayPresent,
			AwayWinner:     awayWinner,
			IsPlayoff:      row.IsPlayoff,
			IsChampionship: isChampionship,
			MatchupType:    row.MatchupType,
			TypeLabel:      matchupTypeLabel(row.IsPlayoff, isChampionship, row.MatchupType, row.Week, lastWeek, homePresent && awayPresent),
		})
	}

	return matchups
}

func normalizeSleeperMatchups(rows []sleeperdb.Matchup, teams []sleeperdb.Team, brackets []sleeperdb.PlayoffBracketMatchup) []matchupsview.MatchupRow {
	teamsByRosterID := make(map[int32]sleeperdb.Team, len(teams))
	for _, team := range teams {
		teamsByRosterID[team.RosterID] = team
	}

	championshipPairs := sleeperChampionshipRosterPairs(brackets)
	rowsByKey := make(map[string]sleeperdb.Matchup, len(rows))
	for _, row := range rows {
		rowsByKey[sleeperMatchupRosterKey(row.Week, row.MatchupID, row.RosterID)] = row
	}

	handled := make(map[string]bool, len(rows))
	matchups := make([]matchupsview.MatchupRow, 0, len(rows)/2)
	for _, row := range rows {
		rowKey := sleeperMatchupRosterKey(row.Week, row.MatchupID, row.RosterID)
		if handled[rowKey] {
			continue
		}

		var opponent sleeperdb.Matchup
		opponentPresent := false
		if row.OpponentRosterID.Valid {
			if found, ok := rowsByKey[sleeperMatchupRosterKey(row.Week, row.MatchupID, row.OpponentRosterID.Int32)]; ok {
				opponent = found
				opponentPresent = true
			}
		}
		if !opponentPresent && row.MatchupID > 0 {
			for _, candidate := range rows {
				if candidate.Week == row.Week && candidate.MatchupID == row.MatchupID && candidate.RosterID != row.RosterID {
					opponent = candidate
					opponentPresent = true
					break
				}
			}
		}

		home := row
		away := opponent
		awayPresent := opponentPresent
		if opponentPresent && opponent.RosterID < row.RosterID {
			home = opponent
			away = row
		}

		if opponentPresent {
			handled[sleeperMatchupRosterKey(opponent.Week, opponent.MatchupID, opponent.RosterID)] = true
		}
		handled[rowKey] = true
		if !opponentPresent && home.MatchupID == 0 {
			continue
		}

		homeTeam := teamsByRosterID[home.RosterID]
		awayTeam := teamsByRosterID[away.RosterID]
		homeScore, awayScore := sleeperScore(home), sleeperScore(away)
		homeWinner := awayPresent && compareScoreStrings(homeScore, awayScore) > 0
		awayWinner := awayPresent && compareScoreStrings(awayScore, homeScore) > 0

		matchups = append(matchups, matchupsview.MatchupRow{
			Week:         home.Week,
			HomeTeamName: sleeperMatchupTeamLabel(homeTeam, home.RosterID),
			HomeOwner:    sleeperTeamOwnerLabel(homeTeam),
			HomeScore:    homeScore,
			HomeRosterID: home.RosterID,
			HomePresent:  true,
			HomeWinner:   homeWinner,
			AwayTeamName: sleeperAwayTeamName(awayTeam, away, awayPresent),
			AwayOwner:    sleeperAwayOwner(awayTeam, awayPresent),
			AwayScore:    awayScore,
			AwayRosterID: away.RosterID,
			AwayPresent:  awayPresent,
			AwayWinner:   awayWinner,
			IsPlayoff:    home.IsPlayoff,
			MatchupType:  home.MatchupType,
		})
	}

	matchups = filterSleeperInactiveWeeks(matchups)
	finalizeSleeperMatchupLabels(matchups, championshipPairs)

	sort.Slice(matchups, func(i, j int) bool {
		if matchups[i].Week != matchups[j].Week {
			return matchups[i].Week < matchups[j].Week
		}
		return matchups[i].HomeTeamName < matchups[j].HomeTeamName
	})

	return matchups
}

func filterSleeperInactiveWeeks(matchups []matchupsview.MatchupRow) []matchupsview.MatchupRow {
	hasPlayedMatchupByWeek := make(map[int32]bool)
	for _, matchup := range matchups {
		if matchup.HomePresent && matchup.AwayPresent {
			hasPlayedMatchupByWeek[matchup.Week] = true
		}
	}

	filtered := make([]matchupsview.MatchupRow, 0, len(matchups))
	for _, matchup := range matchups {
		if hasPlayedMatchupByWeek[matchup.Week] {
			filtered = append(filtered, matchup)
		}
	}
	return filtered
}

func finalizeSleeperMatchupLabels(matchups []matchupsview.MatchupRow, championshipPairs map[string]bool) {
	lastWeek := lastMatchupRowWeek(matchups)
	hasChampionshipPairs := len(championshipPairs) > 0

	for i := range matchups {
		matchup := &matchups[i]
		isChampionship := false
		if matchup.HomePresent && matchup.AwayPresent {
			if hasChampionshipPairs {
				isChampionship = matchup.Week == lastWeek && championshipPairs[rosterPairKey(matchup.HomeRosterID, matchup.AwayRosterID)]
			} else {
				isChampionship = matchup.IsPlayoff && matchup.Week == lastWeek && matchup.MatchupType == "WINNERS_BRACKET"
			}
		}

		matchup.IsChampionship = isChampionship
		matchup.TypeLabel = matchupTypeLabel(matchup.IsPlayoff, isChampionship, matchup.MatchupType, matchup.Week, lastWeek, matchup.HomePresent && matchup.AwayPresent)
	}
}

func sleeperChampionshipRosterPairs(brackets []sleeperdb.PlayoffBracketMatchup) map[string]bool {
	pairs := make(map[string]bool)
	for _, bracket := range brackets {
		if !isSleeperWinnersBracket(bracket.BracketType) || !bracket.Placement.Valid || bracket.Placement.Int32 != 1 {
			continue
		}

		first, second, ok := sleeperBracketRosterPair(bracket)
		if ok {
			pairs[rosterPairKey(first, second)] = true
		}
	}
	return pairs
}

func sleeperBracketRosterPair(bracket sleeperdb.PlayoffBracketMatchup) (int32, int32, bool) {
	if bracket.WinnerRosterID.Valid && bracket.LoserRosterID.Valid {
		return bracket.WinnerRosterID.Int32, bracket.LoserRosterID.Int32, true
	}
	if bracket.Slot1RosterID.Valid && bracket.Slot2RosterID.Valid {
		return bracket.Slot1RosterID.Int32, bracket.Slot2RosterID.Int32, true
	}
	return 0, 0, false
}

func isSleeperWinnersBracket(bracketType string) bool {
	normalized := strings.ToLower(strings.TrimSpace(bracketType))
	return strings.Contains(normalized, "winner")
}

func rosterPairKey(first, second int32) string {
	if first > second {
		first, second = second, first
	}
	return fmt.Sprintf("%d:%d", first, second)
}

func lastMatchupRowWeek(matchups []matchupsview.MatchupRow) int32 {
	var lastWeek int32
	for _, matchup := range matchups {
		if matchup.Week > lastWeek {
			lastWeek = matchup.Week
		}
	}
	return lastWeek
}

func sleeperMatchupRosterKey(week, matchupID, rosterID int32) string {
	return fmt.Sprintf("%d:%d:%d", week, matchupID, rosterID)
}

func sleeperScore(row sleeperdb.Matchup) string {
	if row.CustomPoints.Valid && strings.TrimSpace(row.CustomPoints.String) != "" {
		return strings.TrimSpace(row.CustomPoints.String)
	}
	return strings.TrimSpace(row.Points)
}

func sleeperAwayTeamName(team sleeperdb.Team, row sleeperdb.Matchup, present bool) string {
	if !present {
		return "BYE"
	}
	return sleeperMatchupTeamLabel(team, row.RosterID)
}

func sleeperAwayOwner(team sleeperdb.Team, present bool) string {
	if !present {
		return ""
	}
	return sleeperTeamOwnerLabel(team)
}

func sleeperMatchupTeamLabel(team sleeperdb.Team, rosterID int32) string {
	if strings.TrimSpace(team.TeamName) != "" || team.RosterID != 0 {
		return sleeperTeamLabel(team)
	}
	return fmt.Sprintf("Roster %d", rosterID)
}

func buildMatchupWeekTabs(matchups []matchupsview.MatchupRow) []matchupsview.WeekTab {
	tabsByWeek := make(map[int32]matchupsview.WeekTab)
	for _, matchup := range matchups {
		tab := tabsByWeek[matchup.Week]
		tab.Week = matchup.Week
		tab.IsPlayoff = tab.IsPlayoff || matchup.IsPlayoff
		tab.IsChampionship = tab.IsChampionship || matchup.IsChampionship
		tabsByWeek[matchup.Week] = tab
	}

	tabs := make([]matchupsview.WeekTab, 0, len(tabsByWeek))
	for _, tab := range tabsByWeek {
		tabs = append(tabs, tab)
	}
	sort.Slice(tabs, func(i, j int) bool {
		return tabs[i].Week < tabs[j].Week
	})
	return tabs
}

func filterMatchupsByWeek(matchups []matchupsview.MatchupRow, week int32) []matchupsview.MatchupRow {
	filtered := make([]matchupsview.MatchupRow, 0)
	for _, matchup := range matchups {
		if matchup.Week == week {
			filtered = append(filtered, matchup)
		}
	}
	return filtered
}

func lastESPNWeek(rows []db.GetMatchupsByLeagueIdRow) int32 {
	var lastWeek int32
	for _, row := range rows {
		if row.Week > lastWeek {
			lastWeek = row.Week
		}
	}
	return lastWeek
}

func matchupTypeLabel(isPlayoff, isChampionship bool, matchupType string, currentWeek, lastWeek int32, hasOpponent bool) string {
	if !hasOpponent {
		return "BYE Week"
	}
	if isChampionship {
		return "Championship"
	}
	if isPlayoff && matchupType == "WINNERS_BRACKET" {
		round := playoffRound(int(currentWeek), int(lastWeek))
		if round == 0 {
			return "Placement Game"
		}
		return fmt.Sprintf("Playoffs Round %d", round)
	}
	if isPlayoff {
		return fallback(matchupType, "Playoffs")
	}
	return "Regular Season"
}

func compareScoreStrings(left, right string) int {
	leftScore, leftErr := strconv.ParseFloat(strings.TrimSpace(left), 64)
	rightScore, rightErr := strconv.ParseFloat(strings.TrimSpace(right), 64)
	if leftErr != nil || rightErr != nil {
		return 0
	}
	switch {
	case leftScore > rightScore:
		return 1
	case leftScore < rightScore:
		return -1
	default:
		return 0
	}
}

func formatFloatScore(score float64) string {
	return strconv.FormatFloat(score, 'f', 2, 64)
}

func fallback(value, fallbackValue string) string {
	if strings.TrimSpace(value) == "" {
		return fallbackValue
	}
	return strings.TrimSpace(value)
}

func playoffRound(currentWeek, lastWeek int) int {
	if lastWeek-currentWeek == 2 {
		return 1
	}
	if lastWeek-currentWeek == 1 {
		return 2
	}
	return 0
}
