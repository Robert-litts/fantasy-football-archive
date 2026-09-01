package main

import (
	"context"
	"database/sql"
	"errors"
	"fmt"
	"net/http"
	"sort"
	"strings"

	"github.com/Robert-litts/fantasy-football-archive/internal/archive"
	"github.com/Robert-litts/fantasy-football-archive/internal/db"
	"github.com/Robert-litts/fantasy-football-archive/internal/sleeperdb"
	appstats "github.com/Robert-litts/fantasy-football-archive/internal/stats"
	"github.com/Robert-litts/fantasy-football-archive/templates"
)

type statsArchiveLister interface {
	ListCanonicalLeagueSummaries(context.Context) (archive.LeagueList, error)
}

type statsESPNLister interface {
	GetTeamsByLeagueYear(context.Context, int32) ([]db.GetTeamsByLeagueYearRow, error)
	GetMatchupsByLeagueId(context.Context, int32) ([]db.GetMatchupsByLeagueIdRow, error)
}

type statsSleeperTeamLister interface {
	ListTeamsByLeague(context.Context, int64) ([]sleeperdb.Team, error)
}

type statsSleeperMatchupLister interface {
	ListMatchupsByLeague(context.Context, int64) ([]sleeperdb.Matchup, error)
}

type statsSleeperBracketLister interface {
	ListPlayoffBracketMatchupsByLeague(context.Context, int64) ([]sleeperdb.PlayoffBracketMatchup, error)
}

type statsSeasonLoad struct {
	Season  appstats.SeasonInput
	Include bool
	Notice  string
	Warning error
}

func (app *application) statsHandler(w http.ResponseWriter, r *http.Request) {
	pageData, err := buildStatsPageData(r.Context(), app.archive, app.queries, app.sleeperQueries, app.sleeperQueries, app.sleeperQueries, app.config.ownerAliases)
	if err != nil {
		app.serverErrorResponse(w, r, err)
		return
	}
	for _, warning := range pageData.Warnings {
		app.logger.Warn("stats aggregation warning", "warning", warning)
	}

	if r.Header.Get("HX-Request") == "true" {
		if err := templates.Stats(pageData).Render(r.Context(), w); err != nil {
			app.serverErrorResponse(w, r, err)
		}
		return
	}

	if err := templates.Base(templates.Stats(pageData)).Render(r.Context(), w); err != nil {
		app.serverErrorResponse(w, r, err)
	}
}

type statsPageBuild struct {
	PageData appstats.PageData
	Warnings []error
}

func buildStatsPageData(
	ctx context.Context,
	archiveLister statsArchiveLister,
	espnLister statsESPNLister,
	sleeperTeamLister statsSleeperTeamLister,
	sleeperMatchupLister statsSleeperMatchupLister,
	sleeperBracketLister statsSleeperBracketLister,
	ownerAliases map[string]string,
) (appstats.PageData, error) {
	build, err := buildStatsPageDataDetailed(ctx, archiveLister, espnLister, sleeperTeamLister, sleeperMatchupLister, sleeperBracketLister, ownerAliases)
	if err != nil {
		return appstats.PageData{}, err
	}
	return build.PageData, nil
}

func buildStatsPageDataDetailed(
	ctx context.Context,
	archiveLister statsArchiveLister,
	espnLister statsESPNLister,
	sleeperTeamLister statsSleeperTeamLister,
	sleeperMatchupLister statsSleeperMatchupLister,
	sleeperBracketLister statsSleeperBracketLister,
	ownerAliases map[string]string,
) (statsPageBuild, error) {
	if archiveLister == nil {
		return statsPageBuild{}, sql.ErrConnDone
	}

	leagueList, err := archiveLister.ListCanonicalLeagueSummaries(ctx)
	if err != nil {
		return statsPageBuild{}, err
	}
	if err := ctx.Err(); err != nil {
		return statsPageBuild{}, err
	}

	seasons := make([]appstats.SeasonInput, 0, len(leagueList.Leagues))
	notices := make([]string, 0)
	warnings := make([]error, 0)
	for _, league := range leagueList.Leagues {
		load, err := loadStatsSeason(ctx, league, espnLister, sleeperTeamLister, sleeperMatchupLister, sleeperBracketLister)
		if err != nil {
			return statsPageBuild{}, err
		}
		if load.Warning != nil {
			warnings = append(warnings, load.Warning)
		}
		if load.Notice != "" {
			notices = append(notices, load.Notice)
		}
		if load.Include {
			seasons = append(seasons, load.Season)
		}
	}

	page := appstats.BuildPageDataFromSeasons(seasons, ownerAliases)
	page.SleeperAvailable = leagueList.SleeperAvailable
	if leagueList.SleeperMessage != "" {
		page.SleeperMessage = leagueList.SleeperMessage
	}
	if len(notices) > 0 && page.SleeperAvailable {
		page.SleeperMessage = joinUniqueMessages(append([]string{page.SleeperMessage}, notices...))
	} else if page.SleeperMessage == "" {
		page.SleeperMessage = joinUniqueMessages(notices)
	}
	page.Warnings = warnings
	return statsPageBuild{PageData: page, Warnings: warnings}, nil
}

func loadStatsSeason(
	ctx context.Context,
	league archive.LeagueSummary,
	espnLister statsESPNLister,
	sleeperTeamLister statsSleeperTeamLister,
	sleeperMatchupLister statsSleeperMatchupLister,
	sleeperBracketLister statsSleeperBracketLister,
) (statsSeasonLoad, error) {
	if err := ctx.Err(); err != nil {
		return statsSeasonLoad{}, err
	}

	season := appstats.SeasonInput{Year: int(league.Season)}

	switch league.Provider {
	case archive.ProviderESPN:
		if espnLister == nil {
			return statsSeasonLoad{}, sql.ErrConnDone
		}
		teams, err := espnLister.GetTeamsByLeagueYear(ctx, int32(league.ID))
		if err != nil && !errors.Is(err, sql.ErrNoRows) {
			return statsSeasonLoad{}, err
		}
		if err := ctx.Err(); err != nil {
			return statsSeasonLoad{}, err
		}
		matchups, err := espnLister.GetMatchupsByLeagueId(ctx, int32(league.ID))
		if err != nil && !errors.Is(err, sql.ErrNoRows) {
			return statsSeasonLoad{}, err
		}
		seasonTeams, seasonMatchups, err := normalizeESPNStatsSeason(league, teams, matchups)
		if err != nil {
			return statsSeasonLoad{}, err
		}
		season.Teams = seasonTeams
		season.Matchups = seasonMatchups
		return statsSeasonLoad{Season: season, Include: true}, nil

	case archive.ProviderSleeper:
		if sleeperTeamLister == nil || sleeperMatchupLister == nil {
			return statsSeasonLoad{
				Warning: fmt.Errorf("sleeper season %d: database not configured", league.Season),
			}, nil
		}
		teams, err := sleeperTeamLister.ListTeamsByLeague(ctx, league.ID)
		if err != nil && !errors.Is(err, sql.ErrNoRows) {
			return statsSeasonLoad{
				Warning: fmt.Errorf("sleeper season %d: list teams: %w", league.Season, err),
			}, nil
		}
		if err := ctx.Err(); err != nil {
			return statsSeasonLoad{}, err
		}
		matchups, err := sleeperMatchupLister.ListMatchupsByLeague(ctx, league.ID)
		if err != nil && !errors.Is(err, sql.ErrNoRows) {
			return statsSeasonLoad{
				Warning: fmt.Errorf("sleeper season %d: list matchups: %w", league.Season, err),
			}, nil
		}
		if err := ctx.Err(); err != nil {
			return statsSeasonLoad{}, err
		}
		if len(teams) == 0 {
			return statsSeasonLoad{
				Warning: fmt.Errorf("sleeper season %d: no teams archived", league.Season),
			}, nil
		}
		if len(matchups) == 0 {
			return statsSeasonLoad{
				Warning: fmt.Errorf("sleeper season %d: no matchups archived", league.Season),
			}, nil
		}

		var brackets []sleeperdb.PlayoffBracketMatchup
		notice := ""
		if sleeperBracketLister != nil {
			brackets, err = sleeperBracketLister.ListPlayoffBracketMatchupsByLeague(ctx, league.ID)
			if err != nil && !errors.Is(err, sql.ErrNoRows) {
				brackets = nil
				notice = "Sleeper playoff bracket data is temporarily unavailable; championship labels may use final standings"
			}
		}

		seasonTeams, seasonMatchups, err := normalizeSleeperStatsSeason(league, teams, matchups, brackets)
		if err != nil {
			return statsSeasonLoad{Warning: err}, nil
		}
		season.Teams = seasonTeams
		season.Matchups = seasonMatchups
		return statsSeasonLoad{Season: season, Include: true, Notice: notice}, nil
	default:
		return statsSeasonLoad{}, fmt.Errorf("unsupported league provider %q", league.Provider)
	}
}

func normalizeESPNStatsSeason(league archive.LeagueSummary, teamRows []db.GetTeamsByLeagueYearRow, matchupRows []db.GetMatchupsByLeagueIdRow) ([]appstats.TeamInput, []appstats.MatchupInput, error) {
	teams := make([]appstats.TeamInput, 0, len(teamRows))
	for _, row := range teamRows {
		teams = append(teams, appstats.TeamInput{
			Owner:         strings.TrimSpace(row.Owners),
			Wins:          int(row.Wins),
			Losses:        int(row.Losses),
			Ties:          int(row.Ties),
			FinalStanding: int(row.FinalStanding),
			PointsFor:     appstats.PointsFromWhole(int64(row.PointsFor)),
			PointsAgainst: appstats.PointsFromWhole(int64(row.PointsAgainst)),
		})
	}
	matchups := make([]appstats.MatchupInput, 0, len(matchupRows))
	for _, row := range matchupRows {
		homeScore, err := appstats.PointsFromFloat64(row.HomeScore)
		if err != nil {
			return nil, nil, fmt.Errorf("espn league %d week %d home score: %w", league.ID, row.Week, err)
		}
		awayScore, err := appstats.PointsFromFloat64(row.AwayScore)
		if err != nil {
			return nil, nil, fmt.Errorf("espn league %d week %d away score: %w", league.ID, row.Week, err)
		}
		input := appstats.MatchupInput{
			Week:         int(row.Week),
			HomePresent:  row.HomeTeamID.Valid,
			AwayPresent:  row.AwayTeamID.Valid,
			HomeOwner:    strings.TrimSpace(row.HomeTeamOwners),
			HomeTeamName: row.HomeTeamName,
			HomeScore:    homeScore,
			AwayOwner:    strings.TrimSpace(row.AwayTeamOwners),
			AwayTeamName: row.AwayTeamName,
			AwayScore:    awayScore,
			IsPlayoff:    row.IsPlayoff,
			MatchupType:  row.MatchupType,
		}
		if isESPNChampionshipMatchupRow(row) {
			input.IsChampionship = true
			switch {
			case row.HomeFinalStanding == 1:
				input.ChampionshipWinner = appstats.MatchupWinnerHome
			case row.AwayFinalStanding == 1:
				input.ChampionshipWinner = appstats.MatchupWinnerAway
			}
		}
		matchups = append(matchups, input)
	}
	return teams, matchups, nil
}

func normalizeSleeperStatsSeason(league archive.LeagueSummary, teamRows []sleeperdb.Team, matchupRows []sleeperdb.Matchup, bracketRows []sleeperdb.PlayoffBracketMatchup) ([]appstats.TeamInput, []appstats.MatchupInput, error) {
	teams := make([]appstats.TeamInput, 0, len(teamRows))
	for _, row := range teamRows {
		pointsFor, err := appstats.ParsePoints(row.PointsFor)
		if err != nil {
			return nil, nil, fmt.Errorf("sleeper league %d roster %d points for: %w", league.ID, row.RosterID, err)
		}
		pointsAgainst, err := appstats.ParsePoints(row.PointsAgainst)
		if err != nil {
			return nil, nil, fmt.Errorf("sleeper league %d roster %d points against: %w", league.ID, row.RosterID, err)
		}
		teams = append(teams, appstats.TeamInput{
			Owner:         sleeperStatsOwnerKey(row),
			Wins:          int(row.Wins),
			Losses:        int(row.Losses),
			Ties:          int(row.Ties),
			FinalStanding: int(row.FinalStanding),
			PointsFor:     pointsFor,
			PointsAgainst: pointsAgainst,
		})
	}

	viewRows := normalizeSleeperMatchups(matchupRows, teamRows, bracketRows)
	teamsByRosterID := make(map[int32]sleeperdb.Team, len(teamRows))
	for _, team := range teamRows {
		teamsByRosterID[team.RosterID] = team
	}

	championship := resolveSleeperChampionship(bracketRows, teamRows)
	championPair := rosterPairKey(championship.FirstRosterID, championship.SecondRosterID)
	championMatchupIndex := -1
	if championship.valid() {
		for i, row := range viewRows {
			if !row.HomePresent || !row.AwayPresent || !row.IsPlayoff {
				continue
			}
			if rosterPairKey(row.HomeRosterID, row.AwayRosterID) != championPair {
				continue
			}
			if championMatchupIndex == -1 || row.Week > viewRows[championMatchupIndex].Week {
				championMatchupIndex = i
			}
		}
	}

	matchups := make([]appstats.MatchupInput, 0, len(viewRows))
	for i, row := range viewRows {
		homeScore, err := parseOptionalStatsPoints(row.HomeScore, row.HomePresent)
		if err != nil {
			return nil, nil, fmt.Errorf("sleeper league %d week %d home score: %w", league.ID, row.Week, err)
		}
		awayScore, err := parseOptionalStatsPoints(row.AwayScore, row.AwayPresent)
		if err != nil {
			return nil, nil, fmt.Errorf("sleeper league %d week %d away score: %w", league.ID, row.Week, err)
		}
		input := appstats.MatchupInput{
			Week:         int(row.Week),
			HomePresent:  row.HomePresent,
			AwayPresent:  row.AwayPresent,
			HomeOwner:    sleeperStatsOwnerRowKey(teamsByRosterID[row.HomeRosterID], row.HomeOwner),
			HomeTeamName: row.HomeTeamName,
			HomeScore:    homeScore,
			AwayOwner:    sleeperStatsOwnerRowKey(teamsByRosterID[row.AwayRosterID], row.AwayOwner),
			AwayTeamName: row.AwayTeamName,
			AwayScore:    awayScore,
			IsPlayoff:    row.IsPlayoff,
			MatchupType:  row.MatchupType,
		}
		if i == championMatchupIndex {
			input.IsChampionship = true
			switch championship.OfficialWinnerRosterID {
			case row.HomeRosterID:
				input.ChampionshipWinner = appstats.MatchupWinnerHome
			case row.AwayRosterID:
				input.ChampionshipWinner = appstats.MatchupWinnerAway
			}
		}
		matchups = append(matchups, input)
	}
	return teams, matchups, nil
}

func joinUniqueMessages(messages []string) string {
	seen := make(map[string]struct{})
	out := make([]string, 0, len(messages))
	for _, msg := range messages {
		msg = strings.TrimSpace(msg)
		if msg == "" {
			continue
		}
		if _, ok := seen[msg]; ok {
			continue
		}
		seen[msg] = struct{}{}
		out = append(out, msg)
	}
	sort.Strings(out)
	return strings.Join(out, "; ")
}

// sleeperStatsOwnerKey returns the raw Sleeper identifier that should be
// canonicalized by internal/stats. It prefers OwnerID, then DisplayName, then
// Username. The provider adapter must NOT canonicalize against the alias map
// here so internal/stats applies identity resolution exactly once.
func sleeperStatsOwnerKey(team sleeperdb.Team) string {
	if id := strings.TrimSpace(team.OwnerID); id != "" {
		return id
	}
	if name := strings.TrimSpace(team.DisplayName.String); name != "" {
		return name
	}
	return strings.TrimSpace(team.Username.String)
}

func sleeperStatsOwnerRowKey(team sleeperdb.Team, fallback string) string {
	if key := sleeperStatsOwnerKey(team); key != "" {
		return key
	}
	return strings.TrimSpace(fallback)
}

// parseOptionalStatsPoints parses a Sleeper matchup score string. When the
// side is not present (a bye row), an empty string is treated as zero. Any
// other blank input or malformed value still returns an error so a genuine
// data problem never silently becomes zero.
func parseOptionalStatsPoints(value string, present bool) (appstats.Points, error) {
	if strings.TrimSpace(value) == "" {
		if present {
			return 0, fmt.Errorf("points cannot be blank")
		}
		return 0, nil
	}
	return appstats.ParsePoints(value)
}
