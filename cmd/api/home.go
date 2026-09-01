package main

import (
	"context"
	"database/sql"
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
	startTime := resolveStartTime(r.Context(), app)

	t := time.Now()

	yearsRunning := t.Year() - 2013

	seasonResultsFn := app.seasonResults
	if seasonResultsFn == nil {
		seasonResultsFn = app.seasonResultsPage
	}

	seasonResults, err := seasonResultsFn(r)
	if err != nil {
		app.logger.Error("season results unavailable", "error", err)
		seasonResults.SleeperMessage = "Season results are temporarily unavailable"
	}

	err = templates.Home(yearsRunning, startTime, seasonResults).Render(r.Context(), w)

	if err != nil {
		app.serverErrorResponse(w, r, err)
	}
}

func resolveStartTime(ctx context.Context, app *application) time.Time {
	if app.config.sleeperLeagueID == "" {
		app.logger.Info("skipping live draft time lookup; SLEEPER_LEAGUE_ID not configured")
		return time.Time{}
	}
	if app.draftTime == nil {
		app.logger.Warn("draft time lookup is not configured")
		return time.Time{}
	}

	startTime, err := app.draftTime.DraftTime(ctx, app.config.sleeperLeagueID)
	if err != nil {
		app.logger.Warn("draft time lookup failed; rendering page without draft time",
			"error", err,
			"league_id", app.config.sleeperLeagueID)
		return time.Time{}
	}
	return startTime
}
