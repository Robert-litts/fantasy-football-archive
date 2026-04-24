package main

import (
	"database/sql"
	"errors"
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

	// Default to first league if none selected
	selectedLeagueID := leagues[0].ID

	/// If an ID was provided in the query, use that instead
	if id != -1 {
		selectedLeagueID = id
	}

	// Get teams for the selected league
	teams, err := app.queries.GetTeamsByLeagueYear(r.Context(), selectedLeagueID)
	if err != nil {
		app.serverErrorResponse(w, r, err)
		return
	}

	err = templates.Teams(teams, leagues, int(selectedLeagueID)).Render(r.Context(), w)
	if err != nil {
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

	err = app.writeJSON(w, http.StatusOK, envelope{"teams": teams}, nil)
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

func (app *application) appTeamsTableFragmentHandler(w http.ResponseWriter, r *http.Request) {
	v := validator.New()
	qs := r.URL.Query()
	id := app.readIntQuery(qs, "id", v)
	if !v.Valid() || id < 1 {
		app.badRequestResponse(w, r, errors.New("valid id query parameter is required"))
		return
	}

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

	err = templates.TeamsTable(teams, leagues, int(id)).Render(r.Context(), w)
	if err != nil {
		app.serverErrorResponse(w, r, err)
	}
}
