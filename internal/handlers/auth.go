package handlers

import (
	"net/http"

	"github.com/gin-gonic/gin"
	"github.com/makistos/gosuomisf/internal/auth"
	"github.com/makistos/gosuomisf/internal/database"
	"github.com/makistos/gosuomisf/internal/models"
	"golang.org/x/crypto/bcrypt"
)

type AuthHandler struct {
	db           *database.DB
	tokenService *auth.TokenService
}

func NewAuthHandler(db *database.DB, tokenService *auth.TokenService) *AuthHandler {
	return &AuthHandler{
		db:           db,
		tokenService: tokenService,
	}
}

func (h *AuthHandler) Login(c *gin.Context) {
	var req models.LoginRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// Query user from database
	var user models.User
	var isAdmin bool
	query := `SELECT id, name, password_hash, is_admin FROM suomisf.user WHERE name = $1`
	err := h.db.QueryRow(query, req.Username).Scan(&user.ID, &user.Username, &user.Password, &isAdmin)
	if err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Invalid credentials"})
		return
	}

	// Set role based on is_admin flag
	if isAdmin {
		user.Role = "admin"
	} else {
		user.Role = "user"
	}

	// Verify password
	if err := bcrypt.CompareHashAndPassword([]byte(user.Password), []byte(req.Password)); err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Invalid credentials"})
		return
	}

	// Generate tokens
	accessToken, err := h.tokenService.GenerateAccessToken(user.ID, user.Username, user.Role)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to generate access token"})
		return
	}

	refreshToken, err := h.tokenService.GenerateRefreshToken(user.ID, user.Username)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to generate refresh token"})
		return
	}

	response := models.LoginResponse{
		AccessToken:  accessToken,
		RefreshToken: refreshToken,
		User:         user.Username,
		Role:         user.Role,
		ID:           user.ID,
	}

	c.JSON(http.StatusOK, response)
}

func (h *AuthHandler) Register(c *gin.Context) {
	var req models.RegisterRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// Check if user already exists
	var exists bool
	checkQuery := `SELECT EXISTS(SELECT 1 FROM suomisf.user WHERE name = $1)`
	err := h.db.QueryRow(checkQuery, req.Username).Scan(&exists)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Database error"})
		return
	}

	if exists {
		c.JSON(http.StatusConflict, gin.H{"error": "User already exists"})
		return
	}

	// Hash password
	hashedPassword, err := bcrypt.GenerateFromPassword([]byte(req.Password), bcrypt.DefaultCost)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to hash password"})
		return
	}

	// Insert user
	var userID int
	insertQuery := `
		INSERT INTO suomisf.user (name, password_hash, is_admin, language)
		VALUES ($1, $2, $3, $4) RETURNING id`
	err = h.db.QueryRow(insertQuery, req.Username, string(hashedPassword), false, 7).Scan(&userID) // 7 = Finnish language
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to create user"})
		return
	}

	c.JSON(http.StatusCreated, gin.H{
		"message": "User created successfully",
		"user_id": userID,
	})
}

func (h *AuthHandler) RefreshToken(c *gin.Context) {
	var req models.RefreshRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// Validate refresh token
	claims, err := h.tokenService.ValidateToken(req.RefreshToken)
	if err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Invalid refresh token"})
		return
	}

	// Get user from database to ensure they still exist and get current role
	var user models.User
	var isAdmin bool
	query := `SELECT id, name, is_admin FROM suomisf.user WHERE id = $1`
	err = h.db.QueryRow(query, claims.UserID).Scan(&user.ID, &user.Username, &isAdmin)
	if err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "User not found"})
		return
	}

	// Set role based on is_admin flag
	if isAdmin {
		user.Role = "admin"
	} else {
		user.Role = "user"
	}

	// Generate new access token
	accessToken, err := h.tokenService.GenerateAccessToken(user.ID, user.Username, user.Role)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to generate access token"})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"access_token": accessToken,
	})
}
