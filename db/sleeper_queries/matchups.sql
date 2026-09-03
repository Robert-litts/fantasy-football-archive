-- name: ListMatchupsByLeague :many
SELECT * FROM matchups
WHERE league_id = $1
ORDER BY week ASC, matchup_id ASC, roster_id ASC;
