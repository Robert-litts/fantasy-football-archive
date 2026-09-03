-- name: ListDraftPicksByLeague :many
SELECT
    d.*,
    t.roster_id,
    t.team_name,
    p.sleeper_id,
    p.espn_id,
    p.name AS player_name,
    p.first_name,
    p.last_name,
    p.position
FROM drafts d
JOIN teams t ON t.id = d.team_id
JOIN players p ON p.id = d.player_id
WHERE d.league_id = $1
ORDER BY d.overall_pick ASC;
