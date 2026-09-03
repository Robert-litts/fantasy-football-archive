# Fantasy Football Archive

![it exists](./internal/static/images/league-does-not-exist.png)

Go-based application for accessing historical fantasy football data archived from
ESPN (2013+) and Sleeper (2022+). The browser pages combine both archives into
one canonical history; the JSON API endpoints remain ESPN-only.

This data was originally retrieved from ESPN's API using
[cwendt94's espn-api](https://github.com/cwendt94/espn-api) and wouldn't be
possible without his amazing work!

Checkout the rest of the background and motivations for this projcect [here](https://litts.me/projects/2025/first/)

## Scope

- **Browser pages**: provider-neutral (ESPN + Sleeper).
- **JSON APIs**: ESPN-only (`/api/v1/...`).
- **Sleeper ingestion**: external. This web app reads an externally populated
  Sleeper archive database only. It never writes Sleeper data.
- **Live Sleeper call**: an optional draft-time lookup against
  `https://api.sleeper.app` for the home page draft schedule. It is bounded,
  read-only, and never blocks rendering.

## Prerequisites

- Go 1.23 or higher (the build pins 1.23.3)
- Node.js 20+ for the Tailwind CSS build
- Docker and Docker Compose for the local stack
- PostgreSQL 17 with the ESPN export and the Sleeper archive databases

## Quick start

```bash
cp .env.example .env
DOCKER_UID=$(id -u) DOCKER_GID=$(id -g) docker compose config --quiet
DOCKER_UID=$(id -u) DOCKER_GID=$(id -g) docker compose up -d --build
curl -fsS http://localhost:4000/api/v1/healthcheck
```

Open the app at <http://localhost:4000>. Authenticate through Auth0, then visit
`/app/home`, `/app/leagues`, `/app/teams`, `/app/matchups`, `/app/drafts`,
`/app/stats`, and `/app/diagnostics/sleeper`.

## Configuration

### Owner identity configuration

The app creates an `owner-identities.json` starter file the first time it runs
with database access. Edit this file to group ESPN owner names and Sleeper
accounts that belong to the same person, then restart the app.

```json
{
  "schema_version": 1,
  "owners": [
    {
      "name": "Robbie",
      "espn": {
        "names": ["Robbie Litts", "Robert Litts"]
      },
      "sleeper": {
        "owner_ids": ["123456789012345678"],
        "usernames": ["robbie_sleeper"],
        "display_names": ["Robbie"]
      }
    }
  ]
}
```

Sleeper `owner_ids` are the most stable identifiers and should be kept when
possible. `OWNER_IDENTITIES_FILE` can point to a different JSON path.
`OWNER_ALIASES_JSON` is still supported as a flat override for quick fixes:

```env
OWNER_IDENTITIES_FILE=owner-identities.json
OWNER_ALIASES_JSON={"Mark Jacobs":"Bob Smith","Bigen Bulgey":"John Jones"}
```

This only affects cross-season stats rollups and owner labels derived from
those rollups. Historical season data remains unchanged.

If a configured first-run discovery fails, startup exits with a clear error so
the operator can fix the database or permissions before any partial starter is
written.

### Sleeper archive integration

The web app reads the preserved ESPN database and the externally archived
Sleeper database side by side.

```env
ESPN_DATABASE_URL=postgres://sleeper:sleeper@localhost:5434/fantasy_espn_clone?sslmode=disable
SLEEPER_DATABASE_URL=postgres://sleeper:sleeper@localhost:5434/sleeper_archive?sslmode=disable
SLEEPER_MAIN_LEAGUE_ID=1257071510313517056
SLEEPER_LEAGUE_ID=1257071510313517056
```

- `SLEEPER_MAIN_LEAGUE_ID` selects the canonical Sleeper lineage used for the
  combined history, home page, and stats. Side leagues archived from the same
  user account are hidden from user-facing pages but remain visible in
  `/app/diagnostics/sleeper`.
- `SLEEPER_LEAGUE_ID` is optional. It enables a live lookup of the next draft
  time for the home page. Empty or missing values fall back to a friendly
  "Draft time unavailable" notice.
- If multiple canonical Sleeper lineages exist and `SLEEPER_MAIN_LEAGUE_ID` is
  unset, canonical history returns a configuration error.

For Docker Compose on Linux, the API container cannot use `localhost` to reach
a Postgres instance running on the host machine. Override these defaults in
your `.env`:

```env
DOCKER_ESPN_DATABASE_URL=postgres://sleeper:sleeper@host.docker.internal:5434/fantasy_espn_clone?sslmode=disable
DOCKER_SLEEPER_DATABASE_URL=postgres://sleeper:sleeper@host.docker.internal:5434/sleeper_archive?sslmode=disable
DOCKER_OWNER_IDENTITIES_FILE=/config/owner-identities.json
DOCKER_UID=1000
DOCKER_GID=1000
```

Docker Compose mounts `./config` to `/config`, so the first-run owner identity
file is created at `./config/owner-identities.json` on your host machine.
`DOCKER_UID` and `DOCKER_GID` ensure the API container writes that file as your
host user instead of as `nobody`.

`DB_URL` is still supported as a fallback for the ESPN database.

## Routes

| Path                              | Auth | Description                                  |
| --------------------------------- | ---- | -------------------------------------------- |
| `/api/v1/healthcheck`             | No   | JSON health status                           |
| `/api/v1/leagues`                 | No   | ESPN JSON league list                        |
| `/api/v1/leagues/:id`             | No   | ESPN JSON league                             |
| `/api/v1/leagues/:id/teams`       | No   | ESPN JSON teams                              |
| `/api/v1/leagues/:id/drafts`      | No   | ESPN JSON drafts                             |
| `/api/v1/leagues/:id/matchups`    | No   | ESPN JSON matchups                           |
| `/app/leagues`                    | Yes  | Combined ESPN + canonical Sleeper list       |
| `/app/teams`                      | Yes  | Combined ESPN + canonical Sleeper teams      |
| `/app/matchups`                   | Yes  | Combined ESPN + canonical Sleeper matchups   |
| `/app/drafts`                     | Yes  | Combined ESPN + canonical Sleeper drafts     |
| `/app/stats`                      | Yes  | Combined ESPN + canonical Sleeper history    |
| `/app/home`                       | Yes  | Home with optional draft-time lookup         |
| `/app/diagnostics/sleeper`        | Yes  | All archived Sleeper leagues (admin health)  |

## Verification and release

```bash
make ci       # templ generate, go vet, staticcheck, race tests, native build
docker compose config --quiet
docker compose build --no-cache api
```

Release tags follow `vX.Y.Z`. The CI workflow runs on every push to `main` and
`sleeper-integration` and on every pull request. Tagged releases additionally
rerun CI, publish an immutable Docker image, and wait for approval through the
GitHub `production` environment before deploying. Production Compose must use
the API image variable so the workflow can select the release tag exactly:

```yaml
services:
  api:
    image: ${API_IMAGE:-ghcr.io/robert-litts/fantasy-football-archive:latest}
```

The deploy job only recreates `api`, verifies the release version through the
health endpoint, and rolls back to the previous local image on failure. Create
and protect the `production` environment before publishing a release tag. Add
required reviewers and scope `HOST`, `USERNAME`, `KEY`, `PORT`, and the SSH host
key `FINGERPRINT` secret to that environment.
