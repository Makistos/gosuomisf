package auth

import (
	"testing"

	"github.com/stretchr/testify/assert"
)

func TestNewTokenService(t *testing.T) {
	service := NewTokenService("test-secret", 24, 168)

	assert.NotNil(t, service)
	assert.NotNil(t, service.secretKey)
}

func TestGenerateAndValidateAccessToken(t *testing.T) {
	service := NewTokenService("test-secret", 24, 168)

	token, err := service.GenerateAccessToken(1, "testuser", "user")
	assert.NoError(t, err)
	assert.NotEmpty(t, token)

	claims, err := service.ValidateToken(token)
	assert.NoError(t, err)
	assert.Equal(t, 1, claims.UserID)
	assert.Equal(t, "testuser", claims.Username)
	assert.Equal(t, "user", claims.Role)
}

func TestGenerateAndValidateRefreshToken(t *testing.T) {
	service := NewTokenService("test-secret", 24, 168)

	token, err := service.GenerateRefreshToken(1, "testuser")
	assert.NoError(t, err)
	assert.NotEmpty(t, token)

	claims, err := service.ValidateToken(token)
	assert.NoError(t, err)
	assert.Equal(t, 1, claims.UserID)
	assert.Equal(t, "testuser", claims.Username)
}

func TestValidateInvalidToken(t *testing.T) {
	service := NewTokenService("test-secret", 24, 168)

	_, err := service.ValidateToken("invalid-token")
	assert.Error(t, err)
}

func TestValidateTokenWithWrongSecret(t *testing.T) {
	service1 := NewTokenService("secret1", 24, 168)
	service2 := NewTokenService("secret2", 24, 168)

	token, err := service1.GenerateAccessToken(1, "testuser", "user")
	assert.NoError(t, err)

	// Try to validate with different secret
	_, err = service2.ValidateToken(token)
	assert.Error(t, err)
}
