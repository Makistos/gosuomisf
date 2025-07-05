package config

import (
	"os"
	"strconv"
)

type Config struct {
	Environment        string
	DatabaseURL        string
	JWTSecret          string
	JWTExpiryHours     int
	RefreshExpiryHours int
	Port               string
}

func Load() *Config {
	jwtExpiryHours, _ := strconv.Atoi(getEnv("JWT_EXPIRY_HOURS", "24"))
	refreshExpiryHours, _ := strconv.Atoi(getEnv("REFRESH_EXPIRY_HOURS", "168")) // 7 days

	return &Config{
		Environment:        getEnv("ENVIRONMENT", "development"),
		DatabaseURL:        getEnv("DATABASE_URL", "postgresql://localhost/suomisf?sslmode=disable"),
		JWTSecret:          getEnv("JWT_SECRET", "your-secret-key-change-in-production"),
		JWTExpiryHours:     jwtExpiryHours,
		RefreshExpiryHours: refreshExpiryHours,
		Port:               getEnv("PORT", "8080"),
	}
}

func getEnv(key, defaultValue string) string {
	if value := os.Getenv(key); value != "" {
		return value
	}
	return defaultValue
}
