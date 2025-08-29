package main

import (
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"time"
	_ "time/tzdata"

	"github.com/Robert-litts/fantasy-football-archive/templates"
)

type draft struct {
	StartTime int64 `json:"start_time"`
}

func get_draft_time(leagueID string) (time.Time, error) {
	url := fmt.Sprintf("https://api.sleeper.app/v1/league/%s/drafts", leagueID)

	resp, err := http.Get(url)
	if err != nil {
		return time.Time{}, fmt.Errorf("HTTP request failed: %w", err)
	}
	defer resp.Body.Close()

	body, err := io.ReadAll(resp.Body)
	if err != nil {
		return time.Time{}, fmt.Errorf("failed to read response body: %w", err)
	}

	var drafts []draft
	if err := json.Unmarshal(body, &drafts); err != nil {
		return time.Time{}, fmt.Errorf("JSON unmarshal failed: %w", err)
	}

	if len(drafts) == 0 {
		return time.Time{}, fmt.Errorf("no drafts found for league %s", leagueID)
	}

	// Unix (milliseconds) to UTC
	utcTime := time.UnixMilli(drafts[0].StartTime).UTC()
	loc, err := time.LoadLocation("America/New_York")
	if err != nil {
		return time.Time{}, fmt.Errorf("failed to load timezone: %w", err)
	}

	// Convert to New York time
	nyTime := utcTime.In(loc)
	return nyTime, nil
}

func (app *application) homeHandler(w http.ResponseWriter, r *http.Request) {
	leagueID := "1257071510313517056"

	startTime, err := get_draft_time(leagueID)
	if err != nil {
		fmt.Println("Error:", err)
		return
	}

	t := time.Now()

	yearsRunning := t.Year() - 2013

	err = templates.Home(yearsRunning, startTime).Render(r.Context(), w)

	if err != nil {
		app.serverErrorResponse(w, r, err)
	}
}
