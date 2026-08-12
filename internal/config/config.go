package config

import (
	"os"
	"strconv"

	"github.com/sirupsen/logrus"
)

type Config struct {
	ListenAddr     string
	DBDriver       string
	DBDSN          string
	LogLevel       logrus.Level
	DBPoolMaxConns int32
	DBPoolMinConns int32
}

func Load() Config {
	level := logrus.InfoLevel
	return Config{
		ListenAddr:     envOrDefault("LISTEN_ADDR", ":8080"),
		DBDriver:       envOrDefault("DB_DRIVER", "postgresql"),
		DBDSN:          envOrDefault("DB_DSN", "postgres://postgres@localhost:5433/events?sslmode=disable"),
		LogLevel:       level,
		DBPoolMinConns: int32(getEnvInt("DB_POOL_MIN_CONNS", 2)),
		DBPoolMaxConns: int32(getEnvInt("DB_POOL_MAX_CONNS", 20)),
	}
}

func envOrDefault(key, def string) string {
	if v := os.Getenv(key); v != "" {
		return v
	}
	return def
}

func getEnv(key, fallback string) string {
	if value, ok := os.LookupEnv(key); ok && value != "" {
		return value
	}
	return fallback
}

func getEnvInt(key string, fallback int) int {
	value := getEnv(key, "")
	if value == "" {
		return fallback
	}
	parsed, err := strconv.Atoi(value)
	if err != nil {
		return fallback
	}
	return parsed
}
