package main

import (
	"database/sql"
	"fmt"
	"net/http"

	"github.com/Robert-litts/fantasy-football-archive/internal/validator"
	"github.com/Robert-litts/fantasy-football-archive/templates"
)

func (app *application) listDraftHandler(w http.ResponseWriter, r *http.Request) {
	id, err := app.readIDParam(r)
	if err != nil {
		app.notFoundResponse(w, r)
		return
	}

	app.logger.Info("attempting to fetch draft", "id", id)

	// Use the SQLC-generated query method
	// drafts, err := app.queries.GetDraftsByLeagueYear(r.Context(), int32(id))
	// if err != nil {
	// 	app.logger.Error("database error", "error", err)
	// 	if err == sql.ErrNoRows {
	// 		app.notFoundResponse(w, r)
	// 		return
	// 	}
	// 	app.serverErrorResponse(w, r, err)
	// 	return
	// }

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

	if r.Header.Get("HX-Request") == "true" {
		err = templates.DraftGrid(draftBoard, int(maxRoundNum), int(maxPickNum)).Render(r.Context(), w)
		if err != nil {
			app.serverErrorResponse(w, r, err)
		}
		return
	}

	err = app.writeJSON(w, http.StatusOK, envelope{"drafts": draftBoard}, nil)
	if err != nil {
		app.serverErrorResponse(w, r, err)
	}
}

func (app *application) draftBoardHandler(w http.ResponseWriter, r *http.Request) {
	id, err := app.readIDParam(r)
	if err != nil {
		app.notFoundResponse(w, r)
		return
	}
	fmt.Println(id)

	leagues, err := app.queries.GetAllLeagues(r.Context())
	if err != nil {
		app.logger.Error("database error", "error", err)
		if err == sql.ErrNoRows {
			app.notFoundResponse(w, r)
			return
		}
		app.serverErrorResponse(w, r, err)
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

	if r.Header.Get("HX-Request") == "true" {
		if r.Header.Get("HX-Target") == "draftboard-container" {
			err = templates.DraftBoard(draftBoard, leagues, int(id), int(maxRoundNum), int(maxPickNum)).Render(r.Context(), w)
		} else {
			err = templates.DraftBoardPage(draftBoard, leagues, int(id), int(maxRoundNum), int(maxPickNum)).Render(r.Context(), w)
		}
		if err != nil {
			app.serverErrorResponse(w, r, err)
		}
		return
	}
}

func (app *application) draftsListHandler(w http.ResponseWriter, r *http.Request) {
	leagues, err := app.queries.GetAllLeagues(r.Context())
	if err != nil {
		app.serverErrorResponse(w, r, err)
		return
	}

	if r.Header.Get("HX-Request") == "true" {
		err = templates.DraftPage(leagues).Render(r.Context(), w)
	}

	if err != nil {
		app.serverErrorResponse(w, r, err)
	}
}

func (app *application) draftDisplayHandler(w http.ResponseWriter, r *http.Request) {
	v := validator.New()
	qs := r.URL.Query()
	id := app.readIntQuery(qs, "id", v)
	fmt.Println(id)

	leagues, err := app.queries.GetAllLeagues(r.Context())
	if err != nil {
		app.logger.Error("database error", "error", err)
		if err == sql.ErrNoRows {
			app.notFoundResponse(w, r)
			return
		}
		app.serverErrorResponse(w, r, err)
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

	if r.Header.Get("HX-Request") == "true" {
		err = templates.DraftBoard(draftBoard, leagues, int(id), int(maxRoundNum), int(maxPickNum)).Render(r.Context(), w)
		if err != nil {
			app.serverErrorResponse(w, r, err)
		}
		return
	}
	err = app.writeJSON(w, http.StatusOK, envelope{"drafts": draftBoard}, nil)
	if err != nil {
		app.serverErrorResponse(w, r, err)
	}
}
