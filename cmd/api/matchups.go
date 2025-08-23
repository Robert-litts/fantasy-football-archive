package main

import (
	"database/sql"
	"net/http"

	"github.com/Robert-litts/fantasy-football-archive/internal/validator"
	"github.com/Robert-litts/fantasy-football-archive/templates"
)

func (app *application) matchupTableHandler(w http.ResponseWriter, r *http.Request) {
	v := validator.New()
	qs := r.URL.Query()
	id := app.readIntQuery(qs, "id", v)
	week := app.readIntQuery(qs, "week", v)

	leagues, err := app.queries.GetAllLeagues(r.Context())
	if err != nil {
		app.serverErrorResponse(w, r, err)
		return
	}

	// // Default to first league if none selected
	selectedLeagueID := leagues[0].ID
	selectedWeek := 1 // default to first week of every season unless specified

	/// If an ID was provided in the query, use that instead
	if id != -1 {
		selectedLeagueID = id
	}

	if week != -1 {
		selectedWeek = int(week)
	}

	matchups, err := app.queries.GetMatchupsByLeagueId(r.Context(), selectedLeagueID)
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

		err = templates.MatchupsTable(leagues, int(selectedLeagueID), matchups, int32(selectedWeek)).Render(r.Context(), w)
		if err != nil {
			app.serverErrorResponse(w, r, err)
		}
		return
	}
	err = app.writeJSON(w, http.StatusOK, envelope{"matchups": matchups}, nil)
	if err != nil {
		app.serverErrorResponse(w, r, err)
	}
}

func (app *application) matchupWeekHandler(w http.ResponseWriter, r *http.Request) {

	v := validator.New()
	qs := r.URL.Query()
	id := app.readIntQuery(qs, "id", v)
	week, err := app.readWeekParam(r)
	if err != nil {
		app.notFoundResponse(w, r)
		return
	}

	leagues, err := app.queries.GetAllLeagues(r.Context())
	if err != nil {
		app.serverErrorResponse(w, r, err)
		return
	}

	// Default to first league if none selected
	selectedLeagueID := leagues[0].ID
	selectedWeek := 1 // default to first week of every season unless specified

	//If an ID was provided in the query, use that instead
	if id != -1 {
		selectedLeagueID = id
	}

	if week != -1 {
		selectedWeek = int(week)
	}

	matchups, err := app.queries.GetMatchupsByLeagueId(r.Context(), selectedLeagueID)
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
		err = templates.WeekContent(matchups, int32(selectedWeek)).Render(r.Context(), w)
		if err != nil {
			app.serverErrorResponse(w, r, err)
		}
		return
	}
}
