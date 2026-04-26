-- name: ListTeamsByLeague :many
SELECT * FROM teams
WHERE league_id = $1
ORDER BY final_standing ASC, roster_id ASC;

-- name: GetTeamByLeagueAndRoster :one
SELECT * FROM teams
WHERE league_id = $1
  AND roster_id = $2;
