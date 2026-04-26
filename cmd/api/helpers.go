package main

import (
	"database/sql"
	"encoding/json"
	"errors"
	"fmt"
	"html/template"
	"io"
	"log"
	"net/http"
	"net/url"
	"os"
	"path/filepath"
	"strconv"
	"strings"
	"time"
	_ "time/tzdata"

	"github.com/Robert-litts/fantasy-football-archive/internal/validator"
	"github.com/joho/godotenv"
	"github.com/julienschmidt/httprouter"
)

type envelope map[string]any

func (app *application) readIDParam(r *http.Request) (int64, error) {
	params := httprouter.ParamsFromContext(r.Context())
	id, err := strconv.ParseInt(params.ByName("id"), 10, 64)
	if err != nil || id < 1 {
		return 0, errors.New("invalid ID parameter")
	}
	return id, nil
}

func (app *application) readWeekParam(r *http.Request) (int64, error) {
	params := httprouter.ParamsFromContext(r.Context())
	id, err := strconv.ParseInt(params.ByName("week"), 10, 64)
	if err != nil || id < 1 {
		return 0, errors.New("invalid Week parameter")
	}
	return id, nil
}

func (app *application) readProviderParam(r *http.Request) (string, error) {
	params := httprouter.ParamsFromContext(r.Context())
	provider := params.ByName("provider")

	if provider == "" {
		return "", errors.New("no provider specified")
	}
	return provider, nil
}

func (app *application) readJSON(w http.ResponseWriter, r *http.Request, dst any) error {
	maxBytes := 1_048_576
	r.Body = http.MaxBytesReader(w, r.Body, int64(maxBytes))
	dec := json.NewDecoder(r.Body)
	dec.DisallowUnknownFields()
	err := dec.Decode(dst)
	if err != nil {
		var syntaxError *json.SyntaxError
		var unmarshalTypeError *json.UnmarshalTypeError
		var invalidUnmarshalError *json.InvalidUnmarshalError
		var maxBytesError *http.MaxBytesError
		switch {
		case errors.As(err, &syntaxError):
			return fmt.Errorf("body contains badly-formed JSON (at character %d)", syntaxError.Offset)
		case errors.As(err, &unmarshalTypeError):
			if unmarshalTypeError.Field != "" {
				return fmt.Errorf("body contains incorrect JSON type for field %q", unmarshalTypeError.Field)
			}
			return fmt.Errorf("body contains incorrect JSON type (at character %d)", unmarshalTypeError.Offset)
		case errors.Is(err, io.ErrUnexpectedEOF):
			return errors.New("body must not be empty")
		case errors.As(err, &invalidUnmarshalError):
			panic(err)
		case strings.HasPrefix(err.Error(), "json: unknown field "):
			fieldName := strings.TrimPrefix(err.Error(), "json: unknown field ")
			return fmt.Errorf("body contains unknown key %s", fieldName)

		case errors.As(err, &maxBytesError):
			return fmt.Errorf("body must not be larger than %d bytes", maxBytesError.Limit)
		default:
			return err
		}
	}

	err = dec.Decode(&struct{}{})
	if !errors.Is(err, io.EOF) {
		return errors.New("body must only contain a single JSON value")
	}
	return nil
}

func (app *application) writeJSON(w http.ResponseWriter, status int, data envelope, headers http.Header) error {
	js, err := json.MarshalIndent(data, "", "\t")
	if err != nil {
		return err
	}
	js = append(js, '\n')
	for key, value := range headers {
		w.Header()[key] = value
	}
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(status)
	w.Write(js)

	return nil
}

func (app *application) readString(qs url.Values, key string, defaultValue string) string {
	s := qs.Get(key)
	if s == "" {
		return defaultValue
	}
	return s
}
func (app *application) readCSV(qs url.Values, key string, defaultValue []string) []string {
	csv := qs.Get(key)
	if csv == "" {
		return defaultValue
	}
	return strings.Split(csv, ",")
}

func (app *application) readInt(qs url.Values, key string, defaultValue int, v *validator.Validator) int {
	s := qs.Get(key)
	if s == "" {
		return defaultValue
	}
	i, err := strconv.Atoi(s)
	if err != nil {
		v.AddError(key, "must be an integer value")
		return defaultValue
	}
	return i
}

func (app *application) readIntQuery(qs url.Values, key string, v *validator.Validator) int32 {
	s := qs.Get(key)
	if s == "" {
		return -1 // Sentinel value to indicate "no value"
	}
	i, err := strconv.Atoi(s)
	if err != nil {
		v.AddError(key, "must be an integer value")
		return -1 // Return sentinel value on error
	}
	return int32(i) // Return the valid int32 value
}

func parseOwnerAliasesJSON(raw string) (map[string]string, error) {
	if strings.TrimSpace(raw) == "" {
		return map[string]string{}, nil
	}

	aliases := make(map[string]string)
	if err := json.Unmarshal([]byte(raw), &aliases); err != nil {
		return nil, fmt.Errorf("invalid OWNER_ALIASES_JSON: %w", err)
	}

	normalizedAliases := make(map[string]string, len(aliases))
	for alias, canonical := range aliases {
		normalizedAlias := strings.Join(strings.Fields(strings.TrimSpace(alias)), " ")
		normalizedCanonical := strings.Join(strings.Fields(strings.TrimSpace(canonical)), " ")
		if normalizedAlias == "" || normalizedCanonical == "" {
			return nil, errors.New("invalid OWNER_ALIASES_JSON: aliases and canonical names must be non-empty")
		}
		normalizedAliases[normalizedAlias] = normalizedCanonical
	}

	return normalizedAliases, nil
}

func loadEnvironment() (string, string, int, string, map[string]string, string, string, int, int, time.Duration, string, string, string, string, int) {
	if err := godotenv.Load(); err != nil {
		log.Println("No .env found, using system .env variables")
	}
	leagueID := os.Getenv("SLEEPER_LEAGUE_ID")
	if leagueID == "" {
		log.Fatal("Sleeper League ID environment variable not set")
	}
	baseCallbackURL := os.Getenv("BASE_CALLBACK_URL")
	if baseCallbackURL == "" {
		log.Fatal("Base Callback URL environment variable not set")
	}

	port, err := strconv.Atoi(os.Getenv("PORT"))
	if err != nil {
		log.Fatal("PORT environment variable not set")
	}
	env := os.Getenv("ENV")
	if env == "" {
		log.Fatal("ENV environment variable not set")
	}

	ownerAliases, err := parseOwnerAliasesJSON(os.Getenv("OWNER_ALIASES_JSON"))
	if err != nil {
		log.Fatal(err)
	}

	dsn := os.Getenv("ESPN_DATABASE_URL")
	if dsn == "" {
		dsn = os.Getenv("DB_URL")
	}
	if dsn == "" {
		log.Fatal("ESPN_DATABASE_URL or DB_URL environment variable not set")
	}

	sleeperDSN := os.Getenv("SLEEPER_DATABASE_URL")

	dbMaxOpenConns, err := strconv.Atoi(os.Getenv("DB_MAX_OPEN_CONNS"))
	if err != nil {
		log.Fatal("DB_MAX_OPEN_CONNS environment variable not set")
	}
	dbMaxIdleConns, err := strconv.Atoi(os.Getenv("DB_MAX_IDLE_CONNS"))
	if err != nil {
		log.Fatal("DB_MAX_IDLE_CONNS environment variable not set")
	}
	dbMaxIdleTime, err := time.ParseDuration(os.Getenv("DB_MAX_IDLE_TIME"))
	if err != nil {
		log.Fatal("DB_MAX_IDLE_TIME environment variable not set")
	}

	sessionKey := os.Getenv("SESSION_KEY")
	if sessionKey == "" {
		log.Fatal("SESSION_KEY must be set")
	}

	sendGridKey := os.Getenv("SENDGRID_API_KEY")
	if sendGridKey == "" {
		log.Fatal("SENDGRID_API_KEY environment variable is required")
	}

	redisAddr := os.Getenv("REDIS_ADDR")
	redisPassword := os.Getenv("REDIS_PASSWORD")
	redisDB, err := strconv.Atoi(os.Getenv("REDIS_DB"))
	if err != nil {
		log.Fatal("Failed to convert redisDB to int")
	}

	//return the env variables
	return leagueID, baseCallbackURL, port, env, ownerAliases, dsn, sleeperDSN, dbMaxOpenConns, dbMaxIdleConns, dbMaxIdleTime, sessionKey, sendGridKey, redisAddr, redisPassword, redisDB
}

// The background() helper accepts an arbitrary function as a parameter.
func (app *application) background(fn func()) {
	// Increment the WaitGroup counter.
	app.wg.Add(1)
	go func() {
		// Recover any panic.

		defer app.wg.Done()

		defer func() {
			if err := recover(); err != nil {
				app.logger.Error(fmt.Sprintf("%v", err))
			}
		}()

		// Execute the arbitrary function that we passed as the parameter.
		fn()
	}()
}

func (app *application) invalidAuthenticationTokenResponse(w http.ResponseWriter, r *http.Request) {
	message := "invalid or missing authentication token"
	app.errorResponse(w, r, http.StatusUnauthorized, message)
}

func (app *application) renderTemplate(w http.ResponseWriter, name string, data interface{}) error {
	templates := make(map[string]*template.Template)

	// Define the paths for different template types
	templatePaths := []string{
		filepath.Join("ui", "html", "base.tmpl"),
		filepath.Join("ui", "html", name),
	}

	// If we're rendering the dashboard or leagues, we also need their respective partial templates
	switch name {
	case "dashboard.tmpl", "dashboard-partial.tmpl":
		templatePaths = append(templatePaths, filepath.Join("ui", "html", "dashboard-partial.tmpl"))
	case "leagues.tmpl", "leagues-partial.tmpl":
		templatePaths = append(templatePaths, filepath.Join("ui", "html", "leagues-partial.tmpl"))
	}

	// Log the templates we're attempting to parse
	app.logger.Info("parsing templates",
		"paths", templatePaths)

	// Parse all required templates
	tmpl, err := template.ParseFiles(templatePaths...)
	if err != nil {
		// Log the error with detailed information
		app.logger.Error("template parsing failed",
			"error", err,
			"paths", templatePaths)
		return fmt.Errorf("error parsing template files: %w", err)
	}

	// Store the template in our cache
	templates[name] = tmpl

	// Execute the appropriate template based on the type
	switch name {
	case "dashboard-partial.tmpl":
		err = tmpl.ExecuteTemplate(w, "user-info", data)
	case "leagues-partial.tmpl":
		err = tmpl.ExecuteTemplate(w, "leagues-table", data)
	default:
		// For full pages, we execute the base template
		err = tmpl.ExecuteTemplate(w, "base", data)
	}

	if err != nil {
		app.logger.Error("template execution failed",
			"error", err,
			"template", name)
		return fmt.Errorf("error executing template: %w", err)
	}

	return nil
}

// NewNullString converts a string to sql.NullString
func NewNullString(s string) sql.NullString {
	if s == "" {
		return sql.NullString{Valid: false}
	}
	return sql.NullString{String: s, Valid: true}
}

// ToNullString converts *string to sql.NullString
func ToNullString(s *string) sql.NullString {
	if s == nil {
		return sql.NullString{Valid: false}
	}
	return sql.NullString{String: *s, Valid: true}
}

// FromNullString converts sql.NullString to *string
func FromNullString(ns sql.NullString) *string {
	if !ns.Valid {
		return nil
	}
	return &ns.String
}

type sleeper_draft struct {
	StartTime int64 `json:"start_time"`
}

func Get_draft_time(leagueID string) (time.Time, error) {
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

	var drafts []sleeper_draft
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
