package main

import (
	"context"
	"database/sql"
	"encoding/json"
	"errors"
	"fmt"
	"net/http"
	"strconv"
	"strings"
	"sync"
	"time"

	"github.com/Robert-litts/fantasy-football-archive/internal/archive"
	"github.com/Robert-litts/fantasy-football-archive/internal/db"
	draftsview "github.com/Robert-litts/fantasy-football-archive/internal/draftsview"
	"github.com/Robert-litts/fantasy-football-archive/internal/sleeperdb"
	"github.com/Robert-litts/fantasy-football-archive/templates"
)

type draftsArchiveLister interface {
	ListLeagueSummaries(context.Context) (archive.LeagueList, error)
}

type draftsESPNLister interface {
	GetDraftBoardWithSummary(context.Context, int32) ([]db.GetDraftBoardWithSummaryRow, error)
}

type draftsSleeperLister interface {
	ListDraftPicksByLeague(context.Context, int64) ([]sleeperdb.ListDraftPicksByLeagueRow, error)
}

type draftsSleeperPositionLister interface {
	ListPlayerPositionsByESPNIDs(context.Context, []string) ([]sleeperdb.PlayerPositionByESPNID, error)
}

var errInvalidDraftsQuery = errors.New("invalid query parameters")

var espnDraftPositionCache = struct {
	sync.Mutex
	positions map[string]string
	misses    map[string]bool
}{
	positions: make(map[string]string),
	misses:    make(map[string]bool),
}

var loadESPNAthletePositionsFunc = loadESPNAthletePositions

func draftBoardDimensions(draftBoard []draftsview.PickRow) (int, int) {
	maxRoundNum := int32(0)
	maxPickNum := int32(0)
	for _, draft := range draftBoard {
		if draft.RoundNum > maxRoundNum {
			maxRoundNum = draft.RoundNum
		}
		if draft.RoundPick > maxPickNum {
			maxPickNum = draft.RoundPick
		}
	}
	return int(maxRoundNum), int(maxPickNum)
}

func (app *application) apiListLeagueDraftsHandler(w http.ResponseWriter, r *http.Request) {
	id, err := app.readIDParam(r)
	if err != nil {
		app.notFoundResponse(w, r)
		return
	}

	app.logger.Info("attempting to fetch draft", "id", id)

	draftBoard, err := app.queries.GetDraftBoardWithSummary(r.Context(), int32(id))
	if err != nil {
		app.logger.Error("database error", "error", err)
		if err == sql.ErrNoRows {
			app.notFoundResponse(w, r)
			return
		}
		app.serverErrorResponse(w, r, err)
		return
	}

	if err := app.writeJSON(w, http.StatusOK, envelope{"drafts": draftBoard}, nil); err != nil {
		app.serverErrorResponse(w, r, err)
	}
}

func (app *application) listDraftHandler(w http.ResponseWriter, r *http.Request) {
	id, err := app.readIDParam(r)
	if err != nil {
		app.notFoundResponse(w, r)
		return
	}

	if r.Header.Get("HX-Request") == "true" {
		page, err := buildDraftsPageData(r.Context(), app.archive, app.queries, app.sleeperQueries, espnDraftSelectionKey(id))
		if err != nil {
			app.handleDraftsPageError(w, r, err)
			return
		}
		if err := templates.DraftContent(page).Render(r.Context(), w); err != nil {
			app.serverErrorResponse(w, r, err)
		}
		return
	}

	draftBoard, err := app.queries.GetDraftBoardWithSummary(r.Context(), int32(id))
	if err != nil {
		app.logger.Error("database error", "error", err)
		if err == sql.ErrNoRows {
			app.notFoundResponse(w, r)
			return
		}
		app.serverErrorResponse(w, r, err)
		return
	}

	if err := app.writeJSON(w, http.StatusOK, envelope{"drafts": draftBoard}, nil); err != nil {
		app.serverErrorResponse(w, r, err)
	}
}

func (app *application) draftBoardHandler(w http.ResponseWriter, r *http.Request) {
	id, err := app.readIDParam(r)
	if err != nil {
		app.notFoundResponse(w, r)
		return
	}

	page, err := buildDraftsPageData(r.Context(), app.archive, app.queries, app.sleeperQueries, espnDraftSelectionKey(id))
	if err != nil {
		app.handleDraftsPageError(w, r, err)
		return
	}

	if r.Header.Get("HX-Request") == "true" {
		if r.Header.Get("HX-Target") == "draftboard-container" {
			err = templates.DraftBoard(page).Render(r.Context(), w)
		} else {
			err = templates.Drafts(page).Render(r.Context(), w)
		}
		if err != nil {
			app.serverErrorResponse(w, r, err)
		}
		return
	}

	if err := templates.Base(templates.Drafts(page)).Render(r.Context(), w); err != nil {
		app.serverErrorResponse(w, r, err)
	}
}

func (app *application) appDraftsPageHandler(w http.ResponseWriter, r *http.Request) {
	page, err := app.draftsPageData(r)
	if err != nil {
		app.handleDraftsPageError(w, r, err)
		return
	}

	if err := templates.Drafts(page).Render(r.Context(), w); err != nil {
		app.serverErrorResponse(w, r, err)
	}
}

func (app *application) draftsListHandler(w http.ResponseWriter, r *http.Request) {
	page, err := app.draftsPageData(r)
	if err != nil {
		app.handleDraftsPageError(w, r, err)
		return
	}

	if r.Header.Get("HX-Request") == "true" {
		if err := templates.Drafts(page).Render(r.Context(), w); err != nil {
			app.serverErrorResponse(w, r, err)
		}
		return
	}

	if err := templates.Base(templates.Drafts(page)).Render(r.Context(), w); err != nil {
		app.serverErrorResponse(w, r, err)
	}
}

func (app *application) draftDisplayHandler(w http.ResponseWriter, r *http.Request) {
	page, err := app.draftsPageData(r)
	if err != nil {
		app.handleDraftsPageError(w, r, err)
		return
	}

	if r.Header.Get("HX-Request") == "true" {
		if err := templates.DraftContent(page).Render(r.Context(), w); err != nil {
			app.serverErrorResponse(w, r, err)
		}
		return
	}

	if err := templates.Base(templates.Drafts(page)).Render(r.Context(), w); err != nil {
		app.serverErrorResponse(w, r, err)
	}
}

func (app *application) appDraftBoardFragmentHandler(w http.ResponseWriter, r *http.Request) {
	page, err := app.draftsPageData(r)
	if err != nil {
		app.handleDraftsPageError(w, r, err)
		return
	}

	if err := templates.DraftContent(page).Render(r.Context(), w); err != nil {
		app.serverErrorResponse(w, r, err)
	}
}

func (app *application) appDraftBoardByIDFragmentHandler(w http.ResponseWriter, r *http.Request) {
	id, err := app.readIDParam(r)
	if err != nil {
		app.notFoundResponse(w, r)
		return
	}

	page, err := buildDraftsPageData(r.Context(), app.archive, app.queries, app.sleeperQueries, espnDraftSelectionKey(id))
	if err != nil {
		app.handleDraftsPageError(w, r, err)
		return
	}

	if err := templates.DraftContent(page).Render(r.Context(), w); err != nil {
		app.serverErrorResponse(w, r, err)
	}
}

func (app *application) draftsPageData(r *http.Request) (draftsview.PageData, error) {
	selectedLeagueKey, err := normalizeDraftSelectionKey(strings.TrimSpace(r.URL.Query().Get("id")))
	if err != nil {
		return draftsview.PageData{}, errInvalidDraftsQuery
	}

	return buildDraftsPageData(r.Context(), app.archive, app.queries, app.sleeperQueries, selectedLeagueKey)
}

func normalizeDraftSelectionKey(value string) (string, error) {
	if value == "" {
		return "", nil
	}
	if strings.Contains(value, ":") {
		if _, _, err := parseArchiveLeagueSelectionKey(value); err != nil {
			return "", err
		}
		return value, nil
	}

	id, err := strconv.ParseInt(value, 10, 64)
	if err != nil || id < 1 {
		return "", errors.New("invalid league id")
	}
	return fmt.Sprintf("%s:%d", archive.ProviderESPN, id), nil
}

func espnDraftSelectionKey(id int64) string {
	return fmt.Sprintf("%s:%d", archive.ProviderESPN, id)
}

func (app *application) handleDraftsPageError(w http.ResponseWriter, r *http.Request, err error) {
	if errors.Is(err, errInvalidDraftsQuery) {
		app.badRequestResponse(w, r, err)
		return
	}
	app.serverErrorResponse(w, r, err)
}

func buildDraftsPageData(
	ctx context.Context,
	archiveLister draftsArchiveLister,
	espnLister draftsESPNLister,
	sleeperLister draftsSleeperLister,
	selectedLeagueKey string,
) (draftsview.PageData, error) {
	page := draftsview.PageData{}

	if archiveLister == nil {
		return page, sql.ErrConnDone
	}

	leagueList, err := archiveLister.ListLeagueSummaries(ctx)
	if err != nil {
		return page, err
	}

	page.Leagues = leagueList.Leagues
	page.SleeperAvailable = leagueList.SleeperAvailable
	page.SleeperMessage = leagueList.SleeperMessage

	if len(page.Leagues) == 0 {
		return page, nil
	}

	selected := page.Leagues[0]
	if selectedLeagueKey != "" {
		if found, ok := findLeagueSummaryByKey(page.Leagues, selectedLeagueKey); ok {
			selected = found
		}
	}
	page.SelectedLeague = selected
	page.SelectedLeagueKey = archiveLeagueSelectionKey(selected)
	page.TeamCount = selected.TeamCount

	picks, sleeperMessage, err := loadDraftsForLeague(ctx, selected, espnLister, sleeperLister)
	if sleeperMessage != "" {
		page.SleeperMessage = sleeperMessage
	}
	if err != nil {
		return page, err
	}

	page.Picks = picks
	page.MaxRounds, page.MaxPicks = draftBoardDimensions(picks)
	if page.TeamCount == 0 && page.MaxPicks > 0 {
		page.TeamCount = int32(page.MaxPicks)
	}

	return page, nil
}

func loadDraftsForLeague(
	ctx context.Context,
	league archive.LeagueSummary,
	espnLister draftsESPNLister,
	sleeperLister draftsSleeperLister,
) ([]draftsview.PickRow, string, error) {
	switch league.Provider {
	case archive.ProviderESPN:
		if espnLister == nil {
			return nil, "", sql.ErrConnDone
		}

		rows, err := espnLister.GetDraftBoardWithSummary(ctx, int32(league.ID))
		if err != nil {
			if errors.Is(err, sql.ErrNoRows) {
				return nil, "", nil
			}
			return nil, "", err
		}
		picks := normalizeESPNDraftRows(rows)
		applyESPNDraftPositionFallback(ctx, picks, sleeperPositionLister(sleeperLister))
		return picks, "", nil

	case archive.ProviderSleeper:
		if sleeperLister == nil {
			return nil, "Sleeper archive database is not configured", nil
		}

		rows, err := sleeperLister.ListDraftPicksByLeague(ctx, league.ID)
		if err != nil {
			if errors.Is(err, sql.ErrNoRows) {
				return nil, "", nil
			}
			return nil, "Sleeper draft data is temporarily unavailable", nil
		}
		return normalizeSleeperDraftRows(rows), "", nil
	default:
		return nil, "", fmt.Errorf("unsupported league provider %q", league.Provider)
	}
}

func normalizeESPNDraftRows(rows []db.GetDraftBoardWithSummaryRow) []draftsview.PickRow {
	picks := make([]draftsview.PickRow, 0, len(rows))
	for _, row := range rows {
		picks = append(picks, draftsview.PickRow{
			OverallPick:  row.OverallPick,
			RoundNum:     row.RoundNum,
			RoundPick:    row.RoundPick,
			TeamName:     strings.TrimSpace(row.TeamName),
			PlayerName:   strings.TrimSpace(row.PlayerName),
			PlayerESPNID: strconv.Itoa(int(row.PlayerEspnID)),
			Position:     normalizeDraftPosition(row.PlayerPosition.String),
		})
	}
	return picks
}

func normalizeSleeperDraftRows(rows []sleeperdb.ListDraftPicksByLeagueRow) []draftsview.PickRow {
	picks := make([]draftsview.PickRow, 0, len(rows))
	for _, row := range rows {
		picks = append(picks, draftsview.PickRow{
			OverallPick:  row.OverallPick,
			RoundNum:     row.RoundNum,
			RoundPick:    row.RoundPick,
			TeamName:     strings.TrimSpace(row.TeamName),
			PlayerName:   sleeperDraftPlayerName(row),
			PlayerESPNID: sleeperDraftESPNID(row),
			Position:     normalizeDraftPosition(row.Position.String),
			KeeperStatus: row.KeeperStatus,
		})
	}
	return picks
}

func normalizeDraftPosition(position string) string {
	normalized := strings.ToUpper(strings.TrimSpace(position))
	normalized = strings.ReplaceAll(normalized, "_", " ")
	normalized = strings.ReplaceAll(normalized, "-", " ")
	normalized = strings.Join(strings.Fields(normalized), " ")

	switch normalized {
	case "QB", "0", "1", "QUARTERBACK":
		return "QB"
	case "RB", "2", "RUNNING BACK":
		return "RB"
	case "WR", "3", "4", "WIDE RECEIVER":
		return "WR"
	case "TE", "5", "6", "TIGHT END":
		return "TE"
	case "K", "17", "KICKER":
		return "K"
	case "DEF", "DST", "D/ST", "16", "D ST", "DEFENSE", "DEFENSE SPECIAL TEAMS":
		return "D/ST"
	default:
		return normalized
	}
}

func sleeperPositionLister(sleeperLister draftsSleeperLister) draftsSleeperPositionLister {
	positionLister, _ := sleeperLister.(draftsSleeperPositionLister)
	return positionLister
}

func applyESPNDraftPositionFallback(ctx context.Context, picks []draftsview.PickRow, sleeperPositionLister draftsSleeperPositionLister) {
	ids := make([]string, 0)
	seen := make(map[string]bool)
	for _, pick := range picks {
		if pick.Position == "" && pick.PlayerESPNID != "" && pick.PlayerESPNID != "0" {
			if !seen[pick.PlayerESPNID] {
				ids = append(ids, pick.PlayerESPNID)
				seen[pick.PlayerESPNID] = true
			}
		}
	}
	if len(ids) == 0 {
		return
	}

	positions := loadSleeperPlayerPositions(ctx, sleeperPositionLister, ids)
	missingIDs := missingDraftPositionIDs(ids, positions)
	if len(missingIDs) > 0 {
		apiPositions, err := loadESPNAthletePositionsFunc(ctx, missingIDs)
		if err == nil {
			for id, position := range apiPositions {
				positions[id] = position
			}
		}
	}
	for i := range picks {
		if picks[i].Position != "" {
			continue
		}
		if position := positions[picks[i].PlayerESPNID]; position != "" {
			picks[i].Position = position
		}
	}
}

func loadSleeperPlayerPositions(ctx context.Context, sleeperPositionLister draftsSleeperPositionLister, espnIDs []string) map[string]string {
	positions := make(map[string]string)
	if sleeperPositionLister == nil {
		return positions
	}

	rows, err := sleeperPositionLister.ListPlayerPositionsByESPNIDs(ctx, espnIDs)
	if err != nil {
		return positions
	}
	for _, row := range rows {
		id := strings.TrimSpace(row.ESPNID)
		position := normalizeDraftPosition(row.Position.String)
		if id != "" && position != "" {
			positions[id] = position
		}
	}
	return positions
}

func missingDraftPositionIDs(espnIDs []string, positions map[string]string) []string {
	missing := make([]string, 0)
	for _, id := range espnIDs {
		if positions[id] == "" {
			missing = append(missing, id)
		}
	}
	return missing
}

func loadESPNAthletePositions(ctx context.Context, espnIDs []string) (map[string]string, error) {
	espnDraftPositionCache.Lock()
	positions := make(map[string]string, len(espnIDs))
	missingIDs := make([]string, 0)
	for _, id := range espnIDs {
		if position := espnDraftPositionCache.positions[id]; position != "" {
			positions[id] = position
			continue
		}
		if !espnDraftPositionCache.misses[id] {
			missingIDs = append(missingIDs, id)
		}
	}
	espnDraftPositionCache.Unlock()

	if len(missingIDs) == 0 {
		return positions, nil
	}

	fetched, misses, err := fetchESPNAthletePositions(ctx, missingIDs)
	if err != nil {
		return positions, err
	}

	espnDraftPositionCache.Lock()
	for id, position := range fetched {
		espnDraftPositionCache.positions[id] = position
		positions[id] = position
	}
	for _, id := range misses {
		espnDraftPositionCache.misses[id] = true
	}
	espnDraftPositionCache.Unlock()

	return positions, nil
}

type espnAthlete struct {
	ID       json.RawMessage `json:"id"`
	Position json.RawMessage `json:"position"`
}

func fetchESPNAthletePositions(ctx context.Context, espnIDs []string) (map[string]string, []string, error) {
	requestCtx, cancel := context.WithTimeout(ctx, 5*time.Second)
	defer cancel()

	type athletePositionResult struct {
		id       string
		position string
	}

	positions := make(map[string]string, len(espnIDs))
	misses := make([]string, 0)
	results := make(chan athletePositionResult, len(espnIDs))
	var wg sync.WaitGroup
	sem := make(chan struct{}, 8)

	for _, espnID := range espnIDs {
		wg.Add(1)
		go func(id string) {
			defer wg.Done()
			select {
			case sem <- struct{}{}:
				defer func() { <-sem }()
			case <-requestCtx.Done():
				results <- athletePositionResult{id: id}
				return
			}

			position := fetchESPNAthletePosition(requestCtx, id)
			results <- athletePositionResult{id: id, position: position}
		}(espnID)
	}

	wg.Wait()
	close(results)

	for result := range results {
		if result.position != "" {
			positions[result.id] = result.position
		} else {
			misses = append(misses, result.id)
		}
	}
	return positions, misses, nil
}

func fetchESPNAthletePosition(ctx context.Context, espnID string) string {
	req, err := http.NewRequestWithContext(ctx, http.MethodGet, fmt.Sprintf("https://sports.core.api.espn.com/v2/sports/football/leagues/nfl/athletes/%s?lang=en&region=us", espnID), nil)
	if err != nil {
		return ""
	}

	resp, err := http.DefaultClient.Do(req)
	if err != nil {
		return ""
	}
	defer resp.Body.Close()
	if resp.StatusCode < http.StatusOK || resp.StatusCode >= http.StatusMultipleChoices {
		return ""
	}

	var athlete espnAthlete
	if err := json.NewDecoder(resp.Body).Decode(&athlete); err != nil {
		return ""
	}
	return espnAthletePosition(athlete.Position)
}

func espnAthletePosition(value json.RawMessage) string {
	var position string
	if err := json.Unmarshal(value, &position); err == nil {
		return normalizeDraftPosition(position)
	}

	var object struct {
		Abbreviation string `json:"abbreviation"`
		Name         string `json:"name"`
		DisplayName  string `json:"displayName"`
	}
	if err := json.Unmarshal(value, &object); err != nil {
		return ""
	}

	if position := normalizeDraftPosition(object.Abbreviation); position != "" {
		return position
	}
	if position := normalizeDraftPosition(object.Name); position != "" {
		return position
	}
	return normalizeDraftPosition(object.DisplayName)
}

func sleeperDraftPlayerName(row sleeperdb.ListDraftPicksByLeagueRow) string {
	firstName := strings.TrimSpace(row.FirstName.String)
	lastName := strings.TrimSpace(row.LastName.String)
	if firstName != "" || lastName != "" {
		return strings.TrimSpace(strings.Join([]string{firstName, lastName}, " "))
	}
	return strings.TrimSpace(row.PlayerName)
}

func sleeperDraftESPNID(row sleeperdb.ListDraftPicksByLeagueRow) string {
	if !row.EspnID.Valid {
		return ""
	}
	return strings.TrimSpace(row.EspnID.String)
}
