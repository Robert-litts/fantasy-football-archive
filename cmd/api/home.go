package main

import (
	"net/http"
	"time"

	"github.com/Robert-litts/fantasy-football-archive/templates"
)

func (app *application) homeHandler(w http.ResponseWriter, r *http.Request) {
	t := time.Now()

	yearsRunning := t.Year() - 2013

	err := templates.Home(yearsRunning).Render(r.Context(), w)

	if err != nil {
		app.serverErrorResponse(w, r, err)
	}
}
