package matchupsview

import "github.com/Robert-litts/fantasy-football-archive/internal/archive"

type PageData struct {
	Leagues            []archive.LeagueSummary
	SelectedLeague     archive.LeagueSummary
	SelectedLeagueKey  string
	ActiveWeek         int32
	Weeks              []WeekTab
	Matchups           []MatchupRow
	SleeperAvailable   bool
	SleeperMessage     string
	SelectedWeekRows   []MatchupRow
	SelectedWeekLoaded bool
}

type WeekTab struct {
	Week           int32
	IsPlayoff      bool
	IsChampionship bool
}

type MatchupRow struct {
	Week           int32
	HomeTeamName   string
	HomeOwner      string
	HomeScore      string
	HomeRosterID   int32
	HomePresent    bool
	HomeWinner     bool
	AwayTeamName   string
	AwayOwner      string
	AwayScore      string
	AwayRosterID   int32
	AwayPresent    bool
	AwayWinner     bool
	IsPlayoff      bool
	IsChampionship bool
	MatchupType    string
	TypeLabel      string
}
