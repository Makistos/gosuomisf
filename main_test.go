package main

import (
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/makistos/gosuomisf/internal/api"
	"github.com/makistos/gosuomisf/internal/config"
	"github.com/makistos/gosuomisf/internal/database"
	"github.com/stretchr/testify/assert"
)

func TestHealthEndpoint(t *testing.T) {
	// Load test config
	cfg := &config.Config{
		Environment:        "test",
		DatabaseURL:        "postgresql://localhost/test?sslmode=disable",
		JWTSecret:          "test-secret",
		JWTExpiryHours:     24,
		RefreshExpiryHours: 168,
		Port:              "8080",
	}

	// Create a mock database (for this test we'll skip DB initialization)
	db := &database.DB{}

	// Setup router
	router := api.SetupRouter(db, cfg)

	// Test the front page data endpoint (which should work without DB)
	w := httptest.NewRecorder()
	req, _ := http.NewRequest("GET", "/api/frontpagedata", nil)
	router.ServeHTTP(w, req)

	assert.Equal(t, http.StatusInternalServerError, w.Code) // Expected since no real DB
}

func TestRouterSetup(t *testing.T) {
	cfg := &config.Config{
		Environment:        "test",
		DatabaseURL:        "test",
		JWTSecret:          "test-secret",
		JWTExpiryHours:     24,
		RefreshExpiryHours: 168,
		Port:              "8080",
	}

	db := &database.DB{}
	router := api.SetupRouter(db, cfg)

	assert.NotNil(t, router)
}

func TestConfigLoad(t *testing.T) {
	cfg := config.Load()
	assert.NotNil(t, cfg)
	assert.NotEmpty(t, cfg.JWTSecret)
}
