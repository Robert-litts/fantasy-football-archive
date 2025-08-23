package main

import (
	"database/sql"
	"fmt"
	"net/http"

	"github.com/Robert-litts/fantasy-football-archive/internal/validator"
	"github.com/Robert-litts/fantasy-football-archive/templates"
)

func (app *application) showTeamHandler(w http.ResponseWriter, r *http.Request) {
	id, err := app.readIDParam(r)
	if err != nil {
		app.notFoundResponse(w, r)
		return
	}

	app.logger.Info("attempting to fetch team", "id", id)

	// Use the SQLC-generated query method
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

	err = app.writeJSON(w, http.StatusOK, envelope{"team": team}, nil)
	if err != nil {
		app.serverErrorResponse(w, r, err)
	}
}

func (app *application) teamDisplayHandler(w http.ResponseWriter, r *http.Request) {
	v := validator.New()
	qs := r.URL.Query()
	id := app.readIntQuery(qs, "id", v)
	// Get all leagues
	leagues, err := app.queries.GetAllLeagues(r.Context())
	if err != nil {
		app.serverErrorResponse(w, r, err)
		return
	}
	fmt.Println("league id: ", leagues[0].ID)

	// Default to first league if none selected
	selectedLeagueID := leagues[0].ID

	/// If an ID was provided in the query, use that instead
	if id != -1 {
		selectedLeagueID = id
	}
	fmt.Println(selectedLeagueID)

	// Get teams for the selected league
	teams, err := app.queries.GetTeamsByLeagueYear(r.Context(), selectedLeagueID)
	if err != nil {
		app.serverErrorResponse(w, r, err)
		return
	}
	fmt.Println(teams)

	// If this is an HTMX request, only render the dashboard portion
	if r.Header.Get("HX-Request") == "true" {
		err = templates.Teams(teams, leagues, int(selectedLeagueID)).Render(r.Context(), w)
	} else {
		// Otherwise render the full page
		err = templates.Teams(teams, leagues, int(selectedLeagueID)).Render(r.Context(), w)
	}

	if err != nil {
		app.serverErrorResponse(w, r, err)
	}
}

func (app *application) teamBoardDisplayHandler(w http.ResponseWriter, r *http.Request) {
	v := validator.New()
	qs := r.URL.Query()
	id := app.readIntQuery(qs, "id", v)

	leagues, err := app.queries.GetAllLeagues(r.Context())
	if err != nil {
		app.logger.Error("database error", "error", err)
		if err == sql.ErrNoRows {
			app.notFoundResponse(w, r)
			return
		}
		app.serverErrorResponse(w, r, err)
		return
	}

	teams, err := app.queries.GetTeamsByLeagueYear(r.Context(), id)
	if err != nil {
		app.logger.Error("database error", "error", err)
		if err == sql.ErrNoRows {
			app.notFoundResponse(w, r)
			return
		}
		app.serverErrorResponse(w, r, err)
		return
	}

	if r.Header.Get("HX-Request") == "true" {
		err = templates.TeamsTable(teams, leagues, int(id)).Render(r.Context(), w)
		if err != nil {
			app.serverErrorResponse(w, r, err)
		}
		return
	}
	err = app.writeJSON(w, http.StatusOK, envelope{"teams": teams}, nil)
	if err != nil {
		app.serverErrorResponse(w, r, err)
	}
}
