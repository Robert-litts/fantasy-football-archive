package sleeperdb

import (
	"context"
	"database/sql"

	"github.com/lib/pq"
)

type PlayerPositionByESPNID struct {
	ESPNID   string
	Position sql.NullString
}

func (q *Queries) ListPlayerPositionsByESPNIDs(ctx context.Context, espnIDs []string) ([]PlayerPositionByESPNID, error) {
	if len(espnIDs) == 0 {
		return nil, nil
	}

	rows, err := q.db.QueryContext(ctx, `
SELECT espn_id, position
FROM players
WHERE espn_id = ANY($1)
  AND espn_id IS NOT NULL
`, pq.Array(espnIDs))
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	positions := make([]PlayerPositionByESPNID, 0)
	for rows.Next() {
		var position PlayerPositionByESPNID
		if err := rows.Scan(&position.ESPNID, &position.Position); err != nil {
			return nil, err
		}
		positions = append(positions, position)
	}
	if err := rows.Close(); err != nil {
		return nil, err
	}
	if err := rows.Err(); err != nil {
		return nil, err
	}

	return positions, nil
}
