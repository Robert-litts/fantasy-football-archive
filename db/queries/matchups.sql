-- -- name: GetMatchupsByLeagueId :many
-- SELECT 
--    "m".*,
--    "ht"."teamName" as "homeTeamName",
--    "ht"."owners" as "homeTeamOwners", 
--    "at"."teamName" as "awayTeamName",
--    "at"."owners" as "awayTeamOwners",
--    "l"."year" as "leagueYear",
--    "l"."id" as "leagueId"
-- FROM "matchups" "m"
-- JOIN "teams" "ht" ON "m"."home_team_id" = "ht"."id" 
-- JOIN "teams" "at" ON "m"."away_team_id" = "at"."id"
-- JOIN "leagues" "l" ON "ht"."league_id" = "l"."id"
-- WHERE "ht"."league_id" = $1 
-- AND "at"."league_id" = $1
-- ORDER BY "m"."week" ASC;

-- -- name: GetMatchupsByLeagueId :many
-- SELECT
--     "m".*,
--     "ht"."teamName" as "homeTeamName",
--     "ht"."owners" as "homeTeamOwners",
--     "at"."teamName" as "awayTeamName",
--     "at"."owners" as "awayTeamOwners",
--     "l"."year" as "leagueYear",
--     "l"."id" as "leagueId"
-- FROM "matchups" "m"
-- LEFT JOIN "teams" "ht" ON "m"."home_team_id" = "ht"."id"
-- LEFT JOIN "teams" "at" ON "m"."away_team_id" = "at"."id"
-- LEFT JOIN "leagues" "l" ON COALESCE("ht"."league_id", "at"."league_id") = "l"."id"
-- WHERE ("ht"."league_id" = $1 OR "ht"."league_id" IS NULL)
-- AND ("at"."league_id" = $1 OR "at"."league_id" IS NULL)
-- AND "l"."id" = $1
-- ORDER BY "m"."week" ASC;

-- name: GetMatchupsByLeagueId :many
SELECT
    "m".*,
    COALESCE("ht"."teamName", '') as "homeTeamName",
    COALESCE("ht"."owners", '') as "homeTeamOwners",
    COALESCE("at"."teamName", '') as "awayTeamName",
    COALESCE("at"."owners", '') as "awayTeamOwners",
    "l"."year" as "leagueYear",
    "l"."id" as "leagueId"
FROM "matchups" "m"
LEFT JOIN "teams" "ht" ON "m"."home_team_id" = "ht"."id"
LEFT JOIN "teams" "at" ON "m"."away_team_id" = "at"."id"
JOIN "leagues" "l" ON "l"."id" = $1
WHERE ("ht"."league_id" = $1 OR "m"."home_team_id" IS NULL)
AND ("at"."league_id" = $1 OR "m"."away_team_id" IS NULL)
ORDER BY "m"."week" ASC;