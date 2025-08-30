package main

import (
	"io/fs"
	"net/http"

	embed "github.com/Robert-litts/fantasy-football-archive/internal"
	"github.com/julienschmidt/httprouter"
)

func (app *application) routes() http.Handler {
	router := httprouter.New()
	router.NotFound = http.HandlerFunc(app.notFoundResponse)                 // 404
	router.MethodNotAllowed = http.HandlerFunc(app.methodNotAllowedResponse) // 405

	router.HandlerFunc(http.MethodGet, "/", app.loginHandler)
	staticFS, err := fs.Sub(embed.StaticFiles, "static")
	if err != nil {
		app.logger.Error("failed to get static filesystem", "error", err)
	} else {
		router.ServeFiles("/static/*filepath", http.FS(staticFS))
	}
	//router.ServeFiles("/static/*filepath", http.Dir("./static/"))

	//API Routes
	router.HandlerFunc(http.MethodGet, "/v1/healthcheck", app.healthcheckHandler)
	router.HandlerFunc(http.MethodGet, "/v1/leagues", app.listLeaguesHandler)
	router.HandlerFunc(http.MethodGet, "/v1/leagues/:id", app.showLeagueHandler)
	router.HandlerFunc(http.MethodGet, "/v1/leagues/:id/teams/:id", app.showTeamHandler)
	router.HandlerFunc(http.MethodGet, "/v1/leagues/:id/drafts", app.listDraftHandler)
	//router.HandlerFunc(http.MethodPost, "/v1/users", app.registerUserHandler)
	router.HandlerFunc(http.MethodGet, "/login", app.loginTemplHandler)

	//Auth Routes
	router.HandlerFunc(http.MethodGet, "/v1/auth/:provider/callback", app.HandleCallback)
	router.HandlerFunc(http.MethodGet, "/v1/auth/:provider/logout", app.HandleLogout)
	router.HandlerFunc(http.MethodGet, "/v1/auth/:provider", app.HandleAuth)

	// route with authentication middleware
	router.HandlerFunc(http.MethodGet, "/v1/dashboard",
		app.requireAuthenticated(app.dashboardHandler))

	// route for HTMX to refresh user info
	router.HandlerFunc(http.MethodGet, "/v1/dashboard/refresh",
		app.requireAuthenticated(app.dashboardHandler))

	router.HandlerFunc(http.MethodGet, "/v1/dashboard/leagues",
		app.requireAuthenticated(app.leaguesPageHandler))

	router.HandlerFunc(http.MethodGet, "/v1/dashboard/leagues/refresh",
		app.requireAuthenticated(app.leaguesPageHandler))

	router.HandlerFunc(http.MethodGet, "/v1/dashboard/index",
		app.requireAuthenticated(app.leaguesIndexHandler))

	//HTMX Routes
	router.HandlerFunc(http.MethodGet, "/drafts", app.requireAuthenticated(app.draftsListHandler))
	router.HandlerFunc(http.MethodGet, "/drafts/:id", app.requireAuthenticated(app.draftBoardHandler))
	router.HandlerFunc(http.MethodGet, "/draftboard", app.requireAuthenticated(app.draftDisplayHandler))
	router.HandlerFunc(http.MethodGet, "/teams", app.requireAuthenticated(app.teamDisplayHandler))
	router.HandlerFunc(http.MethodGet, "/leagues", app.requireAuthenticated(app.leaguesPageHandler))
	router.HandlerFunc(http.MethodGet, "/teamboard", app.requireAuthenticated(app.teamBoardDisplayHandler))
	router.HandlerFunc(http.MethodGet, "/matchups", app.requireAuthenticated(app.matchupTableHandler))
	router.HandlerFunc(http.MethodGet, "/home", app.requireAuthenticated(app.homeHandler))
	router.HandlerFunc(http.MethodGet, "/stats", app.requireAuthenticated(app.statsHandler))
	router.HandlerFunc(http.MethodGet, "/rules", app.requireAuthenticated(app.rulesHandler))

	router.HandlerFunc(http.MethodGet, "/matchups/week/:week", app.matchupWeekHandler)

	return app.recoverPanic(router)
}
