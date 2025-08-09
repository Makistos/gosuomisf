package config

import (
	"os"
	"testing"

	"github.com/stretchr/testify/assert"
)

func TestLoad(t *testing.T) {
	// Test loading config
	cfg := Load()

	assert.NotNil(t, cfg)
	assert.NotEmpty(t, cfg.JWTSecret)
	assert.Greater(t, cfg.JWTExpiryHours, 0)
	assert.Greater(t, cfg.RefreshExpiryHours, 0)
	assert.NotEmpty(t, cfg.Port)
}

func TestLoadWithEnvironmentVars(t *testing.T) {
	// Set test environment variables
	os.Setenv("JWT_SECRET", "test-secret-123")
	os.Setenv("PORT", "9999")
	os.Setenv("DATABASE_URL", "postgresql://test:test@localhost/test")
	defer func() {
		os.Unsetenv("JWT_SECRET")
		os.Unsetenv("PORT")
		os.Unsetenv("DATABASE_URL")
	}()

	cfg := Load()

	assert.Equal(t, "test-secret-123", cfg.JWTSecret)
	assert.Equal(t, "9999", cfg.Port)
	assert.Equal(t, "postgresql://test:test@localhost/test", cfg.DatabaseURL)
}

func TestLoadDefaults(t *testing.T) {
	// Clear environment variables
	originalSecret := os.Getenv("JWT_SECRET")
	originalPort := os.Getenv("PORT")

	os.Unsetenv("JWT_SECRET")
	os.Unsetenv("PORT")

	defer func() {
		if originalSecret != "" {
			os.Setenv("JWT_SECRET", originalSecret)
		}
		if originalPort != "" {
			os.Setenv("PORT", originalPort)
		}
	}()

	cfg := Load()

	// Should have default values
	assert.NotEmpty(t, cfg.JWTSecret) // Default random secret
	assert.Equal(t, "8080", cfg.Port) // Default port
}
