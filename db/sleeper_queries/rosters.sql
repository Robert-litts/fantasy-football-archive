-- name: ListRosterEntriesByLeagueAndWeek :many
SELECT
    r.*,
    p.sleeper_id,
    p.espn_id,
    p.name AS player_name,
    p.position
FROM rosters r
JOIN players p ON p.id = r.player_id
WHERE r.league_id = $1
  AND r.week = $2
ORDER BY r.roster_id ASC, r.is_starter DESC, p.name ASC;
