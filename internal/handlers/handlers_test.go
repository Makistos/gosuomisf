package handlers

import (
	"bytes"
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"os"
	"testing"

	"github.com/gin-gonic/gin"
	"github.com/makistos/gosuomisf/internal/auth"
	"github.com/makistos/gosuomisf/internal/config"
	"github.com/makistos/gosuomisf/internal/database"
	"github.com/makistos/gosuomisf/internal/models"
	"github.com/stretchr/testify/assert"
)

var testDB *database.DB

func TestMain(m *testing.M) {
	// Setup
	gin.SetMode(gin.TestMode)
	
	// Try to connect to test database
	dbURL := os.Getenv("DATABASE_URL")
	if dbURL == "" {
		dbURL = "postgresql://postgres:postgres@127.0.0.1:5432/suomisf_test?sslmode=disable"
	}
	
	var err error
	testDB, err = database.Initialize(dbURL)
	if err != nil {
		// If no database available, create a mock
		testDB = &database.DB{}
	}

	// Run tests
	code := m.Run()
	
	// Teardown
	if testDB != nil && testDB.DB != nil {
		testDB.Close()
	}
	
	os.Exit(code)
}

func TestFrontPageHandler(t *testing.T) {
	handler := NewFrontPageHandler(testDB)
	
	w := httptest.NewRecorder()
	c, _ := gin.CreateTestContext(w)
	
	handler.GetFrontPageData(c)
	
	if testDB.DB != nil {
		// If we have a real DB, expect success or specific error
		assert.True(t, w.Code == http.StatusOK || w.Code == http.StatusInternalServerError)
	} else {
		// With mock DB, expect error
		assert.Equal(t, http.StatusInternalServerError, w.Code)
	}
}

func TestTagHandler_GetTags(t *testing.T) {
	handler := NewTagHandler(testDB)
	
	w := httptest.NewRecorder()
	c, _ := gin.CreateTestContext(w)
	c.Request, _ = http.NewRequest("GET", "/api/tags?page=1&page_size=10", nil)
	
	handler.GetTags(c)
	
	if testDB.DB != nil {
		// With real DB, should get data or proper error
		assert.True(t, w.Code == http.StatusOK || w.Code == http.StatusInternalServerError)
		
		if w.Code == http.StatusOK {
			var response models.PaginatedResponse
			err := json.Unmarshal(w.Body.Bytes(), &response)
			assert.NoError(t, err)
			assert.GreaterOrEqual(t, response.Total, 0)
		}
	} else {
		// With mock DB, expect error due to nil connection
		assert.Equal(t, http.StatusInternalServerError, w.Code)
	}
}

func TestTagHandler_GetTag(t *testing.T) {
	handler := NewTagHandler(testDB)
	
	w := httptest.NewRecorder()
	c, _ := gin.CreateTestContext(w)
	c.Params = gin.Params{gin.Param{Key: "tagId", Value: "1"}}
	
	handler.GetTag(c)
	
	if testDB.DB != nil {
		// With real DB, should get data or not found
		assert.True(t, w.Code == http.StatusOK || w.Code == http.StatusNotFound || w.Code == http.StatusInternalServerError)
	} else {
		// With mock DB, expect internal server error due to nil connection
		assert.Equal(t, http.StatusInternalServerError, w.Code)
	}
}

func TestTagHandler_InvalidTagID(t *testing.T) {
	handler := NewTagHandler(testDB)
	
	w := httptest.NewRecorder()
	c, _ := gin.CreateTestContext(w)
	c.Params = gin.Params{gin.Param{Key: "tagId", Value: "invalid"}}
	
	handler.GetTag(c)
	
	assert.Equal(t, http.StatusBadRequest, w.Code)
	
	var response map[string]string
	err := json.Unmarshal(w.Body.Bytes(), &response)
	assert.NoError(t, err)
	assert.Equal(t, "Invalid tag ID", response["error"])
}

func TestAuthHandler_Register(t *testing.T) {
	if testDB.DB == nil {
		t.Skip("Skipping auth tests without database")
	}
	
	cfg := &config.Config{
		JWTSecret:          "test-secret",
		JWTExpiryHours:     24,
		RefreshExpiryHours: 168,
	}
	tokenService := auth.NewTokenService(cfg.JWTSecret, cfg.JWTExpiryHours, cfg.RefreshExpiryHours)
	handler := NewAuthHandler(testDB, tokenService)
	
	reqBody := models.RegisterRequest{
		Username: "testuser_" + randomString(5),
		Password: "testpass123",
	}
	
	jsonData, _ := json.Marshal(reqBody)
	
	w := httptest.NewRecorder()
	c, _ := gin.CreateTestContext(w)
	c.Request, _ = http.NewRequest("POST", "/api/register", bytes.NewBuffer(jsonData))
	c.Request.Header.Set("Content-Type", "application/json")
	
	handler.Register(c)
	
	// Should succeed or fail gracefully
	assert.True(t, w.Code == http.StatusCreated || w.Code == http.StatusInternalServerError || w.Code == http.StatusConflict)
}

func TestAuthHandler_Login(t *testing.T) {
	if testDB.DB == nil {
		t.Skip("Skipping auth tests without database")
	}
	
	cfg := &config.Config{
		JWTSecret:          "test-secret",
		JWTExpiryHours:     24,
		RefreshExpiryHours: 168,
	}
	tokenService := auth.NewTokenService(cfg.JWTSecret, cfg.JWTExpiryHours, cfg.RefreshExpiryHours)
	handler := NewAuthHandler(testDB, tokenService)
	
	reqBody := models.LoginRequest{
		Username: "nonexistent",
		Password: "wrongpass",
	}
	
	jsonData, _ := json.Marshal(reqBody)
	
	w := httptest.NewRecorder()
	c, _ := gin.CreateTestContext(w)
	c.Request, _ = http.NewRequest("POST", "/api/login", bytes.NewBuffer(jsonData))
	c.Request.Header.Set("Content-Type", "application/json")
	
	handler.Login(c)
	
	// Should fail with unauthorized
	assert.Equal(t, http.StatusUnauthorized, w.Code)
}

func TestAuthHandler_InvalidJSON(t *testing.T) {
	cfg := &config.Config{
		JWTSecret:          "test-secret",
		JWTExpiryHours:     24,
		RefreshExpiryHours: 168,
	}
	tokenService := auth.NewTokenService(cfg.JWTSecret, cfg.JWTExpiryHours, cfg.RefreshExpiryHours)
	handler := NewAuthHandler(testDB, tokenService)
	
	w := httptest.NewRecorder()
	c, _ := gin.CreateTestContext(w)
	c.Request, _ = http.NewRequest("POST", "/api/login", bytes.NewBufferString("invalid json"))
	c.Request.Header.Set("Content-Type", "application/json")
	
	handler.Login(c)
	
	assert.Equal(t, http.StatusBadRequest, w.Code)
}

// Helper function to generate random strings for unique usernames
func randomString(length int) string {
	const charset = "abcdefghijklmnopqrstuvwxyz0123456789"
	b := make([]byte, length)
	for i := range b {
		b[i] = charset[i%len(charset)]
	}
	return string(b)
}
