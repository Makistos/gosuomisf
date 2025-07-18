package handlers

import (
	"database/sql"
	"net/http"
	"strconv"

	"github.com/gin-gonic/gin"
	"github.com/makistos/gosuomisf/internal/database"
	"github.com/makistos/gosuomisf/internal/models"
)

type TagHandler struct {
	db *database.DB
}

func NewTagHandler(db *database.DB) *TagHandler {
	return &TagHandler{db: db}
}

func (h *TagHandler) GetTags(c *gin.Context) {
	var query models.PaginationQuery
	if err := c.ShouldBindQuery(&query); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	offset := (query.Page - 1) * query.PageSize

	baseQuery := `SELECT t.id, t.name, tt.name as type, t.type_id, t.description FROM tag t LEFT JOIN tagtype tt ON t.type_id = tt.id`
	countQuery := `SELECT COUNT(*) FROM tag`

	var args []interface{}
	var whereClause string

	if query.Search != "" {
		whereClause = " WHERE t.name LIKE ? OR t.description LIKE ?"
		searchTerm := "%" + query.Search + "%"
		args = append(args, searchTerm, searchTerm)
		baseQuery += whereClause
		countQuery += whereClause
	}

	orderClause := " ORDER BY "
	switch query.Sort {
	case "name":
		orderClause += "t.name"
	case "type":
		orderClause += "tt.name"
	default:
		orderClause += "t.id"
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
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to query tags"})
		return
	}
	defer rows.Close()

	var tags []models.Tag
	for rows.Next() {
		var tag models.Tag
		var typeNull sql.NullString
		var descNull sql.NullString

		err := rows.Scan(
			&tag.ID, &tag.Name, &typeNull, &tag.TypeID, &descNull,
		)
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to scan tag"})
			return
		}

		if typeNull.Valid {
			tag.Type = &typeNull.String
		}
		if descNull.Valid {
			tag.Description = &descNull.String
		}

		tags = append(tags, tag)
	}

	totalPages := (total + query.PageSize - 1) / query.PageSize

	response := models.PaginatedResponse{
		Data:       tags,
		Page:       query.Page,
		PageSize:   query.PageSize,
		Total:      total,
		TotalPages: totalPages,
	}

	c.JSON(http.StatusOK, response)
}

func (h *TagHandler) GetTag(c *gin.Context) {
	tagID, err := strconv.Atoi(c.Param("tagId"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid tag ID"})
		return
	}

	var tag models.Tag
	var typeNull sql.NullString
	var descNull sql.NullString

	query := `SELECT t.id, t.name, tt.name as type, t.type_id, t.description FROM tag t LEFT JOIN tagtype tt ON t.type_id = tt.id WHERE t.id = ?`
	err = h.db.QueryRow(query, tagID).Scan(
		&tag.ID, &tag.Name, &typeNull, &tag.TypeID, &descNull,
	)
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Tag not found"})
		return
	}

	if typeNull.Valid {
		tag.Type = &typeNull.String
	}
	if descNull.Valid {
		tag.Description = &descNull.String
	}
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Tag not found"})
		return
	}

	c.JSON(http.StatusOK, tag)
}
