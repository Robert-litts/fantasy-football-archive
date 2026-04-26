# Fantasy Football Archive

![it exists](./internal/static/images/league-does-not-exist.png)

Go-based RESTful API for accessing historical fantasy football data extracted from ESPN and stored locally in a PostgresSQL database. The API lets you query your past fantasy football league data, including league standings, team performance, drafts, and more.

This data was retrieved from ESPN's API using [cwendt94's espn-api](https://github.com/cwendt94/espn-api) and wouldn't be possible without his amazing work!

Checkout the rest of the background and motivations for this projcect [here](https://litts.me/projects/2025/first/)

### Prerequisites

- Go (version 1.23 or higher)
- PostgreSQL database with the exported ESPN data (see my other project for instructions on how to export the data, coming soon)

### Optional owner alias configuration

If your league has owners who changed names across seasons and you want the stats page to roll them up under a common name, set `OWNER_ALIASES_JSON` in your environment.

Example:

```env
OWNER_ALIASES_JSON={"Mark Jacobs":"Bob Smith","Bigen Bulgey":"John Jones"}
```

This only affects cross-season stats rollups. Historical season data remains unchanged.

### Sleeper archive integration

The web app can read the preserved ESPN database and the newer Sleeper archive database side by side.

For local development outside Docker, configure both database URLs:

```env
ESPN_DATABASE_URL=postgres://sleeper:sleeper@localhost:5434/fantasy_espn_clone?sslmode=disable
SLEEPER_DATABASE_URL=postgres://sleeper:sleeper@localhost:5434/sleeper_archive?sslmode=disable
SLEEPER_LEAGUE_ID=123456789012345678
SLEEPER_MAIN_LEAGUE_ID=123456789012345678
```

`SLEEPER_MAIN_LEAGUE_ID` should match the lineage seed used by the Sleeper archive. Canonical long-term archive stats use the Sleeper database's `canonical_league_id` values to exclude other leagues archived from the same user account. If it is omitted, the web app includes Sleeper leagues with any non-empty `canonical_league_id`.

For Docker Compose on Linux, the API container cannot use `localhost` to reach a Postgres instance running on the host machine. Either set these overrides in your `.env`, or let Compose fall back to its built-in defaults:

```env
DOCKER_ESPN_DATABASE_URL=postgres://sleeper:sleeper@host.docker.internal:5434/fantasy_espn_clone?sslmode=disable
DOCKER_SLEEPER_DATABASE_URL=postgres://sleeper:sleeper@host.docker.internal:5434/sleeper_archive?sslmode=disable
```

`DB_URL` is still supported as a fallback for the ESPN database.

Initial Sleeper smoke-test routes:

```text
GET /api/v1/sleeper/report
GET /app/sleeper/report
```
