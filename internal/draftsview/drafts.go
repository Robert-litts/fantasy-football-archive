package draftsview

import "github.com/Robert-litts/fantasy-football-archive/internal/archive"

type PickRow struct {
	OverallPick  int32
	RoundNum     int32
	RoundPick    int32
	TeamName     string
	PlayerName   string
	PlayerESPNID string
	Position     string
	KeeperStatus bool
}

type PageData struct {
	Leagues           []archive.LeagueSummary
	SelectedLeague    archive.LeagueSummary
	SelectedLeagueKey string
	Picks             []PickRow
	MaxRounds         int
	MaxPicks          int
	TeamCount         int32
	SleeperAvailable  bool
	SleeperMessage    string
}
