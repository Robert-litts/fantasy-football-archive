package main

import (
	"bytes"
	"context"
	"errors"
	"io"
	"log/slog"
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"
	"time"

	"github.com/Robert-litts/fantasy-football-archive/internal/archive"
	"github.com/gorilla/sessions"
)

// stubDraftTimeLookup is a controllable DraftTimeLookup for tests.
type stubDraftTimeLookup struct {
	t   time.Time
	err error
}

func (s stubDraftTimeLookup) DraftTime(_ context.Context, _ string) (time.Time, error) {
	return s.t, s.err
}

func newHomeTestApp(t *testing.T, leagueID string) *application {
	t.Helper()
	app := &application{
		config: config{
			env:             "test",
			sleeperLeagueID: leagueID,
		},
		logger:       slog.New(slog.NewTextHandler(io.Discard, nil)),
		sessionStore: sessions.NewCookieStore([]byte("test-session-key")),
	}
	return app
}

func stubSeasonResults(list archive.SeasonResultList, err error) func(*http.Request) (archive.SeasonResultList, error) {
	return func(*http.Request) (archive.SeasonResultList, error) {
		return list, err
	}
}

func TestHomeHandlerEmptyLeagueIDSkipsDraftLookup(t *testing.T) {
	app := newHomeTestApp(t, "")
	app.draftTime = stubDraftTimeLookup{t: time.Now().Add(72 * time.Hour)}

	called := false
	app.seasonResults = func(*http.Request) (archive.SeasonResultList, error) {
		called = true
		return archive.SeasonResultList{}, nil
	}

	req := httptest.NewRequest(http.MethodGet, "/app/home", nil)
	rr := httptest.NewRecorder()

	app.homeHandler(rr, req)

	if rr.Code != http.StatusOK {
		t.Fatalf("got status %d, want %d", rr.Code, http.StatusOK)
	}
	if !called {
		t.Fatal("expected seasonResults to be invoked")
	}
	if !strings.Contains(rr.Body.String(), "Draft time unavailable") {
		t.Fatalf("body should contain fallback message; got %q", rr.Body.String())
	}
}

func TestHomeHandlerDraftLookupFailureLogsWarnAndRenders200(t *testing.T) {
	app := newHomeTestApp(t, "league-xyz")
	app.draftTime = stubDraftTimeLookup{err: errors.New("sleeper is down")}
	app.seasonResults = stubSeasonResults(archive.SeasonResultList{}, nil)

	// Use a custom recording logger so we can assert on warn output.
	logBuf := &bytes.Buffer{}
	handler := slog.NewTextHandler(logBuf, &slog.HandlerOptions{Level: slog.LevelDebug})
	app.logger = slog.New(handler)

	req := httptest.NewRequest(http.MethodGet, "/app/home", nil)
	rr := httptest.NewRecorder()

	app.homeHandler(rr, req)

	if rr.Code != http.StatusOK {
		t.Fatalf("got status %d, want %d", rr.Code, http.StatusOK)
	}
	if !strings.Contains(logBuf.String(), "draft time lookup failed") {
		t.Fatalf("expected warn log; got %s", logBuf.String())
	}
	if !strings.Contains(rr.Body.String(), "Draft time unavailable") {
		t.Fatalf("body should contain fallback message; got %q", rr.Body.String())
	}
}

func TestHomeHandlerSuccessRendersStartTime(t *testing.T) {
	app := newHomeTestApp(t, "league-xyz")
	loc, err := time.LoadLocation("America/New_York")
	if err != nil {
		t.Fatalf("failed to load timezone: %v", err)
	}
	expected := time.Date(2026, 9, 14, 20, 0, 0, 0, loc)
	app.draftTime = stubDraftTimeLookup{t: expected}
	app.seasonResults = stubSeasonResults(archive.SeasonResultList{}, nil)

	req := httptest.NewRequest(http.MethodGet, "/app/home", nil)
	rr := httptest.NewRecorder()

	app.homeHandler(rr, req)

	if rr.Code != http.StatusOK {
		t.Fatalf("got status %d, want %d", rr.Code, http.StatusOK)
	}
	if strings.Contains(rr.Body.String(), "Draft time unavailable") {
		t.Fatalf("body should not contain fallback message; got %q", rr.Body.String())
	}
	if !strings.Contains(rr.Body.String(), expected.Format("Mon, Jan 2 at 3:04PM MST")) {
		t.Fatalf("body should contain formatted start time; got %q", rr.Body.String())
	}
}

func TestResolveStartTimeReturnsZeroOnLookupError(t *testing.T) {
	app := newHomeTestApp(t, "league-xyz")
	app.draftTime = stubDraftTimeLookup{err: errors.New("boom")}

	got := resolveStartTime(context.Background(), app)
	if !got.IsZero() {
		t.Fatalf("resolveStartTime = %v, want zero time on error", got)
	}
}

func TestResolveStartTimeSkipsLookupWhenLeagueIDEmpty(t *testing.T) {
	app := newHomeTestApp(t, "")
	app.draftTime = stubDraftTimeLookup{t: time.Now().Add(time.Hour)}

	got := resolveStartTime(context.Background(), app)
	if !got.IsZero() {
		t.Fatalf("resolveStartTime = %v, want zero time when league id is empty", got)
	}
}
