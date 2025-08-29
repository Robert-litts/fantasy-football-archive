package main

import (
	"net/http"

	"github.com/Robert-litts/fantasy-football-archive/templates"
)

func (app *application) rulesHandler(w http.ResponseWriter, r *http.Request) {

	err := templates.Rules().Render(r.Context(), w)

	if err != nil {
		app.serverErrorResponse(w, r, err)
	}
}
