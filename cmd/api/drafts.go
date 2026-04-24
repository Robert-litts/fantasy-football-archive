package main

import (
	"database/sql"
	"errors"
	"net/http"

	"github.com/Robert-litts/fantasy-football-archive/internal/db"
	"github.com/Robert-litts/fantasy-football-archive/internal/validator"
	"github.com/Robert-litts/fantasy-football-archive/templates"
)

func draftBoardDimensions(draftBoard []db.GetDraftBoardWithSummaryRow) (int, int) {
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

	err = app.writeJSON(w, http.StatusOK, envelope{"drafts": draftBoard}, nil)
	if err != nil {
		app.serverErrorResponse(w, r, err)
	}
}

func (app *application) listDraftHandler(w http.ResponseWriter, r *http.Request) {
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
	maxRoundNum, maxPickNum := draftBoardDimensions(draftBoard)

	if r.Header.Get("HX-Request") == "true" {
		err = templates.DraftGrid(draftBoard, maxRoundNum, maxPickNum).Render(r.Context(), w)
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
	maxRoundNum, maxPickNum := draftBoardDimensions(draftBoard)

	if r.Header.Get("HX-Request") == "true" {
		if r.Header.Get("HX-Target") == "draftboard-container" {
			err = templates.DraftBoard(draftBoard, leagues, int(id), maxRoundNum, maxPickNum).Render(r.Context(), w)
		} else {
			err = templates.DraftBoardPage(draftBoard, leagues, int(id), maxRoundNum, maxPickNum).Render(r.Context(), w)
		}
		if err != nil {
			app.serverErrorResponse(w, r, err)
		}
		return
	}
}

func (app *application) appDraftsPageHandler(w http.ResponseWriter, r *http.Request) {
	leagues, err := app.queries.GetAllLeagues(r.Context())
	if err != nil {
		app.serverErrorResponse(w, r, err)
		return
	}

	err = templates.DraftPage(leagues).Render(r.Context(), w)
	if err != nil {
		app.serverErrorResponse(w, r, err)
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
		if err != nil {
			app.serverErrorResponse(w, r, err)
		}
	}
}

func (app *application) draftDisplayHandler(w http.ResponseWriter, r *http.Request) {
	v := validator.New()
	qs := r.URL.Query()
	id := app.readIntQuery(qs, "id", v)

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
	maxRoundNum, maxPickNum := draftBoardDimensions(draftBoard)

	if r.Header.Get("HX-Request") == "true" {
		err = templates.DraftBoard(draftBoard, leagues, int(id), maxRoundNum, maxPickNum).Render(r.Context(), w)
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

func (app *application) appDraftBoardFragmentHandler(w http.ResponseWriter, r *http.Request) {
	v := validator.New()
	qs := r.URL.Query()
	id := app.readIntQuery(qs, "id", v)
	if !v.Valid() || id < 1 {
		app.badRequestResponse(w, r, errors.New("valid id query parameter is required"))
		return
	}

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

	draftBoard, err := app.queries.GetDraftBoardWithSummary(r.Context(), id)
	if err != nil {
		app.logger.Error("database error", "error", err)
		if err == sql.ErrNoRows {
			app.notFoundResponse(w, r)
			return
		}
		app.serverErrorResponse(w, r, err)
		return
	}

	maxRoundNum, maxPickNum := draftBoardDimensions(draftBoard)
	err = templates.DraftBoard(draftBoard, leagues, int(id), maxRoundNum, maxPickNum).Render(r.Context(), w)
	if err != nil {
		app.serverErrorResponse(w, r, err)
	}
}

func (app *application) appDraftBoardByIDFragmentHandler(w http.ResponseWriter, r *http.Request) {
	id, err := app.readIDParam(r)
	if err != nil {
		app.notFoundResponse(w, r)
		return
	}

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

	maxRoundNum, maxPickNum := draftBoardDimensions(draftBoard)
	err = templates.DraftBoardPage(draftBoard, leagues, int(id), maxRoundNum, maxPickNum).Render(r.Context(), w)
	if err != nil {
		app.serverErrorResponse(w, r, err)
	}
}
