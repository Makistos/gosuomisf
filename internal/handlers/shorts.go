package handlers

import (
	"net/http"
	"strconv"

	"github.com/gin-gonic/gin"
	"github.com/makistos/gosuomisf/internal/database"
	"github.com/makistos/gosuomisf/internal/models"
)

type ShortHandler struct {
	db *database.DB
}

func NewShortHandler(db *database.DB) *ShortHandler {
	return &ShortHandler{db: db}
}

func (h *ShortHandler) GetShorts(c *gin.Context) {
	var query models.PaginationQuery
	if err := c.ShouldBindQuery(&query); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	offset := (query.Page - 1) * query.PageSize

	baseQuery := `SELECT id, title, author, publ_year, language, description, length, created_at, updated_at FROM shorts`
	countQuery := `SELECT COUNT(*) FROM shorts`

	var args []interface{}
	var whereClause string

	if query.Search != "" {
		whereClause = " WHERE title LIKE ? OR author LIKE ? OR description LIKE ?"
		searchTerm := "%" + query.Search + "%"
		args = append(args, searchTerm, searchTerm, searchTerm)
		baseQuery += whereClause
		countQuery += whereClause
	}

	orderClause := " ORDER BY "
	switch query.Sort {
	case "title":
		orderClause += "title"
	case "author":
		orderClause += "author"
	case "year":
		orderClause += "publ_year"
	default:
		orderClause += "created_at"
	}

	if query.Order == "desc" {
		orderClause += " DESC"
	} else {
		orderClause += " ASC"
	}

	baseQuery += orderClause + " LIMIT ? OFFSET ?"
	args = append(args, query.PageSize, offset)

	var total int
	countArgs := args[:len(args)-2] // Remove limit and offset
	err := h.db.QueryRow(countQuery, countArgs...).Scan(&total)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to get total count"})
		return
	}

	rows, err := h.db.Query(baseQuery, args...)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to query shorts"})
		return
	}
	defer rows.Close()

	var shorts []models.Short
	for rows.Next() {
		var short models.Short
		err := rows.Scan(
			&short.ID, &short.Title, &short.Author, &short.PublYear,
			&short.Language, &short.Description, &short.Length,
			&short.CreatedAt, &short.UpdatedAt,
		)
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to scan short"})
			return
		}
		shorts = append(shorts, short)
	}

	totalPages := (total + query.PageSize - 1) / query.PageSize

	response := models.PaginatedResponse{
		Data:       shorts,
		Page:       query.Page,
		PageSize:   query.PageSize,
		Total:      total,
		TotalPages: totalPages,
	}

	c.JSON(http.StatusOK, response)
}

func (h *ShortHandler) GetShort(c *gin.Context) {
	shortID, err := strconv.Atoi(c.Param("shortId"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid short ID"})
		return
	}

	var short models.Short
	query := `SELECT id, title, author, publ_year, language, description, length, created_at, updated_at FROM shorts WHERE id = ?`
	err = h.db.QueryRow(query, shortID).Scan(
		&short.ID, &short.Title, &short.Author, &short.PublYear,
		&short.Language, &short.Description, &short.Length,
		&short.CreatedAt, &short.UpdatedAt,
	)
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Short not found"})
		return
	}

	c.JSON(http.StatusOK, short)
}
