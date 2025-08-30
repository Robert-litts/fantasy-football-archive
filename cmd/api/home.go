package main

import (
	"fmt"
	"net/http"
	"time"
	_ "time/tzdata"

	"github.com/Robert-litts/fantasy-football-archive/templates"
)

func (app *application) homeHandler(w http.ResponseWriter, r *http.Request) {

	startTime, err := Get_draft_time(app.config.sleeperLeagueID)
	if err != nil {
		fmt.Println("Error:", err)
		return
	}

	t := time.Now()

	yearsRunning := t.Year() - 2013

	err = templates.Home(yearsRunning, startTime).Render(r.Context(), w)

	if err != nil {
		app.serverErrorResponse(w, r, err)
	}
}
