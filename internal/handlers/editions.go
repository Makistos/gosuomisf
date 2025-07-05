package handlers

import (
	"net/http"
	"strconv"

	"github.com/gin-gonic/gin"
	"github.com/makistos/gosuomisf/internal/database"
	"github.com/makistos/gosuomisf/internal/models"
)

type EditionHandler struct {
	db *database.DB
}

func NewEditionHandler(db *database.DB) *EditionHandler {
	return &EditionHandler{db: db}
}

func (h *EditionHandler) GetEditions(c *gin.Context) {
	var query models.PaginationQuery
	if err := c.ShouldBindQuery(&query); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	offset := (query.Page - 1) * query.PageSize

	baseQuery := `SELECT id, work_id, title, subtitle, publisher, publ_year, isbn, pages, format, description, created_at, updated_at FROM editions`
	countQuery := `SELECT COUNT(*) FROM editions`

	var args []interface{}
	var whereClause string

	if query.Search != "" {
		whereClause = " WHERE title LIKE ? OR publisher LIKE ? OR isbn LIKE ?"
		searchTerm := "%" + query.Search + "%"
		args = append(args, searchTerm, searchTerm, searchTerm)
		baseQuery += whereClause
		countQuery += whereClause
	}

	orderClause := " ORDER BY "
	switch query.Sort {
	case "title":
		orderClause += "title"
	case "year":
		orderClause += "publ_year"
	case "publisher":
		orderClause += "publisher"
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
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to query editions"})
		return
	}
	defer rows.Close()

	var editions []models.Edition
	for rows.Next() {
		var edition models.Edition
		err := rows.Scan(
			&edition.ID, &edition.WorkID, &edition.Title, &edition.Subtitle,
			&edition.Publisher, &edition.PublYear, &edition.ISBN, &edition.Pages,
			&edition.Format, &edition.Description, &edition.CreatedAt, &edition.UpdatedAt,
		)
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to scan edition"})
			return
		}
		editions = append(editions, edition)
	}

	totalPages := (total + query.PageSize - 1) / query.PageSize

	response := models.PaginatedResponse{
		Data:       editions,
		Page:       query.Page,
		PageSize:   query.PageSize,
		Total:      total,
		TotalPages: totalPages,
	}

	c.JSON(http.StatusOK, response)
}

func (h *EditionHandler) GetEdition(c *gin.Context) {
	editionID, err := strconv.Atoi(c.Param("editionId"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid edition ID"})
		return
	}

	var edition models.Edition
	query := `SELECT id, work_id, title, subtitle, publisher, publ_year, isbn, pages, format, description, created_at, updated_at FROM editions WHERE id = ?`
	err = h.db.QueryRow(query, editionID).Scan(
		&edition.ID, &edition.WorkID, &edition.Title, &edition.Subtitle,
		&edition.Publisher, &edition.PublYear, &edition.ISBN, &edition.Pages,
		&edition.Format, &edition.Description, &edition.CreatedAt, &edition.UpdatedAt,
	)
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Edition not found"})
		return
	}

	c.JSON(http.StatusOK, edition)
}
