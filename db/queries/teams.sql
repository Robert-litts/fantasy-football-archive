-- name: GetTeamById :one
SELECT "id", "league_id", "year", "teamAbbrv", "owners", "divisionId", "divisionName", "wins", "losses", "ties", "pointsFor", "pointsAgainst", "waiverRank", "acquisitions", "acquisitionBudgetSpent", "drops", "trades", "logoUrl" 
FROM "teams" 
WHERE "id" = $1;

-- name: GetTeamsByLeagueYear :many
SELECT 
    "d"."owners", 
    "d"."wins", 
    "d"."losses", 
    "d"."ties", 
    "d"."pointsFor", 
    "d"."pointsAgainst", 
    "d"."waiverRank", 
    "d"."acquisitions", 
    "d"."acquisitionBudgetSpent", 
    "d"."drops",
    "d"."trades", 
    "d"."streakLength",
    "d"."finalStanding"
FROM "teams" "d"
JOIN "leagues" "l" ON "d"."league_id" = "l"."id"
WHERE "l"."id" = $1
ORDER BY "finalStanding" ASC;