-- name: GetDraftsByLeagueYear :many
SELECT 
    "d"."id", 
    "d"."team_id", 
    "d"."player_id", 
    "d"."overallPick", 
    "d"."roundNum", 
    "d"."roundPick", 
    "d"."keeperStatus", 
    "d"."bidAmount", 
    "d"."nominating_team_id"
FROM "drafts" "d"
JOIN "teams" "t" ON "d"."team_id" = "t"."id"
WHERE "t"."league_id" = $1;

-- name: GetDraftBoardWithSummary :many
SELECT
    d."id" AS "draft_id",
    d."team_id",
    t."teamName" AS "team_name",
    d."player_id",
    p."name" AS "player_name",
    d."overallPick",
    d."roundNum",
    d."roundPick",
    l."year",
    l."teamCount"
FROM "drafts" d
JOIN "players" p ON d."player_id" = p."id"
JOIN "teams" t ON d."team_id" = t."id"
JOIN "leagues" l ON t."league_id" = l."id"
WHERE t."league_id" = $1
ORDER BY d."overallPick";

