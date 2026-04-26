package main

import (
	"html/template"
	"net/http"

	"github.com/Robert-litts/fantasy-football-archive/internal/sleeperdb"
)

func (app *application) sleeperReportHandler(w http.ResponseWriter, r *http.Request) {
	reports, ok := app.sleeperReports(w, r)
	if !ok {
		return
	}

	if err := app.writeJSON(w, http.StatusOK, envelope{"reports": reports}, nil); err != nil {
		app.serverErrorResponse(w, r, err)
	}
}

func (app *application) sleeperReportPageHandler(w http.ResponseWriter, r *http.Request) {
	reports, ok := app.sleeperReports(w, r)
	if !ok {
		return
	}

	w.Header().Set("Content-Type", "text/html; charset=utf-8")
	if err := sleeperReportPageTemplate.Execute(w, reports); err != nil {
		app.serverErrorResponse(w, r, err)
	}
}

func (app *application) sleeperReports(w http.ResponseWriter, r *http.Request) ([]sleeperdb.ListLeagueReportsRow, bool) {
	if app.sleeperQueries == nil {
		app.errorResponse(w, r, http.StatusServiceUnavailable, "sleeper database is not configured")
		return nil, false
	}

	reports, err := app.sleeperQueries.ListLeagueReports(r.Context())
	if err != nil {
		app.logger.Error("sleeper report database error", "error", err)
		app.serverErrorResponse(w, r, err)
		return nil, false
	}

	return reports, true
}

var sleeperReportPageTemplate = template.Must(template.New("sleeper-report").Parse(`<!doctype html>
<html lang="en">
<head>
	<meta charset="utf-8">
	<meta name="viewport" content="width=device-width, initial-scale=1">
	<title>Sleeper Archive Report</title>
	<style>
		body { background: #111827; color: #e5e7eb; font-family: ui-sans-serif, system-ui, sans-serif; margin: 0; padding: 2rem; }
		main { max-width: 1200px; margin: 0 auto; }
		h1 { margin: 0 0 0.5rem; font-size: 2rem; }
		p { color: #9ca3af; margin: 0 0 1.5rem; }
		table { width: 100%; border-collapse: collapse; background: #1f2937; border: 1px solid #374151; border-radius: 0.75rem; overflow: hidden; }
		th, td { padding: 0.75rem 1rem; border-bottom: 1px solid #374151; text-align: left; white-space: nowrap; }
		th { color: #d1d5db; font-size: 0.75rem; letter-spacing: 0.05em; text-transform: uppercase; background: #111827; }
		tr:last-child td { border-bottom: 0; }
		.muted { color: #9ca3af; }
	</style>
</head>
<body>
	<main>
		<h1>Sleeper Archive Report</h1>
		<p>Read-only debug view proving the web app can query the Sleeper archive database.</p>
		<table>
			<thead>
				<tr>
					<th>Season</th>
					<th>League</th>
					<th>Teams</th>
					<th>Draft Picks</th>
					<th>Weeks</th>
					<th>Matchups</th>
					<th>Weekly Rosters</th>
					<th>Brackets</th>
					<th>Champion</th>
					<th>Runner-Up</th>
				</tr>
			</thead>
			<tbody>
				{{range .}}
					<tr>
						<td>{{.Season}}</td>
						<td>{{.Name}}</td>
						<td>{{.TeamCount}}/{{.TotalRosters}}</td>
						<td>{{.DraftPickCount}}</td>
						<td>{{if .MatchupMinWeek}}{{.MatchupMinWeek}}-{{.MatchupMaxWeek}}{{else}}<span class="muted">none</span>{{end}}</td>
						<td>{{.MatchupEntryCount}}</td>
						<td>{{.WeeklyRosterEntryCount}}</td>
						<td>{{.PlayoffBracketMatchupCount}}</td>
						<td>{{if .ChampionTeamName}}{{.ChampionTeamName}}{{else}}<span class="muted">missing</span>{{end}}</td>
						<td>{{if .RunnerUpTeamName}}{{.RunnerUpTeamName}}{{else}}<span class="muted">missing</span>{{end}}</td>
					</tr>
				{{else}}
					<tr>
						<td colspan="10" class="muted">No Sleeper archive leagues found.</td>
					</tr>
				{{end}}
			</tbody>
		</table>
	</main>
</body>
</html>`))
