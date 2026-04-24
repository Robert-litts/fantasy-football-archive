package main

import (
	"database/sql"
	"net/http"

	"github.com/Robert-litts/fantasy-football-archive/internal/db"
	appstats "github.com/Robert-litts/fantasy-football-archive/internal/stats"
	"github.com/Robert-litts/fantasy-football-archive/templates"
)

func (app *application) statsHandler(w http.ResponseWriter, r *http.Request) {
	leagues, err := app.queries.GetAllLeagues(r.Context())
	if err != nil {
		app.serverErrorResponse(w, r, err)
		return
	}

	teamsByLeague := make(map[int32][]db.GetTeamsByLeagueYearRow, len(leagues))
	matchupsByLeague := make(map[int32][]db.GetMatchupsByLeagueIdRow, len(leagues))
	for _, league := range leagues {
		teams, err := app.queries.GetTeamsByLeagueYear(r.Context(), league.ID)
		if err != nil {
			app.logger.Error("database error", "error", err, "leagueID", league.ID, "source", "teams")
			if err == sql.ErrNoRows {
				continue
			}
			app.serverErrorResponse(w, r, err)
			return
		}
		teamsByLeague[league.ID] = teams

		matchups, err := app.queries.GetMatchupsByLeagueId(r.Context(), league.ID)
		if err != nil {
			app.logger.Error("database error", "error", err, "leagueID", league.ID, "source", "matchups")
			if err == sql.ErrNoRows {
				continue
			}
			app.serverErrorResponse(w, r, err)
			return
		}
		matchupsByLeague[league.ID] = matchups
	}

	pageData := appstats.BuildPageData(leagues, teamsByLeague, matchupsByLeague, app.config.ownerAliases)

	if r.Header.Get("HX-Request") == "true" {
		err := templates.Stats(pageData).Render(r.Context(), w)
		if err != nil {
			app.serverErrorResponse(w, r, err)
		}
		return
	}

	err = templates.Base(
		templates.Stats(pageData),
	).Render(r.Context(), w)

	if err != nil {
		app.serverErrorResponse(w, r, err)
	}
}
