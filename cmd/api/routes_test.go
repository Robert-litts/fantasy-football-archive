package main

import (
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"

	"github.com/gorilla/sessions"
)

func TestRoutesCanBeBuilt(t *testing.T) {
	app := newTestApplication()

	defer func() {
		if err := recover(); err != nil {
			t.Fatalf("routes panicked while being built: %v", err)
		}
	}()

	_ = app.routes()
}

func TestHealthcheckRouteReturnsJSON(t *testing.T) {
	app := newTestApplication()

	req := httptest.NewRequest(http.MethodGet, "/api/v1/healthcheck", nil)
	rr := httptest.NewRecorder()

	app.routes().ServeHTTP(rr, req)

	if rr.Code != http.StatusOK {
		t.Fatalf("got status %d; want %d", rr.Code, http.StatusOK)
	}

	if got := rr.Header().Get("Content-Type"); got != "application/json" {
		t.Fatalf("got Content-Type %q; want application/json", got)
	}

	if !strings.Contains(rr.Body.String(), `"status": "available"`) {
		t.Fatalf("response body does not contain health status: %s", rr.Body.String())
	}
}

func TestUnauthenticatedAppRoutesRedirectToLogin(t *testing.T) {
	app := newTestApplication()

	tests := []string{
		"/app",
		"/app/leagues",
		"/app/fragments/leagues-table",
	}

	for _, path := range tests {
		t.Run(path, func(t *testing.T) {
			req := httptest.NewRequest(http.MethodGet, path, nil)
			rr := httptest.NewRecorder()

			app.routes().ServeHTTP(rr, req)

			if rr.Code != http.StatusSeeOther {
				t.Fatalf("got status %d; want %d", rr.Code, http.StatusSeeOther)
			}

			if got := rr.Header().Get("Location"); got != "/" {
				t.Fatalf("got Location %q; want /", got)
			}
		})
	}
}

func TestUnknownRouteReturnsJSONNotFound(t *testing.T) {
	app := newTestApplication()

	req := httptest.NewRequest(http.MethodGet, "/api/v1/does-not-exist", nil)
	rr := httptest.NewRecorder()

	app.routes().ServeHTTP(rr, req)

	if rr.Code != http.StatusNotFound {
		t.Fatalf("got status %d; want %d", rr.Code, http.StatusNotFound)
	}

	if got := rr.Header().Get("Content-Type"); got != "application/json" {
		t.Fatalf("got Content-Type %q; want application/json", got)
	}
}

func newTestApplication() *application {
	return &application{
		config: config{
			env: "test",
		},
		sessionStore: sessions.NewCookieStore([]byte("test-session-key")),
	}
}
