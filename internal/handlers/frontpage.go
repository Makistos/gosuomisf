package handlers

import (
	"net/http"

	"github.com/gin-gonic/gin"
	"github.com/makistos/gosuomisf/internal/database"
	"github.com/makistos/gosuomisf/internal/models"
)

type FrontPageHandler struct {
	db *database.DB
}

func NewFrontPageHandler(db *database.DB) *FrontPageHandler {
	return &FrontPageHandler{db: db}
}

func (h *FrontPageHandler) GetFrontPageData(c *gin.Context) {
	var data models.FrontPageData

	// Check if database connection is available
	if h.db == nil || h.db.DB == nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Database not available"})
		return
	}

	// Get total works count
	err := h.db.QueryRow("SELECT COUNT(*) FROM suomisf.work").Scan(&data.TotalWorks)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to get works count"})
		return
	}

	// Get total people count
	err = h.db.QueryRow("SELECT COUNT(*) FROM suomisf.person").Scan(&data.TotalPeople)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to get people count"})
		return
	}

	// Get total shorts count
	err = h.db.QueryRow("SELECT COUNT(*) FROM suomisf.shortstory").Scan(&data.TotalShorts)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to get shorts count"})
		return
	}

	// Get total editions count
	err = h.db.QueryRow("SELECT COUNT(*) FROM suomisf.edition").Scan(&data.TotalEditions)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to get editions count"})
		return
	}

	c.JSON(http.StatusOK, data)
}
