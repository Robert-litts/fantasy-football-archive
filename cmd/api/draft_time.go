package main

import (
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"io"
	"log/slog"
	"net/http"
	"time"
	_ "time/tzdata"
)

const draftTimeResponseLimit int64 = 64 * 1024

// DraftTimeLookup resolves the next (or most recent) draft time for a Sleeper
// league. It is intentionally injectable so handlers can swap in fakes during
// tests and so failures are surfaced as plain errors instead of panics.
type DraftTimeLookup interface {
	DraftTime(ctx context.Context, leagueID string) (time.Time, error)
}

type draftTimeFetcher struct {
	client  *http.Client
	logger  *slog.Logger
	now     func() time.Time
	baseURL string
}

// NewDraftTimeLookup returns a DraftTimeLookup backed by the Sleeper HTTP API.
// Requests use a 5 second timeout. Failures are logged but never panic.
func NewDraftTimeLookup(logger *slog.Logger) DraftTimeLookup {
	return &draftTimeFetcher{
		client:  &http.Client{Timeout: 5 * time.Second},
		logger:  logger,
		now:     time.Now,
		baseURL: "https://api.sleeper.app/v1/league/%s/drafts",
	}
}

type sleeperDraft struct {
	DraftID   string `json:"draft_id"`
	Status    string `json:"status"`
	StartTime int64  `json:"start_time"`
}

func (f *draftTimeFetcher) DraftTime(ctx context.Context, leagueID string) (time.Time, error) {
	if leagueID == "" {
		return time.Time{}, errors.New("league id is required")
	}

	base := f.baseURL
	if base == "" {
		base = "https://api.sleeper.app/v1/league/%s/drafts"
	}
	url := fmt.Sprintf(base, leagueID)
	req, err := http.NewRequestWithContext(ctx, http.MethodGet, url, nil)
	if err != nil {
		f.logWarn(ctx, "failed to build sleeper draft request", "error", err, "league_id", leagueID)
		return time.Time{}, fmt.Errorf("build request: %w", err)
	}

	resp, err := f.client.Do(req)
	if err != nil {
		f.logWarn(ctx, "sleeper draft request failed", "error", err, "league_id", leagueID)
		return time.Time{}, fmt.Errorf("http request: %w", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode < 200 || resp.StatusCode >= 300 {
		f.logWarn(ctx, "sleeper draft request returned non-2xx",
			"status", resp.StatusCode, "league_id", leagueID)
		return time.Time{}, fmt.Errorf("unexpected status %d", resp.StatusCode)
	}

	body, err := io.ReadAll(io.LimitReader(resp.Body, draftTimeResponseLimit))
	if err != nil {
		f.logWarn(ctx, "failed to read sleeper draft response", "error", err, "league_id", leagueID)
		return time.Time{}, fmt.Errorf("read body: %w", err)
	}

	var drafts []sleeperDraft
	if err := json.Unmarshal(body, &drafts); err != nil {
		f.logWarn(ctx, "failed to parse sleeper draft response", "error", err, "league_id", leagueID)
		return time.Time{}, fmt.Errorf("decode drafts: %w", err)
	}

	if len(drafts) == 0 {
		f.logWarn(ctx, "no drafts returned for sleeper league", "league_id", leagueID)
		return time.Time{}, errors.New("no drafts returned")
	}

	loc, err := time.LoadLocation("America/New_York")
	if err != nil {
		f.logWarn(ctx, "failed to load America/New_York timezone", "error", err)
		return time.Time{}, fmt.Errorf("load timezone: %w", err)
	}

	now := f.now()
	var upcoming *sleeperDraft
	var latest *sleeperDraft
	for i := range drafts {
		draft := &drafts[i]
		start := time.UnixMilli(draft.StartTime).UTC()
		if latest == nil || draft.StartTime > latest.StartTime {
			latest = draft
		}
		if !start.Before(now) {
			if upcoming == nil || draft.StartTime > upcoming.StartTime {
				upcoming = draft
			}
		}
	}

	selected := upcoming
	if selected == nil {
		selected = latest
	}

	return time.UnixMilli(selected.StartTime).UTC().In(loc), nil
}

func (f *draftTimeFetcher) logWarn(ctx context.Context, msg string, args ...any) {
	if f.logger == nil {
		return
	}
	allArgs := append([]any{"ctx_err", ctx.Err()}, args...)
	f.logger.Warn(msg, allArgs...)
}
