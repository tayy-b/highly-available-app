package db

//  contains the database connection and methods to interact with the database.

import (
	"context"
	"fmt"
	"time"
	"timestamp-api-service/internal/config"

	_ "github.com/lib/pq"

	"github.com/jmoiron/sqlx"
)

type DB struct {
	conn *sqlx.DB
}

func New(ctx context.Context, cfg config.Config) (*DB, error) {
	db, err := sqlx.ConnectContext(ctx, "postgres", cfg.DBDSN)
	if err != nil {
		return nil, fmt.Errorf("connect database: %w", err)
	}
	db.SetMaxOpenConns(int(cfg.DBPoolMaxConns))
	db.SetMaxIdleConns(int(cfg.DBPoolMinConns))
	db.SetConnMaxIdleTime(5 * time.Minute)
	return &DB{conn: db}, nil
}

func (d *DB) Close() {
	_ = d.conn.Close()
}

func (d *DB) AddTimestamp(ctx context.Context) error {
	const q = `INSERT INTO events DEFAULT VALUES`
	if _, err := d.conn.ExecContext(ctx, q); err != nil {
		return fmt.Errorf("insert event: %w", err)
	}
	return nil
}
