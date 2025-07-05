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

	// Get total works count
	err := h.db.QueryRow("SELECT COUNT(*) FROM works").Scan(&data.TotalWorks)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to get works count"})
		return
	}

	// Get total people count
	err = h.db.QueryRow("SELECT COUNT(*) FROM people").Scan(&data.TotalPeople)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to get people count"})
		return
	}

	// Get total shorts count
	err = h.db.QueryRow("SELECT COUNT(*) FROM shorts").Scan(&data.TotalShorts)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to get shorts count"})
		return
	}

	// Get total editions count
	err = h.db.QueryRow("SELECT COUNT(*) FROM editions").Scan(&data.TotalEditions)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to get editions count"})
		return
	}

	c.JSON(http.StatusOK, data)
}
