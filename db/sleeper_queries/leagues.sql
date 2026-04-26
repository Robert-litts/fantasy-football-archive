-- name: ListLeagues :many
SELECT * FROM leagues
ORDER BY season ASC, name ASC;

-- name: GetLeagueByID :one
SELECT * FROM leagues
WHERE id = $1;

-- name: GetLeagueBySleeperID :one
SELECT * FROM leagues
WHERE sleeper_league_id = $1;

-- name: ListLeaguesBySeason :many
SELECT * FROM leagues
WHERE season = $1
ORDER BY name ASC;
