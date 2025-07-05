package handlers

import (
	"database/sql"
	"net/http"
	"strconv"

	"github.com/gin-gonic/gin"
	"github.com/makistos/gosuomisf/internal/database"
	"github.com/makistos/gosuomisf/internal/models"
)

type WorkHandler struct {
	db *database.DB
}

func NewWorkHandler(db *database.DB) *WorkHandler {
	return &WorkHandler{db: db}
}

func (h *WorkHandler) GetWorks(c *gin.Context) {
	var query models.PaginationQuery
	if err := c.ShouldBindQuery(&query); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	offset := (query.Page - 1) * query.PageSize

	baseQuery := `SELECT w.id, w.title, w.subtitle, w.orig_title, w.pubyear, w.language, l.name as language_name,
		w.bookseries_id, bs.name as bookseries_name, w.bookseriesnum, w.bookseriesorder,
		w.type, wt.name as type_name, w.misc, w.description, w.descr_attr, w.imported_string, w.author_str
		FROM work w
		LEFT JOIN worktype wt ON w.type = wt.id
		LEFT JOIN language l ON w.language = l.id
		LEFT JOIN bookseries bs ON w.bookseries_id = bs.id`
	countQuery := `SELECT COUNT(*) FROM work w`

	var args []interface{}
	var whereClause string

	if query.Search != "" {
		whereClause = " WHERE w.title LIKE ? OR w.orig_title LIKE ? OR w.description LIKE ?"
		searchTerm := "%" + query.Search + "%"
		args = append(args, searchTerm, searchTerm, searchTerm)
		baseQuery += whereClause
		countQuery += " LEFT JOIN worktype wt ON w.type = wt.id LEFT JOIN language l ON w.language = l.id LEFT JOIN bookseries bs ON w.bookseries_id = bs.id" + whereClause
	} else {
		// No search, no additional joins needed for count
		countQuery = `SELECT COUNT(*) FROM work`
	}

	orderClause := " ORDER BY "
	switch query.Sort {
	case "title":
		orderClause += "w.title"
	case "year":
		orderClause += "w.pubyear"
	case "type":
		orderClause += "wt.name"
	case "language":
		orderClause += "l.name"
	default:
		orderClause += "w.id"
	}

	if query.Order == "desc" {
		orderClause += " DESC"
	} else {
		orderClause += " ASC"
	}

	baseQuery += orderClause + " LIMIT ? OFFSET ?"
	args = append(args, query.PageSize, offset)

	var total int
	var countArgs []interface{}
	if query.Search != "" {
		countArgs = args[:len(args)-2] // Remove limit and offset
	}
	err := h.db.QueryRow(countQuery, countArgs...).Scan(&total)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to get total count"})
		return
	}

	rows, err := h.db.Query(baseQuery, args...)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to query works"})
		return
	}
	defer rows.Close()

	var works []models.Work
	for rows.Next() {
		var work models.Work
		var subtitleNull, origTitleNull, languageNameNull, bookseriesNameNull, bookseriesNumNull sql.NullString
		var pubYearNull, languageIDNull, bookseriesIDNull, bookseriesOrderNull, typeIDNull sql.NullInt32
		var typeNameNull, miscNull, descriptionNull, descrAttrNull, importedStringNull, authorStrNull sql.NullString

		err := rows.Scan(
			&work.ID, &work.Title, &subtitleNull, &origTitleNull, &pubYearNull,
			&languageIDNull, &languageNameNull, &bookseriesIDNull, &bookseriesNameNull,
			&bookseriesNumNull, &bookseriesOrderNull, &typeIDNull, &typeNameNull,
			&miscNull, &descriptionNull, &descrAttrNull, &importedStringNull, &authorStrNull,
		)
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to scan work"})
			return
		}

		// Handle nullable fields
		if subtitleNull.Valid {
			work.Subtitle = &subtitleNull.String
		}
		if origTitleNull.Valid {
			work.OrigTitle = &origTitleNull.String
		}
		if pubYearNull.Valid {
			pubYear := int(pubYearNull.Int32)
			work.PubYear = &pubYear
		}
		if languageIDNull.Valid {
			languageID := int(languageIDNull.Int32)
			work.LanguageID = &languageID
		}
		if languageNameNull.Valid {
			work.Language = &languageNameNull.String
		}
		if bookseriesIDNull.Valid {
			bookseriesID := int(bookseriesIDNull.Int32)
			work.BookseriesID = &bookseriesID
		}
		if bookseriesNameNull.Valid {
			work.BookseriesName = &bookseriesNameNull.String
		}
		if bookseriesNumNull.Valid {
			work.BookseriesNum = &bookseriesNumNull.String
		}
		if bookseriesOrderNull.Valid {
			bookseriesOrder := int(bookseriesOrderNull.Int32)
			work.BookseriesOrder = &bookseriesOrder
		}
		if typeIDNull.Valid {
			typeID := int(typeIDNull.Int32)
			work.TypeID = &typeID
		}
		if typeNameNull.Valid {
			work.Type = &typeNameNull.String
		}
		if miscNull.Valid {
			work.Misc = &miscNull.String
		}
		if descriptionNull.Valid {
			work.Description = &descriptionNull.String
		}
		if descrAttrNull.Valid {
			work.DescrAttr = &descrAttrNull.String
		}
		if importedStringNull.Valid {
			work.ImportedString = &importedStringNull.String
		}
		if authorStrNull.Valid {
			work.AuthorStr = &authorStrNull.String
		}

		works = append(works, work)
	}

	totalPages := (total + query.PageSize - 1) / query.PageSize

	response := models.PaginatedResponse{
		Data:       works,
		Page:       query.Page,
		PageSize:   query.PageSize,
		Total:      total,
		TotalPages: totalPages,
	}

	c.JSON(http.StatusOK, response)
}

func (h *WorkHandler) GetWork(c *gin.Context) {
	workID, err := strconv.Atoi(c.Param("workId"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid work ID"})
		return
	}

	var work models.Work
	var subtitleNull, origTitleNull, languageNameNull, bookseriesNameNull, bookseriesNumNull sql.NullString
	var pubYearNull, languageIDNull, bookseriesIDNull, bookseriesOrderNull, typeIDNull sql.NullInt32
	var typeNameNull, miscNull, descriptionNull, descrAttrNull, importedStringNull, authorStrNull sql.NullString

	query := `SELECT w.id, w.title, w.subtitle, w.orig_title, w.pubyear, w.language, l.name as language_name,
		w.bookseries_id, bs.name as bookseries_name, w.bookseriesnum, w.bookseriesorder,
		w.type, wt.name as type_name, w.misc, w.description, w.descr_attr, w.imported_string, w.author_str
		FROM work w
		LEFT JOIN worktype wt ON w.type = wt.id
		LEFT JOIN language l ON w.language = l.id
		LEFT JOIN bookseries bs ON w.bookseries_id = bs.id
		WHERE w.id = ?`

	err = h.db.QueryRow(query, workID).Scan(
		&work.ID, &work.Title, &subtitleNull, &origTitleNull, &pubYearNull,
		&languageIDNull, &languageNameNull, &bookseriesIDNull, &bookseriesNameNull,
		&bookseriesNumNull, &bookseriesOrderNull, &typeIDNull, &typeNameNull,
		&miscNull, &descriptionNull, &descrAttrNull, &importedStringNull, &authorStrNull,
	)
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Work not found"})
		return
	}

	// Handle nullable fields
	if subtitleNull.Valid {
		work.Subtitle = &subtitleNull.String
	}
	if origTitleNull.Valid {
		work.OrigTitle = &origTitleNull.String
	}
	if pubYearNull.Valid {
		pubYear := int(pubYearNull.Int32)
		work.PubYear = &pubYear
	}
	if languageIDNull.Valid {
		languageID := int(languageIDNull.Int32)
		work.LanguageID = &languageID
	}
	if languageNameNull.Valid {
		work.Language = &languageNameNull.String
	}
	if bookseriesIDNull.Valid {
		bookseriesID := int(bookseriesIDNull.Int32)
		work.BookseriesID = &bookseriesID
	}
	if bookseriesNameNull.Valid {
		work.BookseriesName = &bookseriesNameNull.String
	}
	if bookseriesNumNull.Valid {
		work.BookseriesNum = &bookseriesNumNull.String
	}
	if bookseriesOrderNull.Valid {
		bookseriesOrder := int(bookseriesOrderNull.Int32)
		work.BookseriesOrder = &bookseriesOrder
	}
	if typeIDNull.Valid {
		typeID := int(typeIDNull.Int32)
		work.TypeID = &typeID
	}
	if typeNameNull.Valid {
		work.Type = &typeNameNull.String
	}
	if miscNull.Valid {
		work.Misc = &miscNull.String
	}
	if descriptionNull.Valid {
		work.Description = &descriptionNull.String
	}
	if descrAttrNull.Valid {
		work.DescrAttr = &descrAttrNull.String
	}
	if importedStringNull.Valid {
		work.ImportedString = &importedStringNull.String
	}
	if authorStrNull.Valid {
		work.AuthorStr = &authorStrNull.String
	}

	c.JSON(http.StatusOK, work)
}

func (h *WorkHandler) GetWorkAwards(c *gin.Context) {
	workID, err := strconv.Atoi(c.Param("workId"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid work ID"})
		return
	}

	query := `SELECT id, work_id, name, year, category, winner FROM awards WHERE work_id = ?`
	rows, err := h.db.Query(query, workID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to query awards"})
		return
	}
	defer rows.Close()

	var awards []models.Award
	for rows.Next() {
		var award models.Award
		err := rows.Scan(&award.ID, &award.WorkID, &award.Name, &award.Year, &award.Category, &award.Winner)
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to scan award"})
			return
		}
		awards = append(awards, award)
	}

	c.JSON(http.StatusOK, awards)
}
