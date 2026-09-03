-- name: ListPlayoffBracketMatchupsByLeague :many
SELECT * FROM playoff_bracket_matchups
WHERE league_id = $1
ORDER BY bracket_type ASC, round_num ASC, matchup_id ASC;
