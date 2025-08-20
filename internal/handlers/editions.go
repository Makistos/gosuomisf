package handlers

import (
	"database/sql"
	"fmt"
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

	baseQuery := `SELECT e.id, e.title, e.subtitle, e.pubyear, e.editionnum, e.version, e.isbn, e.pages, e.dustcover, e.coverimage,
		e.pubseriesnum, e.coll_info, e.verified, e.imported_string, e.misc, e.size,
		p.id as publisher_id, p.name as publisher_name, p.fullname as publisher_fullname, p.description as publisher_description,
		bt.id as binding_id, bt.name as binding_name,
		ps.id as pubseries_id, ps.name as pubseries_name
		FROM suomisf.edition e
		LEFT JOIN suomisf.publisher p ON e.publisher_id = p.id
		LEFT JOIN suomisf.bindingtype bt ON e.binding_id = bt.id
		LEFT JOIN suomisf.pubseries ps ON e.pubseries_id = ps.id`
	countQuery := `SELECT COUNT(*) FROM suomisf.edition e`

	var args []interface{}
	var whereClause string

	if query.Search != "" {
		whereClause = " WHERE e.title LIKE $1 OR p.name LIKE $2 OR e.isbn LIKE $3"
		searchTerm := "%" + query.Search + "%"
		args = append(args, searchTerm, searchTerm, searchTerm)
		baseQuery += whereClause
		countQuery += whereClause
	}

	orderClause := " ORDER BY "
	switch query.Sort {
	case "title":
		orderClause += "e.title"
	case "year":
		orderClause += "e.pubyear"
	case "publisher":
		orderClause += "p.name"
	default:
		orderClause += "e.id"
	}

	if query.Order == "desc" {
		orderClause += " DESC"
	} else {
		orderClause += " ASC"
	}

	argCount := len(args)
	baseQuery += orderClause + fmt.Sprintf(" LIMIT $%d OFFSET $%d", argCount+1, argCount+2)
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
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to query editions"})
		return
	}
	defer rows.Close()

	var editions []models.Edition
	for rows.Next() {
		var edition models.Edition
		var eTitle, eSubtitle, isbn, collInfo, importedString, misc sql.NullString
		var pubYear, version, pages, dustCover, coverImage, size, pubSeriesNum sql.NullInt64
		var editionNum int64
		var publisherID, bindingID, pubSeriesID sql.NullInt64
		var publisherName, publisherFullname, publisherDescription sql.NullString
		var bindingName, pubSeriesName sql.NullString
		var verified sql.NullBool

		err := rows.Scan(
			&edition.ID, &eTitle, &eSubtitle, &pubYear, &editionNum, &version, &isbn, &pages, &dustCover, &coverImage,
			&pubSeriesNum, &collInfo, &verified, &importedString, &misc, &size,
			&publisherID, &publisherName, &publisherFullname, &publisherDescription,
			&bindingID, &bindingName, &pubSeriesID, &pubSeriesName,
		)
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to scan edition"})
			return
		}

		// Handle nullable fields
		if eTitle.Valid {
			edition.Title = &eTitle.String
		}
		if eSubtitle.Valid {
			edition.Subtitle = &eSubtitle.String
		}
		if pubYear.Valid {
			year := int(pubYear.Int64)
			edition.PubYear = &year
		}
		// EditionNum must be valid and greater than 0
		if editionNum <= 0 {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Invalid edition number in database"})
			return
		}
		num := int(editionNum)
		edition.EditionNum = &num
		if version.Valid {
			ver := int(version.Int64)
			edition.Version = &ver
		}
		if isbn.Valid {
			edition.ISBN = &isbn.String
		}
		if pages.Valid {
			p := int(pages.Int64)
			edition.Pages = &p
		}
		if dustCover.Valid {
			dc := int(dustCover.Int64)
			edition.DustCover = &dc
		}
		if coverImage.Valid {
			ci := int(coverImage.Int64)
			edition.CoverImage = &ci
		}
		if pubSeriesNum.Valid {
			psn := int(pubSeriesNum.Int64)
			edition.PubSeriesNum = &psn
		}
		if collInfo.Valid {
			edition.CollInfo = &collInfo.String
		}
		if verified.Valid {
			edition.Verified = &verified.Bool
		}
		if importedString.Valid {
			edition.ImportedString = &importedString.String
		}
		if misc.Valid {
			edition.Misc = &misc.String
		}
		if size.Valid {
			s := int(size.Int64)
			edition.Size = &s
		}

		// Create publisher object if publisher data exists
		if publisherID.Valid {
			publisher := make(map[string]interface{})
			publisher["id"] = int(publisherID.Int64)

			if publisherName.Valid {
				publisher["name"] = publisherName.String
			} else {
				publisher["name"] = nil
			}

			if publisherFullname.Valid {
				publisher["fullname"] = publisherFullname.String
			} else {
				publisher["fullname"] = nil
			}

			if publisherDescription.Valid {
				publisher["description"] = publisherDescription.String
			} else {
				publisher["description"] = nil
			}

			edition.Publisher = &publisher
		} else {
			edition.Publisher = nil
		}

		// Create binding object if binding data exists
		if bindingID.Valid && bindingName.Valid {
			edition.Binding = &models.Binding{
				ID:   int(bindingID.Int64),
				Name: bindingName.String,
			}
		} else {
			edition.Binding = nil
		}

		// Create pubseries object if pubseries data exists
		if pubSeriesID.Valid && pubSeriesName.Valid {
			edition.PubSeries = &models.PubSeries{
				ID:   int(pubSeriesID.Int64),
				Name: pubSeriesName.String,
			}
		} else {
			edition.PubSeries = nil
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
	var eTitle, eSubtitle, isbn, printedIn, collInfo sql.NullString
	var misc, importedString, publisherName, publisherFullname, publisherDescription sql.NullString
	var bindingName, pubSeriesName sql.NullString
	var workID, pubYear, version, pages, size, dustCover, coverImage, pubSeriesNum sql.NullInt64
	var editionNum int64
	var publisherID, bindingID, pubSeriesID sql.NullInt64
	var verified sql.NullBool

	query := `
		SELECT e.id, pt.work_id, e.title, e.subtitle, e.pubyear, e.editionnum, e.version, e.isbn,
		       e.printedin, e.pubseriesnum, e.coll_info, e.pages, e.size, e.dustcover,
		       e.coverimage, e.misc, e.imported_string, e.verified,
		       e.publisher_id, p.name as publisher_name, p.fullname as publisher_fullname, p.description as publisher_description,
		       bt.id as binding_id, bt.name as binding_name,
		       ps.id as pubseries_id, ps.name as pubseries_name
		FROM suomisf.edition e
		LEFT JOIN suomisf.part pt ON e.id = pt.edition_id
		LEFT JOIN suomisf.publisher p ON e.publisher_id = p.id
		LEFT JOIN suomisf.bindingtype bt ON e.binding_id = bt.id
		LEFT JOIN suomisf.pubseries ps ON e.pubseries_id = ps.id
		WHERE e.id = $1`

	err = h.db.QueryRow(query, editionID).Scan(
		&edition.ID, &workID, &eTitle, &eSubtitle, &pubYear, &editionNum, &version,
		&isbn, &printedIn, &pubSeriesNum, &collInfo, &pages, &size, &dustCover,
		&coverImage, &misc, &importedString, &verified, &publisherID, &publisherName, &publisherFullname, &publisherDescription,
		&bindingID, &bindingName, &pubSeriesID, &pubSeriesName,
	)
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Edition not found"})
		return
	}

	// Handle nullable fields
	if workID.Valid {
		wid := int(workID.Int64)
		edition.WorkID = &wid
	}
	if eTitle.Valid {
		edition.Title = &eTitle.String
	}
	if eSubtitle.Valid {
		edition.Subtitle = &eSubtitle.String
	}
	if pubYear.Valid {
		year := int(pubYear.Int64)
		edition.PubYear = &year
	}
	// EditionNum must be valid and greater than 0
	if editionNum <= 0 {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Invalid edition number in database"})
		return
	}
	num := int(editionNum)
	edition.EditionNum = &num
	if version.Valid {
		ver := int(version.Int64)
		edition.Version = &ver
	}
	if isbn.Valid {
		edition.ISBN = &isbn.String
	}
	if printedIn.Valid {
		edition.PrintedIn = &printedIn.String
	}
	if pubSeriesNum.Valid {
		val := int(pubSeriesNum.Int64)
		edition.PubSeriesNum = &val
	}
	if collInfo.Valid {
		edition.CollInfo = &collInfo.String
	}
	if pages.Valid {
		p := int(pages.Int64)
		edition.Pages = &p
	}
	if size.Valid {
		s := int(size.Int64)
		edition.Size = &s
	}
	if dustCover.Valid {
		dc := int(dustCover.Int64)
		edition.DustCover = &dc
	}
	if coverImage.Valid {
		ci := int(coverImage.Int64)
		edition.CoverImage = &ci
	}
	if misc.Valid {
		edition.Misc = &misc.String
	}
	if importedString.Valid {
		edition.ImportedString = &importedString.String
	}
	if verified.Valid {
		edition.Verified = &verified.Bool
	}

	// Create publisher object if publisher data exists
	if publisherID.Valid {
		publisher := make(map[string]interface{})
		publisher["id"] = int(publisherID.Int64)

		if publisherName.Valid {
			publisher["name"] = publisherName.String
		} else {
			publisher["name"] = nil
		}

		if publisherFullname.Valid {
			publisher["fullname"] = publisherFullname.String
		} else {
			publisher["fullname"] = nil
		}

		if publisherDescription.Valid {
			publisher["description"] = publisherDescription.String
		} else {
			publisher["description"] = nil
		}

		edition.Publisher = &publisher
	} else {
		edition.Publisher = nil
	}

	// Create binding object if binding data exists
	if bindingID.Valid && bindingName.Valid {
		edition.Binding = &models.Binding{
			ID:   int(bindingID.Int64),
			Name: bindingName.String,
		}
	} else {
		edition.Binding = nil
	}

	// Create pubseries object if pubseries data exists
	if pubSeriesID.Valid && pubSeriesName.Valid {
		edition.PubSeries = &models.PubSeries{
			ID:   int(pubSeriesID.Int64),
			Name: pubSeriesName.String,
		}
	} else {
		edition.PubSeries = nil
	}

	c.JSON(http.StatusOK, edition)
}
