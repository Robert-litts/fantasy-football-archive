package main

import (
	"context"
	"encoding/json"
	"io"
	"log/slog"
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"
	"time"
)

func newDraftTimeTestFetcher(t *testing.T, serverURL string, now time.Time) *draftTimeFetcher {
	t.Helper()
	return &draftTimeFetcher{
		client:  &http.Client{Timeout: 2 * time.Second},
		logger:  slog.New(slog.NewTextHandler(io.Discard, nil)),
		now:     func() time.Time { return now },
		baseURL: serverURL + "/v1/league/%s/drafts",
	}
}

func TestDraftTimeLookupSuccessReturnsUpcomingDraftInNY(t *testing.T) {
	now := time.Date(2026, 8, 31, 12, 0, 0, 0, time.UTC)
	future := now.Add(72 * time.Hour).UnixMilli()
	past := now.Add(-48 * time.Hour).UnixMilli()

	server := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Content-Type", "application/json")
		_ = json.NewEncoder(w).Encode([]sleeperDraft{
			{StartTime: past},
			{StartTime: future},
		})
	}))
	defer server.Close()

	fetcher := newDraftTimeTestFetcher(t, server.URL, now)
	got, err := fetcher.DraftTime(context.Background(), "123")
	if err != nil {
		t.Fatalf("DraftTime returned error: %v", err)
	}

	loc, err := time.LoadLocation("America/New_York")
	if err != nil {
		t.Fatalf("failed to load timezone: %v", err)
	}
	expected := time.UnixMilli(future).UTC().In(loc)
	if !got.Equal(expected) {
		t.Fatalf("DraftTime = %s, want %s", got, expected)
	}
}

func TestDraftTimeLookupRejectsNon2xx(t *testing.T) {
	server := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		http.Error(w, "boom", http.StatusInternalServerError)
	}))
	defer server.Close()

	fetcher := newDraftTimeTestFetcher(t, server.URL, time.Now())
	if _, err := fetcher.DraftTime(context.Background(), "1"); err == nil {
		t.Fatal("expected error for non-2xx response")
	}
}

func TestDraftTimeLookupEmptyListErrors(t *testing.T) {
	server := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Content-Type", "application/json")
		_, _ = w.Write([]byte("[]"))
	}))
	defer server.Close()

	fetcher := newDraftTimeTestFetcher(t, server.URL, time.Now())
	_, err := fetcher.DraftTime(context.Background(), "1")
	if err == nil {
		t.Fatal("expected error for empty draft list")
	}
	if !strings.Contains(err.Error(), "no drafts") {
		t.Fatalf("error = %v, want it to mention no drafts", err)
	}
}

func TestDraftTimeLookupMalformedJSONErrors(t *testing.T) {
	server := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		_, _ = w.Write([]byte("{not valid json"))
	}))
	defer server.Close()

	fetcher := newDraftTimeTestFetcher(t, server.URL, time.Now())
	if _, err := fetcher.DraftTime(context.Background(), "1"); err == nil {
		t.Fatal("expected error for malformed JSON")
	}
}

func TestDraftTimeLookupOversizedBodyIsCapped(t *testing.T) {
	// Construct a payload larger than the 64KB cap. The JSON parser will fail
	// because the response is truncated, which is the expected behaviour.
	huge := strings.Repeat("a", int(draftTimeResponseLimit)+512)
	server := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Content-Type", "application/json")
		_, _ = io.WriteString(w, huge)
	}))
	defer server.Close()

	fetcher := newDraftTimeTestFetcher(t, server.URL, time.Now())
	_, err := fetcher.DraftTime(context.Background(), "1")
	if err == nil {
		t.Fatal("expected error when body exceeds response limit and is not valid JSON")
	}
}

func TestDraftTimeLookupRespectsContextCancellation(t *testing.T) {
	server := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		<-r.Context().Done()
	}))
	defer server.Close()

	fetcher := newDraftTimeTestFetcher(t, server.URL, time.Now())
	ctx, cancel := context.WithCancel(context.Background())
	cancel()
	if _, err := fetcher.DraftTime(ctx, "1"); err == nil {
		t.Fatal("expected error when context is cancelled before request")
	}
}

func TestDraftTimeLookupPicksLatestOfMultipleDrafts(t *testing.T) {
	now := time.Date(2026, 1, 1, 0, 0, 0, 0, time.UTC)
	older := now.Add(-365 * 24 * time.Hour).UnixMilli()
	newer := now.Add(-30 * 24 * time.Hour).UnixMilli()
	mid := now.Add(-200 * 24 * time.Hour).UnixMilli()

	server := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Content-Type", "application/json")
		_ = json.NewEncoder(w).Encode([]sleeperDraft{
			{StartTime: older},
			{StartTime: mid},
			{StartTime: newer},
		})
	}))
	defer server.Close()

	fetcher := newDraftTimeTestFetcher(t, server.URL, now)
	got, err := fetcher.DraftTime(context.Background(), "1")
	if err != nil {
		t.Fatalf("DraftTime returned error: %v", err)
	}

	loc, err := time.LoadLocation("America/New_York")
	if err != nil {
		t.Fatalf("failed to load timezone: %v", err)
	}
	expected := time.UnixMilli(newer).UTC().In(loc)
	if !got.Equal(expected) {
		t.Fatalf("DraftTime = %s, want %s", got, expected)
	}
}

func TestDraftTimeLookupEmptyLeagueIDReturnsError(t *testing.T) {
	fetcher := newDraftTimeTestFetcher(t, "http://127.0.0.1:1", time.Now())
	if _, err := fetcher.DraftTime(context.Background(), ""); err == nil {
		t.Fatal("expected error when league id is empty")
	}
}
