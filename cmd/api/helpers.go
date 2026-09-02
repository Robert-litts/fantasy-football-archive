package main

import (
	"database/sql"
	"encoding/json"
	"errors"
	"fmt"
	"log"
	"net/http"
	"net/url"
	"os"
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

	return normalizeOwnerAliasMap(aliases, "OWNER_ALIASES_JSON")
}

func loadEnvironment() (string, string, string, int, string, map[string]string, string, string, string, int, int, time.Duration, string, string, string, string, int) {
	if err := godotenv.Load(); err != nil {
		log.Println("No .env found, using system .env variables")
	}
	leagueID := os.Getenv("SLEEPER_LEAGUE_ID")
	if leagueID == "" {
		log.Println("WARNING: SLEEPER_LEAGUE_ID environment variable not set; live draft time lookup will be skipped")
	}
	sleeperMainLeagueID := strings.TrimSpace(os.Getenv("SLEEPER_MAIN_LEAGUE_ID"))
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
	ownerIdentitiesFile := ownerIdentitiesPathFromEnv()

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
	return leagueID, sleeperMainLeagueID, baseCallbackURL, port, env, ownerAliases, ownerIdentitiesFile, dsn, sleeperDSN, dbMaxOpenConns, dbMaxIdleConns, dbMaxIdleTime, sessionKey, sendGridKey, redisAddr, redisPassword, redisDB
}

func (app *application) invalidAuthenticationTokenResponse(w http.ResponseWriter, r *http.Request) {
	message := "invalid or missing authentication token"
	app.errorResponse(w, r, http.StatusUnauthorized, message)
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
