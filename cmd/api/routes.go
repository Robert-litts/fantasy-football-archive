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

	// API routes return JSON for programmatic clients.
	router.HandlerFunc(http.MethodGet, "/api/v1/healthcheck", app.healthcheckHandler)
	router.HandlerFunc(http.MethodGet, "/api/v1/leagues", app.listLeaguesHandler)
	router.HandlerFunc(http.MethodGet, "/api/v1/leagues/:id", app.showLeagueHandler)
	router.HandlerFunc(http.MethodGet, "/api/v1/leagues/:id/teams", app.apiListLeagueTeamsHandler)
	router.HandlerFunc(http.MethodGet, "/api/v1/leagues/:id/teams/:id", app.showTeamHandler)
	router.HandlerFunc(http.MethodGet, "/api/v1/leagues/:id/drafts", app.apiListLeagueDraftsHandler)
	router.HandlerFunc(http.MethodGet, "/api/v1/leagues/:id/matchups", app.apiListLeagueMatchupsHandler)

	// Compatibility aliases for the original API routes.
	router.HandlerFunc(http.MethodGet, "/v1/healthcheck", app.healthcheckHandler)
	router.HandlerFunc(http.MethodGet, "/v1/leagues", app.listLeaguesHandler)
	router.HandlerFunc(http.MethodGet, "/v1/leagues/:id", app.showLeagueHandler)
	router.HandlerFunc(http.MethodGet, "/v1/leagues/:id/teams", app.apiListLeagueTeamsHandler)
	router.HandlerFunc(http.MethodGet, "/v1/leagues/:id/teams/:id", app.showTeamHandler)
	router.HandlerFunc(http.MethodGet, "/v1/leagues/:id/drafts", app.listDraftHandler)
	router.HandlerFunc(http.MethodGet, "/v1/leagues/:id/matchups", app.apiListLeagueMatchupsHandler)
	//router.HandlerFunc(http.MethodPost, "/v1/users", app.registerUserHandler)
	router.HandlerFunc(http.MethodGet, "/login", app.loginTemplHandler)

	// Auth routes own browser login, callback, and logout redirects.
	router.HandlerFunc(http.MethodGet, "/auth/:provider/callback", app.HandleCallback)
	router.HandlerFunc(http.MethodGet, "/auth/:provider/logout", app.HandleLogout)
	router.HandlerFunc(http.MethodGet, "/auth/:provider", app.HandleAuth)

	// Compatibility aliases for the original auth routes.
	router.HandlerFunc(http.MethodGet, "/v1/auth/:provider/callback", app.HandleCallback)
	router.HandlerFunc(http.MethodGet, "/v1/auth/:provider/logout", app.HandleLogout)
	router.HandlerFunc(http.MethodGet, "/v1/auth/:provider", app.HandleAuth)

	// App shell and page routes render user-visible HTML.
	router.HandlerFunc(http.MethodGet, "/app", app.requireAuthenticated(app.leaguesIndexHandler))
	router.HandlerFunc(http.MethodGet, "/app/index", app.requireAuthenticated(app.leaguesIndexHandler))
	router.HandlerFunc(http.MethodGet, "/app/dashboard", app.requireAuthenticated(app.appDashboardPageHandler))
	router.HandlerFunc(http.MethodGet, "/app/home", app.requireAuthenticated(app.homeHandler))
	router.HandlerFunc(http.MethodGet, "/app/leagues", app.requireAuthenticated(app.appLeaguesPageHandler))
	router.HandlerFunc(http.MethodGet, "/app/teams", app.requireAuthenticated(app.teamDisplayHandler))
	router.HandlerFunc(http.MethodGet, "/app/matchups", app.requireAuthenticated(app.appMatchupsTableFragmentHandler))
	router.HandlerFunc(http.MethodGet, "/app/drafts", app.requireAuthenticated(app.appDraftsPageHandler))
	router.HandlerFunc(http.MethodGet, "/app/drafts/:id", app.requireAuthenticated(app.draftBoardHandler))
	router.HandlerFunc(http.MethodGet, "/app/draftboard", app.requireAuthenticated(app.appDraftBoardFragmentHandler))
	router.HandlerFunc(http.MethodGet, "/app/stats", app.requireAuthenticated(app.statsHandler))
	router.HandlerFunc(http.MethodGet, "/app/rules", app.requireAuthenticated(app.rulesHandler))

	// App fragment routes render HTMX partials.
	router.HandlerFunc(http.MethodGet, "/app/fragments/user-info", app.requireAuthenticated(app.appUserInfoFragmentHandler))
	router.HandlerFunc(http.MethodGet, "/app/fragments/leagues-table", app.requireAuthenticated(app.appLeaguesTableFragmentHandler))
	router.HandlerFunc(http.MethodGet, "/app/fragments/teams-table", app.requireAuthenticated(app.appTeamsTableFragmentHandler))
	router.HandlerFunc(http.MethodGet, "/app/fragments/matchups-table", app.requireAuthenticated(app.appMatchupsTableFragmentHandler))
	router.HandlerFunc(http.MethodGet, "/app/fragments/matchups-week/:week", app.requireAuthenticated(app.appMatchupsWeekFragmentHandler))
	router.HandlerFunc(http.MethodGet, "/app/fragments/draft-page", app.requireAuthenticated(app.appDraftsPageHandler))
	router.HandlerFunc(http.MethodGet, "/app/fragments/draft-board", app.requireAuthenticated(app.appDraftBoardFragmentHandler))
	router.HandlerFunc(http.MethodGet, "/app/fragments/draft-board/:id", app.requireAuthenticated(app.appDraftBoardByIDFragmentHandler))

	// Compatibility aliases for the original browser routes.
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
