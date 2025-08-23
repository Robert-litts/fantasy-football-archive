-- CREATE TABLE "leagues" (
--     "id" INTEGER PRIMARY KEY,
--     "leagueId" INTEGER NOT NULL,
--     "year" INTEGER NOT NULL,
--     "teamCount" INTEGER,
--     "currentWeek" INTEGER,
--     "nflWeek" INTEGER,
--     CONSTRAINT "uix_league_year" UNIQUE ("leagueId", "year")
-- );

CREATE TABLE leagues (
    "id" SERIAL PRIMARY KEY,
    "leagueId" INTEGER NOT NULL,
    "year" INTEGER NOT NULL,
    "teamCount" INTEGER NOT NULL,
    "currentWeek" INTEGER NOT NULL DEFAULT 0,
    "nflWeek" INTEGER NOT NULL DEFAULT 0,
    
    CONSTRAINT "uix_league_year" UNIQUE ("leagueId", "year")
);

-- CREATE TABLE settings (
--     id INTEGER PRIMARY KEY AUTOINCREMENT,
--     league_id INTEGER NOT NULL UNIQUE,
--     regularSeasonCount INTEGER,
--     vetoVotesRequired INTEGER,
--     teamCount INTEGER,
--     playoffTeamCount INTEGER,
--     keeperCount INTEGER,
--     tradeDeadline BIGINT,
--     name VARCHAR(255),
--     tieRule VARCHAR(50),
--     playoffTieRule VARCHAR(50),
--     playoffSeedTieRule VARCHAR(50),
--     playoffMatchupPeriodLength INTEGER,
--     faab BOOLEAN,
--     CONSTRAINT idx_settings_league INDEX (league_id),
--     FOREIGN KEY (league_id) REFERENCES leagues(id)
-- );

CREATE TABLE "teams" (
    "id" INTEGER PRIMARY KEY,
    "league_id" INTEGER NOT NULL,
    "teamId" INTEGER NOT NULL,
    "year" INTEGER NOT NULL,
    "teamAbbrv" VARCHAR(10) NOT NULL,
    "teamName" VARCHAR(255) NOT NULL,
    "owners" VARCHAR(50) NOT NULL,
    "divisionId" VARCHAR(255) NOT NULL,
    "divisionName" VARCHAR(255) NOT NULL,
    "wins" INTEGER DEFAULT 0 NOT NULL,
    "losses" INTEGER DEFAULT 0 NOT NULL,
    "ties" INTEGER DEFAULT 0 NOT NULL,
    "pointsFor" INTEGER DEFAULT 0 NOT NULL,
    "pointsAgainst" INTEGER DEFAULT 0 NOT NULL,
    "waiverRank" INTEGER NOT NULL,
    "acquisitions" INTEGER DEFAULT 0 NOT NULL,
    "acquisitionBudgetSpent" INTEGER DEFAULT 0 NOT NULL,
    "drops" INTEGER DEFAULT 0 NOT NULL,
    "trades" INTEGER DEFAULT 0 NOT NULL,
    "streakType" VARCHAR(50) NOT NULL,
    "streakLength" INTEGER NOT NULL,
    "standing" INTEGER NOT NULL,
    "finalStanding" INTEGER NOT NULL,
    "draftProjRank" INTEGER NOT NULL,
    "playoffPct" INTEGER NOT NULL,
    "logoUrl" VARCHAR(255) NOT NULL,
    CONSTRAINT "uix_team_year" UNIQUE ("teamId", "year"),
    FOREIGN KEY ("league_id") REFERENCES "leagues"("id")
);


CREATE TABLE players (
    "id" INTEGER PRIMARY KEY,
    "espnId" INTEGER UNIQUE NOT NULL,
    "name" VARCHAR(255) NOT NULL,
    "position" VARCHAR(50)
);

CREATE TABLE drafts (
    "id" SERIAL PRIMARY KEY,
    "team_id" INTEGER NOT NULL,
    "player_id" INTEGER NOT NULL,
    "overallPick" INTEGER NOT NULL,
    "roundNum" INTEGER NOT NULL,
    "roundPick" INTEGER NOT NULL,
    "keeperStatus" BOOLEAN NOT NULL DEFAULT FALSE,
    "bidAmount" INTEGER NOT NULL DEFAULT -1,
    "nominating_team_id" INTEGER,
    
    CONSTRAINT "uix_draft_pick" UNIQUE ("team_id", "player_id"),
    CONSTRAINT "fk_drafts_team" FOREIGN KEY ("team_id") REFERENCES teams("id"),
    CONSTRAINT "fk_drafts_player" FOREIGN KEY ("player_id") REFERENCES "players"("id"),
    CONSTRAINT "fk_drafts_nominating_team" FOREIGN KEY ("nominating_team_id") REFERENCES "teams"("id")
);

CREATE TABLE matchups (
    "id" SERIAL PRIMARY KEY,
    "week" INTEGER NOT NULL,
    "home_team_id" INTEGER,
    "away_team_id" INTEGER,
    "homeScore" FLOAT NOT NULL DEFAULT 0.0,
    "awayScore" FLOAT NOT NULL DEFAULT 0.0,
    "isPlayoff" BOOLEAN NOT NULL DEFAULT FALSE,
    "matchupType" VARCHAR(50) NOT NULL DEFAULT 'NONE',
    CONSTRAINT "uix_matchup" UNIQUE ("week", "home_team_id", "away_team_id"),
    CONSTRAINT "fk_matchups_home_team" FOREIGN KEY ("home_team_id") REFERENCES teams("id"),
    CONSTRAINT "fk_matchups_away_team" FOREIGN KEY ("away_team_id") REFERENCES teams("id")
);

-- CREATE TABLE activities (
--     id INTEGER PRIMARY KEY AUTOINCREMENT,
--     date BIGINT,
--     team_id INTEGER,
--     player_id INTEGER NOT NULL,
--     bidAmount FLOAT,
--     action VARCHAR(50),
--     CONSTRAINT idx_activity_team_player INDEX (team_id, player_id),
--     CONSTRAINT idx_activity_team INDEX (team_id),
--     FOREIGN KEY (team_id) REFERENCES teams(id),
--     FOREIGN KEY (player_id) REFERENCES players(id)
-- );

-- CREATE TABLE rosters (
--     id INTEGER PRIMARY KEY AUTOINCREMENT,
--     team_id INTEGER NOT NULL,
--     player_id INTEGER NOT NULL,
--     rosterSlot VARCHAR(50),
--     CONSTRAINT uix_roster_team_player UNIQUE (team_id, player_id),
--     CONSTRAINT idx_roster_team_player INDEX (team_id, player_id),
--     CONSTRAINT idx_roster_team INDEX (team_id),
--     FOREIGN KEY (team_id) REFERENCES teams(id),
--     FOREIGN KEY (player_id) REFERENCES players(id)
-- );

CREATE TABLE IF NOT EXISTS users (
    id bigserial PRIMARY KEY,
    created_at timestamp(0) with time zone NOT NULL DEFAULT NOW(),
    name text NOT NULL,
    email citext UNIQUE NOT NULL,
    password_hash bytea NOT NULL,
    activated bool NOT NULL,
    version integer NOT NULL DEFAULT 1
);

CREATE TABLE IF NOT EXISTS tokens (
    hash bytea PRIMARY KEY,
    user_id bigint NOT NULL REFERENCES users ON DELETE CASCADE,
    expiry timestamp(0) with time zone NOT NULL,
    scope text NOT NULL
);