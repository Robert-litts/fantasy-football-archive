package main

import (
	"database/sql"
	"fmt"
	"net/http"
	"time"
	_ "time/tzdata"

	"github.com/Robert-litts/fantasy-football-archive/internal/archive"
	"github.com/Robert-litts/fantasy-football-archive/templates"
)

func (app *application) seasonResultsPage(r *http.Request) (archive.SeasonResultList, error) {
	if app.archive == nil {
		return archive.SeasonResultList{}, sql.ErrConnDone
	}

	return app.archive.ListSeasonResults(r.Context())
}

func (app *application) homeHandler(w http.ResponseWriter, r *http.Request) {

	startTime, err := Get_draft_time(app.config.sleeperLeagueID)
	if err != nil {
		fmt.Println("Error:", err)
		return
	}

	t := time.Now()

	yearsRunning := t.Year() - 2013

	seasonResults, err := app.seasonResultsPage(r)
	if err != nil {
		app.logger.Error("season results unavailable", "error", err)
		seasonResults.SleeperMessage = "Season results are temporarily unavailable"
	}

	err = templates.Home(yearsRunning, startTime, seasonResults).Render(r.Context(), w)

	if err != nil {
		app.serverErrorResponse(w, r, err)
	}
}
