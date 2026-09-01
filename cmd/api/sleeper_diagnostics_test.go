package main

import (
	"context"
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"

	"github.com/Robert-litts/fantasy-football-archive/internal/sleeperdb"
	"github.com/gorilla/sessions"
)

type diagnosticsSleeperStub struct {
	reports []sleeperdb.ListLeagueReportsRow
	err     error
}

func (s diagnosticsSleeperStub) ListLeagueReports(context.Context) ([]sleeperdb.ListLeagueReportsRow, error) {
	return s.reports, s.err
}

func (s diagnosticsSleeperStub) ListTeamsByLeague(context.Context, int64) ([]sleeperdb.Team, error) {
	return nil, nil
}

func (s diagnosticsSleeperStub) ListDraftPicksByLeague(context.Context, int64) ([]sleeperdb.ListDraftPicksByLeagueRow, error) {
	return nil, nil
}

func (s diagnosticsSleeperStub) ListPlayerPositionsByESPNIDs(context.Context, []string) ([]sleeperdb.PlayerPositionByESPNID, error) {
	return nil, nil
}

func (s diagnosticsSleeperStub) ListMatchupsByLeague(context.Context, int64) ([]sleeperdb.Matchup, error) {
	return nil, nil
}

func (s diagnosticsSleeperStub) ListPlayoffBracketMatchupsByLeague(context.Context, int64) ([]sleeperdb.PlayoffBracketMatchup, error) {
	return nil, nil
}

// authenticatedTestStore returns a sessions.Store that always reports the user
// as authenticated. It implements just enough of the interface to drive the
// requireAuthenticated middleware.
type authenticatedTestStore struct{}

func (authenticatedTestStore) Get(r *http.Request, name string) (*sessions.Session, error) {
	session, err := sessions.NewCookieStore([]byte("test-session-key")).Get(r, name)
	if err != nil {
		return nil, err
	}
	session.Values["authenticated"] = true
	return session, nil
}

func (authenticatedTestStore) New(r *http.Request, name string) (*sessions.Session, error) {
	return sessions.NewCookieStore([]byte("test-session-key")).New(r, name)
}

func (authenticatedTestStore) Save(r *http.Request, w http.ResponseWriter, s *sessions.Session) error {
	return sessions.NewCookieStore([]byte("test-session-key")).Save(r, w, s)
}

func newDiagnosticsApp(t *testing.T, stub sleeperQueryStore, authenticated bool) *application {
	t.Helper()
	app := newTestApplication()
	app.sleeperQueries = stub
	app.draftTime = NewDraftTimeLookup(nil)
	app.config.sleeperLeagueID = "league-x"
	if authenticated {
		app.sessionStore = authenticatedTestStore{}
	}
	return app
}

func TestSleeperDiagnosticsRouteReturnsServiceUnavailableWhenQueriesNil(t *testing.T) {
	app := newDiagnosticsApp(t, nil, true)

	req := httptest.NewRequest(http.MethodGet, "/app/diagnostics/sleeper", nil)
	rr := httptest.NewRecorder()

	app.routes().ServeHTTP(rr, req)

	if rr.Code != http.StatusServiceUnavailable {
		t.Fatalf("got status %d, want %d", rr.Code, http.StatusServiceUnavailable)
	}
	if got := rr.Header().Get("Content-Type"); !strings.HasPrefix(got, "application/json") {
		t.Fatalf("Content-Type = %q, want application/json", got)
	}
	if !strings.Contains(rr.Body.String(), "sleeper database is not configured") {
		t.Fatalf("response body = %q, want configured message", rr.Body.String())
	}
}

func TestSleeperDiagnosticsRouteRendersHTMLWhenQueriesAvailable(t *testing.T) {
	stub := diagnosticsSleeperStub{
		reports: []sleeperdb.ListLeagueReportsRow{
			{
				LeagueID:         1,
				Season:           2023,
				Name:             "Sleeper 2023",
				TeamCount:        12,
				TotalRosters:     12,
				ChampionTeamName: "Champ",
				RunnerUpTeamName: "Run",
			},
		},
	}

	app := newDiagnosticsApp(t, stub, true)

	req := httptest.NewRequest(http.MethodGet, "/app/diagnostics/sleeper", nil)
	rr := httptest.NewRecorder()

	app.routes().ServeHTTP(rr, req)

	if rr.Code != http.StatusOK {
		t.Fatalf("got status %d, want %d", rr.Code, http.StatusOK)
	}
	if got := rr.Header().Get("Content-Type"); !strings.HasPrefix(got, "text/html") {
		t.Fatalf("Content-Type = %q, want text/html", got)
	}
	if !strings.Contains(rr.Body.String(), "Sleeper 2023") {
		t.Fatalf("response body does not contain stub league name: %s", rr.Body.String())
	}
	if !strings.Contains(rr.Body.String(), "Champ") {
		t.Fatalf("response body does not contain stub champion: %s", rr.Body.String())
	}
}

func TestLegacySleeperReportAPIRouteIsRemoved(t *testing.T) {
	app := newDiagnosticsApp(t, nil, true)

	req := httptest.NewRequest(http.MethodGet, "/api/v1/sleeper/report", nil)
	rr := httptest.NewRecorder()

	app.routes().ServeHTTP(rr, req)

	if rr.Code != http.StatusNotFound {
		t.Fatalf("got status %d, want %d (JSON route removed)", rr.Code, http.StatusNotFound)
	}
}

func TestSleeperDiagnosticsRouteRequiresAuthentication(t *testing.T) {
	app := newDiagnosticsApp(t, nil, false)

	req := httptest.NewRequest(http.MethodGet, "/app/diagnostics/sleeper", nil)
	rr := httptest.NewRecorder()

	app.routes().ServeHTTP(rr, req)

	if rr.Code != http.StatusSeeOther {
		t.Fatalf("got status %d, want %d (redirect to login)", rr.Code, http.StatusSeeOther)
	}
}
