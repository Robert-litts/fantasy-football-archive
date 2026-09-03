package teamsview

import "github.com/Robert-litts/fantasy-football-archive/internal/archive"

type TeamRow struct {
	OwnerLabel    string
	TeamLabel     string
	Wins          int32
	Losses        int32
	Ties          int32
	FinalStanding int32
	PointsFor     string
	PointsAgainst string
}

type PageData struct {
	Leagues           []archive.LeagueSummary
	SelectedLeague    archive.LeagueSummary
	SelectedLeagueKey string
	Teams             []TeamRow
	SleeperAvailable  bool
	SleeperMessage    string
}
