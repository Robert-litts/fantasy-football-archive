package main

import (
	"context"
	"database/sql"
	"errors"
	"fmt"
	"net/http"
	"strconv"
	"strings"

	"github.com/Robert-litts/fantasy-football-archive/internal/archive"
	"github.com/Robert-litts/fantasy-football-archive/internal/db"
	"github.com/Robert-litts/fantasy-football-archive/internal/sleeperdb"
	teamsview "github.com/Robert-litts/fantasy-football-archive/internal/teamsview"
	"github.com/Robert-litts/fantasy-football-archive/templates"
)

type teamsArchiveLister interface {
	ListCanonicalLeagueSummaries(context.Context) (archive.LeagueList, error)
}

type teamsESPNLister interface {
	GetTeamsByLeagueYear(context.Context, int32) ([]db.GetTeamsByLeagueYearRow, error)
}

type teamsSleeperLister interface {
	ListTeamsByLeague(context.Context, int64) ([]sleeperdb.Team, error)
}

var errInvalidTeamsQuery = errors.New("invalid query parameters")

func (app *application) showTeamHandler(w http.ResponseWriter, r *http.Request) {
	id, err := app.readIDParam(r)
	if err != nil {
		app.notFoundResponse(w, r)
		return
	}

	app.logger.Info("attempting to fetch team", "id", id)

	team, err := app.queries.GetTeamById(r.Context(), int32(id))
	if err != nil {
		app.logger.Error("database error", "error", err)
		if err == sql.ErrNoRows {
			app.notFoundResponse(w, r)
			return
		}
		app.serverErrorResponse(w, r, err)
		return
	}

	if err := app.writeJSON(w, http.StatusOK, envelope{"team": team}, nil); err != nil {
		app.serverErrorResponse(w, r, err)
	}
}

func (app *application) apiListLeagueTeamsHandler(w http.ResponseWriter, r *http.Request) {
	id, err := app.readIDParam(r)
	if err != nil {
		app.notFoundResponse(w, r)
		return
	}

	teams, err := app.queries.GetTeamsByLeagueYear(r.Context(), int32(id))
	if err != nil {
		app.logger.Error("database error", "error", err)
		if err == sql.ErrNoRows {
			app.notFoundResponse(w, r)
			return
		}
		app.serverErrorResponse(w, r, err)
		return
	}

	if err := app.writeJSON(w, http.StatusOK, envelope{"teams": teams}, nil); err != nil {
		app.serverErrorResponse(w, r, err)
	}
}

func (app *application) teamDisplayHandler(w http.ResponseWriter, r *http.Request) {
	page, err := app.teamsPageData(r)
	if err != nil {
		app.handleTeamsPageError(w, r, err)
		return
	}

	if err := templates.Teams(page).Render(r.Context(), w); err != nil {
		app.serverErrorResponse(w, r, err)
	}
}

func (app *application) appTeamsTableFragmentHandler(w http.ResponseWriter, r *http.Request) {
	page, err := app.teamsPageData(r)
	if err != nil {
		app.handleTeamsPageError(w, r, err)
		return
	}

	if err := templates.TeamsTable(page).Render(r.Context(), w); err != nil {
		app.serverErrorResponse(w, r, err)
	}
}

func (app *application) teamBoardDisplayHandler(w http.ResponseWriter, r *http.Request) {
	page, err := app.teamsPageData(r)
	if err != nil {
		app.handleTeamsPageError(w, r, err)
		return
	}

	if r.Header.Get("HX-Request") == "true" {
		if err := templates.TeamsTable(page).Render(r.Context(), w); err != nil {
			app.serverErrorResponse(w, r, err)
		}
		return
	}

	if err := templates.Base(templates.Teams(page)).Render(r.Context(), w); err != nil {
		app.serverErrorResponse(w, r, err)
	}
}

func (app *application) teamsPageData(r *http.Request) (teamsview.PageData, error) {
	qs := r.URL.Query()
	selectedLeagueKey := strings.TrimSpace(qs.Get("id"))
	if selectedLeagueKey != "" {
		if _, _, err := parseArchiveLeagueSelectionKey(selectedLeagueKey); err != nil {
			return teamsview.PageData{}, errInvalidTeamsQuery
		}
	}

	return buildTeamsPageData(r.Context(), app.archive, app.queries, app.sleeperQueries, selectedLeagueKey)
}

func parseArchiveLeagueSelectionKey(value string) (archive.Provider, int64, error) {
	parts := strings.SplitN(strings.TrimSpace(value), ":", 2)
	if len(parts) != 2 {
		return "", 0, errors.New("invalid league selection key")
	}

	provider := archive.Provider(strings.TrimSpace(parts[0]))
	switch provider {
	case archive.ProviderESPN, archive.ProviderSleeper:
	default:
		return "", 0, errors.New("invalid league provider")
	}

	id, err := strconv.ParseInt(strings.TrimSpace(parts[1]), 10, 64)
	if err != nil || id < 1 {
		return "", 0, errors.New("invalid league id")
	}

	return provider, id, nil
}

func archiveLeagueSelectionKey(league archive.LeagueSummary) string {
	return fmt.Sprintf("%s:%d", league.Provider, league.ID)
}

func findLeagueSummaryByKey(leagues []archive.LeagueSummary, selectionKey string) (archive.LeagueSummary, bool) {
	for _, league := range leagues {
		if archiveLeagueSelectionKey(league) == selectionKey {
			return league, true
		}
	}
	return archive.LeagueSummary{}, false
}

func (app *application) handleTeamsPageError(w http.ResponseWriter, r *http.Request, err error) {
	if errors.Is(err, errInvalidTeamsQuery) {
		app.badRequestResponse(w, r, err)
		return
	}
	if errors.Is(err, sql.ErrConnDone) {
		app.serverErrorResponse(w, r, err)
		return
	}
	app.serverErrorResponse(w, r, err)
}

func buildTeamsPageData(
	ctx context.Context,
	archiveLister teamsArchiveLister,
	espnLister teamsESPNLister,
	sleeperLister teamsSleeperLister,
	selectedLeagueKey string,
) (teamsview.PageData, error) {
	page := teamsview.PageData{}

	if archiveLister == nil {
		return page, sql.ErrConnDone
	}

	leagueList, err := archiveLister.ListCanonicalLeagueSummaries(ctx)
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

	teams, sleeperMessage, err := loadTeamsForLeague(ctx, selected, espnLister, sleeperLister)
	if sleeperMessage != "" {
		page.SleeperMessage = sleeperMessage
	}
	if err != nil {
		return page, err
	}

	page.Teams = teams
	return page, nil
}

func loadTeamsForLeague(
	ctx context.Context,
	league archive.LeagueSummary,
	espnLister teamsESPNLister,
	sleeperLister teamsSleeperLister,
) ([]teamsview.TeamRow, string, error) {
	switch league.Provider {
	case archive.ProviderESPN:
		if espnLister == nil {
			return nil, "", sql.ErrConnDone
		}

		rows, err := espnLister.GetTeamsByLeagueYear(ctx, int32(league.ID))
		if err != nil {
			if errors.Is(err, sql.ErrNoRows) {
				return nil, "", nil
			}
			return nil, "", err
		}

		teams := make([]teamsview.TeamRow, 0, len(rows))
		for _, row := range rows {
			teams = append(teams, normalizeESPNTeamRow(row))
		}
		return teams, "", nil

	case archive.ProviderSleeper:
		if sleeperLister == nil {
			return nil, "Sleeper archive database is not configured", nil
		}

		rows, err := sleeperLister.ListTeamsByLeague(ctx, league.ID)
		if err != nil {
			if errors.Is(err, sql.ErrNoRows) {
				return nil, "", nil
			}
			return nil, "Sleeper team data is temporarily unavailable", nil
		}

		teams := make([]teamsview.TeamRow, 0, len(rows))
		for _, row := range rows {
			teams = append(teams, normalizeSleeperTeamRow(row))
		}
		return teams, "", nil
	default:
		return nil, "", fmt.Errorf("unsupported league provider %q", league.Provider)
	}
}

func normalizeESPNTeamRow(row db.GetTeamsByLeagueYearRow) teamsview.TeamRow {
	return teamsview.TeamRow{
		OwnerLabel:    strings.TrimSpace(row.Owners),
		TeamLabel:     formatESPNTeamLabel(row.TeamAbbrv, row.TeamName),
		Wins:          row.Wins,
		Losses:        row.Losses,
		Ties:          row.Ties,
		FinalStanding: row.FinalStanding,
		PointsFor:     strconv.Itoa(int(row.PointsFor)),
		PointsAgainst: strconv.Itoa(int(row.PointsAgainst)),
	}
}

func normalizeSleeperTeamRow(row sleeperdb.Team) teamsview.TeamRow {
	return teamsview.TeamRow{
		OwnerLabel:    sleeperTeamOwnerLabel(row),
		TeamLabel:     sleeperTeamLabel(row),
		Wins:          row.Wins,
		Losses:        row.Losses,
		Ties:          row.Ties,
		FinalStanding: row.FinalStanding,
		PointsFor:     row.PointsFor,
		PointsAgainst: row.PointsAgainst,
	}
}

func formatESPNTeamLabel(teamAbbrv, teamName string) string {
	teamAbbrv = strings.TrimSpace(teamAbbrv)
	teamName = strings.TrimSpace(teamName)

	switch {
	case teamName != "" && teamAbbrv != "":
		return fmt.Sprintf("%s (%s)", teamName, teamAbbrv)
	case teamName != "":
		return teamName
	default:
		return teamAbbrv
	}
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

func sleeperTeamLabel(team sleeperdb.Team) string {
	if name := strings.TrimSpace(team.TeamName); name != "" {
		return name
	}
	return fmt.Sprintf("Roster %d", team.RosterID)
}
