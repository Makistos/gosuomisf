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

	// Check if database connection is available
	if h.db == nil || h.db.DB == nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Database not available"})
		return
	}

	// Updated query to include counts and proper type structure
	baseQuery := `
		SELECT
			t.id,
			t.name,
			t.type_id,
			tt.name as type_name,
			t.description,
			COALESCE(work_counts.work_count, 0) as work_count,
			COALESCE(article_counts.article_count, 0) as article_count,
			COALESCE(story_counts.story_count, 0) as story_count
		FROM suomisf.tag t
		LEFT JOIN suomisf.tagtype tt ON t.type_id = tt.id
		LEFT JOIN (
			SELECT tag_id, COUNT(*) as work_count
			FROM suomisf.worktag
			GROUP BY tag_id
		) work_counts ON t.id = work_counts.tag_id
		LEFT JOIN (
			SELECT tag_id, COUNT(*) as article_count
			FROM suomisf.articletag
			GROUP BY tag_id
		) article_counts ON t.id = article_counts.tag_id
		LEFT JOIN (
			SELECT tag_id, COUNT(*) as story_count
			FROM suomisf.storytag
			GROUP BY tag_id
		) story_counts ON t.id = story_counts.tag_id`

	var args []interface{}
	var whereClause string

	if query.Search != "" {
		whereClause = " WHERE t.name ILIKE $1 OR t.description ILIKE $2"
		searchTerm := "%" + query.Search + "%"
		args = append(args, searchTerm, searchTerm)
		baseQuery += whereClause
	}

	orderClause := " ORDER BY "
	switch query.Sort {
	case "name":
		orderClause += "t.name"
	case "type":
		orderClause += "tt.name"
	case "id":
		orderClause += "t.id"
	default:
		orderClause += "t.name" // Default to ordering by name
	}

	if query.Order == "desc" {
		orderClause += " DESC"
	} else {
		orderClause += " ASC"
	}

	baseQuery += orderClause

	rows, err := h.db.Query(baseQuery, args...)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to query tags"})
		return
	}
	defer rows.Close()

	var tags []models.Tag
	for rows.Next() {
		var tag models.Tag
		var typeID sql.NullInt64
		var typeName sql.NullString
		var descNull sql.NullString

		err := rows.Scan(
			&tag.ID,
			&tag.Name,
			&typeID,
			&typeName,
			&descNull,
			&tag.WorkCount,
			&tag.ArticleCount,
			&tag.StoryCount,
		)
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to scan tag"})
			return
		}

		// Create TagType if type information is available
		if typeID.Valid && typeName.Valid {
			tag.Type = &models.TagType{
				ID:   int(typeID.Int64),
				Name: typeName.String,
			}
		}

		if descNull.Valid {
			tag.Description = &descNull.String
		}

		tags = append(tags, tag)
	}

	// Return the array directly instead of paginated response
	c.JSON(http.StatusOK, tags)
}

func (h *TagHandler) GetTag(c *gin.Context) {
	tagID, err := strconv.Atoi(c.Param("tagId"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid tag ID"})
		return
	}

	// Check if database connection is available
	if h.db == nil || h.db.DB == nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Database not available"})
		return
	}

	var tag models.Tag
	var typeID sql.NullInt64
	var typeName sql.NullString
	var descNull sql.NullString

	query := `
		SELECT
			t.id,
			t.name,
			t.type_id,
			tt.name as type_name,
			t.description,
			COALESCE(work_counts.work_count, 0) as work_count,
			COALESCE(article_counts.article_count, 0) as article_count,
			COALESCE(story_counts.story_count, 0) as story_count
		FROM suomisf.tag t
		LEFT JOIN suomisf.tagtype tt ON t.type_id = tt.id
		LEFT JOIN (
			SELECT tag_id, COUNT(*) as work_count
			FROM suomisf.worktag
			GROUP BY tag_id
		) work_counts ON t.id = work_counts.tag_id
		LEFT JOIN (
			SELECT tag_id, COUNT(*) as article_count
			FROM suomisf.articletag
			GROUP BY tag_id
		) article_counts ON t.id = article_counts.tag_id
		LEFT JOIN (
			SELECT tag_id, COUNT(*) as story_count
			FROM suomisf.storytag
			GROUP BY tag_id
		) story_counts ON t.id = story_counts.tag_id
		WHERE t.id = $1`

	err = h.db.QueryRow(query, tagID).Scan(
		&tag.ID,
		&tag.Name,
		&typeID,
		&typeName,
		&descNull,
		&tag.WorkCount,
		&tag.ArticleCount,
		&tag.StoryCount,
	)
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Tag not found"})
		return
	}

	// Create TagType if type information is available
	if typeID.Valid && typeName.Valid {
		tag.Type = &models.TagType{
			ID:   int(typeID.Int64),
			Name: typeName.String,
		}
	}

	if descNull.Valid {
		tag.Description = &descNull.String
	}

	c.JSON(http.StatusOK, tag)
}
