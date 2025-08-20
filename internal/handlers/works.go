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
		whereClause = " WHERE w.title ILIKE $1 OR w.orig_title ILIKE $2 OR w.description ILIKE $3"
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
	if h.db == nil || h.db.DB == nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Database connection not available"})
		return
	}

	workID, err := strconv.Atoi(c.Param("workId"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid work ID"})
		return
	}

	var work models.Work
	// Initialize the new fields as empty slices
	work.Genres = []map[string]interface{}{}
	work.Tags = []models.Tag{}
	work.Links = []map[string]interface{}{}
	work.Awards = []map[string]interface{}{}
	work.Stories = []map[string]interface{}{}

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
		WHERE w.id = $1`

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
		work.LanguageName = &languageNameNull.String
	}
	if bookseriesIDNull.Valid && bookseriesNameNull.Valid {
		bookseriesID := int(bookseriesIDNull.Int32)
		work.BookseriesID = &bookseriesID
		work.BookseriesName = &bookseriesNameNull.String

		// Create bookseries object
		bookseries := map[string]interface{}{
			"id":   bookseriesID,
			"name": bookseriesNameNull.String,
		}
		work.Bookseries = &bookseries
	} else if bookseriesIDNull.Valid {
		bookseriesID := int(bookseriesIDNull.Int32)
		work.BookseriesID = &bookseriesID
	} else if bookseriesNameNull.Valid {
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

	// Fetch editions for this work
	editionsQuery := `
		SELECT e.id, e.title, e.subtitle, e.pubyear, e.editionnum, e.version, e.isbn,
		       e.printedin, e.pubseriesnum, e.coll_info, e.pages, e.size, e.dustcover,
		       e.coverimage, e.misc, e.imported_string, e.verified,
		       p.id as publisher_id, p.name as publisher_name, p.fullname as publisher_fullname, p.description as publisher_description
		FROM suomisf.edition e
		INNER JOIN suomisf.part pt ON e.id = pt.edition_id
		LEFT JOIN suomisf.publisher p ON e.publisher_id = p.id
		WHERE pt.work_id = $1 and pt.shortstory_id IS NULL
		ORDER BY e.pubyear, e.editionnum`

	editionsRows, err := h.db.Query(editionsQuery, workID)
	work.Editions = make([]models.Edition, 0) // Initialize as empty slice

	if err != nil {
		// If there's an error fetching editions, create a default edition
		defaultEdition := models.Edition{
			ID:            -1, // Use -1 to indicate this is a generated edition
			Title:         &work.Title,
			Publisher:     nil,                               // No publisher for default edition
			Images:        make([]map[string]interface{}, 0), // Initialize as empty slice
			Owners:        make([]map[string]interface{}, 0), // Initialize as empty slice
			Wishlisted:    make([]map[string]interface{}, 0), // Initialize as empty slice
			Contributions: make([]map[string]interface{}, 0), // Initialize as empty slice
		}
		if work.PubYear != nil {
			defaultEdition.PubYear = work.PubYear
		}
		work.Editions = append(work.Editions, defaultEdition)
	} else {
		defer editionsRows.Close()
		editionCount := 0

		for editionsRows.Next() {
			editionCount++
			var edition models.Edition
			var eTitle, eSubtitle, isbn, printedIn, pubSeriesNum, collInfo sql.NullString
			var misc, importedString, publisherName, publisherFullname, publisherDescription sql.NullString
			var pubYear, version, pages, size, dustCover, coverImage sql.NullInt64
			var editionNum int64
			var publisherID sql.NullInt64
			var verified sql.NullBool

			err := editionsRows.Scan(&edition.ID, &eTitle, &eSubtitle, &pubYear, &editionNum, &version,
				&isbn, &printedIn, &pubSeriesNum, &collInfo, &pages, &size, &dustCover,
				&coverImage, &misc, &importedString, &verified, &publisherID, &publisherName, &publisherFullname, &publisherDescription)

			if err != nil {
				continue // Skip this edition if there's an error
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
			// EditionNum should always have a value, default to 1 if 0
			if editionNum == 0 {
				editionNum = 1
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
				edition.PubSeriesNum = &pubSeriesNum.String
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

			// Query edition images
			imagesQuery := `
				SELECT id, image_src, image_attr
				FROM suomisf.editionimage
				WHERE edition_id = $1
				ORDER BY id`

			imagesRows, err := h.db.Query(imagesQuery, edition.ID)
			edition.Images = make([]map[string]interface{}, 0) // Initialize as empty slice
			if err == nil {
				defer imagesRows.Close()
				for imagesRows.Next() {
					var image map[string]interface{} = make(map[string]interface{})
					var imageID int
					var imageSrc, imageAttr sql.NullString

					err := imagesRows.Scan(&imageID, &imageSrc, &imageAttr)
					if err == nil {
						image["id"] = imageID
						if imageSrc.Valid {
							image["image_src"] = imageSrc.String
						}
						if imageAttr.Valid {
							image["image_attr"] = imageAttr.String
						} else {
							image["image_attr"] = nil
						}
						edition.Images = append(edition.Images, image)
					}
				}
			}

			// Query edition owners (condition_id < 6)
			ownersQuery := `
				SELECT u.id, u.name
				FROM suomisf."user" u
				INNER JOIN suomisf.userbook ub ON u.id = ub.user_id
				WHERE ub.edition_id = $1 AND ub.condition_id < 6
				ORDER BY u.name`

			ownersRows, err := h.db.Query(ownersQuery, edition.ID)
			edition.Owners = make([]map[string]interface{}, 0) // Initialize as empty slice
			if err == nil {
				defer ownersRows.Close()
				for ownersRows.Next() {
					var owner map[string]interface{} = make(map[string]interface{})
					var ownerID int
					var ownerName sql.NullString

					err := ownersRows.Scan(&ownerID, &ownerName)
					if err == nil {
						owner["id"] = ownerID
						if ownerName.Valid {
							owner["name"] = ownerName.String
						}
						edition.Owners = append(edition.Owners, owner)
					}
				}
			}

			// Query edition wishlisted users (condition_id == 6)
			wishlistedQuery := `
				SELECT u.id, u.name
				FROM suomisf."user" u
				INNER JOIN suomisf.userbook ub ON u.id = ub.user_id
				WHERE ub.edition_id = $1 AND ub.condition_id = 6
				ORDER BY u.name`

			wishlistedRows, err := h.db.Query(wishlistedQuery, edition.ID)
			edition.Wishlisted = make([]map[string]interface{}, 0) // Initialize as empty slice
			if err == nil {
				defer wishlistedRows.Close()
				for wishlistedRows.Next() {
					var wishlisted map[string]interface{} = make(map[string]interface{})
					var wishlistedID int
					var wishlistedName sql.NullString

					err := wishlistedRows.Scan(&wishlistedID, &wishlistedName)
					if err == nil {
						wishlisted["id"] = wishlistedID
						if wishlistedName.Valid {
							wishlisted["name"] = wishlistedName.String
						}
						edition.Wishlisted = append(edition.Wishlisted, wishlisted)
					}
				}
			}

			// Query edition contributions (translators, editors, etc.) - only role_ids 2, 4, 5
			editionContributionsQuery := `
				SELECT DISTINCT p.id, p.name, p.alt_name, cr.id as role_id, cr.name as role_name,
				       c.description, c.real_person_id, rp.name as real_person_name
				FROM suomisf.part pt
				INNER JOIN suomisf.contributor c ON pt.id = c.part_id
				INNER JOIN suomisf.person p ON c.person_id = p.id
				INNER JOIN suomisf.contributorrole cr ON c.role_id = cr.id
				LEFT JOIN suomisf.person rp ON c.real_person_id = rp.id
				WHERE pt.edition_id = $1 AND cr.id IN (2, 4, 5)
				ORDER BY p.name`

			editionContribRows, err := h.db.Query(editionContributionsQuery, edition.ID)
			edition.Contributions = make([]map[string]interface{}, 0) // Initialize as empty slice
			if err == nil {
				defer editionContribRows.Close()
				for editionContribRows.Next() {
					var contrib map[string]interface{} = make(map[string]interface{})
					var personID, roleID int
					var personName, personAltName, roleName, description, realPersonName sql.NullString
					var realPersonID sql.NullInt64

					err := editionContribRows.Scan(&personID, &personName, &personAltName, &roleID, &roleName,
						&description, &realPersonID, &realPersonName)
					if err == nil {
						// Person object
						person := map[string]interface{}{
							"id": personID,
						}
						if personName.Valid {
							person["name"] = personName.String
						}
						if personAltName.Valid {
							person["alt_name"] = personAltName.String
						}
						contrib["person"] = person

						// Role object
						if roleName.Valid {
							contrib["role"] = map[string]interface{}{
								"id":   roleID,
								"name": roleName.String,
							}
						}

						// Description
						if description.Valid {
							contrib["description"] = description.String
						} else {
							contrib["description"] = nil
						}

						// Real person (if exists)
						if realPersonID.Valid && realPersonName.Valid {
							contrib["real_person"] = map[string]interface{}{
								"id":   int(realPersonID.Int64),
								"name": realPersonName.String,
							}
						} else {
							contrib["real_person"] = nil
						}

						edition.Contributions = append(edition.Contributions, contrib)
					}
				}
			}

			work.Editions = append(work.Editions, edition)
		}

		// Ensure at least one edition exists
		if editionCount == 0 {
			defaultEdition := models.Edition{
				ID:            -1, // Use -1 to indicate this is a generated edition
				Title:         &work.Title,
				Images:        make([]map[string]interface{}, 0), // Initialize as empty slice
				Owners:        make([]map[string]interface{}, 0), // Initialize as empty slice
				Wishlisted:    make([]map[string]interface{}, 0), // Initialize as empty slice
				Contributions: make([]map[string]interface{}, 0), // Initialize as empty slice
			}
			if work.PubYear != nil {
				defaultEdition.PubYear = work.PubYear
			}
			work.Editions = append(work.Editions, defaultEdition)
		}
	}

	// Query work contributions (contributors) - only role_ids 1 and 3
	contributionsQuery := `
		SELECT DISTINCT p.id, p.name, p.alt_name, cr.id as role_id, cr.name as role_name,
		       c.description, c.real_person_id, rp.name as real_person_name
		FROM suomisf.part pt
		INNER JOIN suomisf.contributor c ON pt.id = c.part_id
		INNER JOIN suomisf.person p ON c.person_id = p.id
		INNER JOIN suomisf.contributorrole cr ON c.role_id = cr.id
		LEFT JOIN suomisf.person rp ON c.real_person_id = rp.id
		WHERE pt.work_id = $1 AND cr.id IN (1, 3)
		ORDER BY p.name`

	contributionsRows, err := h.db.Query(contributionsQuery, workID)
	work.Contributions = make([]map[string]interface{}, 0) // Initialize as empty slice
	if err == nil {
		defer contributionsRows.Close()
		for contributionsRows.Next() {
			var contribution map[string]interface{} = make(map[string]interface{})
			var personID, roleID int
			var personName, personAltName, roleName, description, realPersonName sql.NullString
			var realPersonID sql.NullInt64

			err := contributionsRows.Scan(&personID, &personName, &personAltName, &roleID, &roleName,
				&description, &realPersonID, &realPersonName)
			if err == nil {
				// Person object
				person := map[string]interface{}{
					"id": personID,
				}
				if personName.Valid {
					person["name"] = personName.String
				}
				if personAltName.Valid {
					person["alt_name"] = personAltName.String
				}
				contribution["person"] = person

				// Role object
				if roleName.Valid {
					contribution["role"] = map[string]interface{}{
						"id":   roleID,
						"name": roleName.String,
					}
				}

				// Description
				if description.Valid {
					contribution["description"] = description.String
				} else {
					contribution["description"] = nil
				}

				// Real person (if exists)
				if realPersonID.Valid && realPersonName.Valid {
					contribution["real_person"] = map[string]interface{}{
						"id":   int(realPersonID.Int64),
						"name": realPersonName.String,
					}
				} else {
					contribution["real_person"] = nil
				}

				work.Contributions = append(work.Contributions, contribution)
			}
		}
	}

	// Query work genres
	work.Genres = []map[string]interface{}{} // Initialize as empty slice
	genresQuery := `
		SELECT g.id, g.name, g.abbr
		FROM suomisf.genre g
		JOIN suomisf.workgenre wg ON g.id = wg.genre_id
		WHERE wg.work_id = $1
		ORDER BY g.name`

	genresRows, err := h.db.Query(genresQuery, workID)
	if err == nil {
		defer genresRows.Close()
		for genresRows.Next() {
			var genreID int
			var genreName, genreAbbr sql.NullString

			err := genresRows.Scan(&genreID, &genreName, &genreAbbr)
			if err != nil {
				continue // Skip this genre if there's an error
			}

			genre := map[string]interface{}{
				"id":   genreID,
				"name": genreName.String,
			}
			if genreAbbr.Valid {
				genre["abbr"] = genreAbbr.String
			} else {
				genre["abbr"] = nil
			}

			work.Genres = append(work.Genres, genre)
		}
	}

	// Query work tags
	work.Tags = []models.Tag{} // Initialize as empty slice
	tagsQuery := `
		SELECT t.id, t.name, t.description, tt.id as type_id, tt.name as type_name
		FROM suomisf.tag t
		JOIN suomisf.worktag wt ON t.id = wt.tag_id
		LEFT JOIN suomisf.tagtype tt ON t.type_id = tt.id
		WHERE wt.work_id = $1`

	tagsRows, err := h.db.Query(tagsQuery, workID)
	if err == nil {
		defer tagsRows.Close()
		for tagsRows.Next() {
			var tag models.Tag
			var tagDesc sql.NullString
			var typeID sql.NullInt32
			var typeName sql.NullString

			err := tagsRows.Scan(&tag.ID, &tag.Name, &tagDesc, &typeID, &typeName)
			if err != nil {
				continue // Skip this tag if there's an error
			}

			if tagDesc.Valid {
				tag.Description = &tagDesc.String
			}

			if typeID.Valid && typeName.Valid {
				tag.Type = &models.TagType{
					ID:   int(typeID.Int32),
					Name: typeName.String,
				}
			}

			work.Tags = append(work.Tags, tag)
		}
	}

	// Query work links
	work.Links = []map[string]interface{}{} // Initialize as empty slice
	linksQuery := `
		SELECT wl.id, wl.link, wl.description
		FROM suomisf.worklink wl
		WHERE wl.work_id = $1
		ORDER BY wl.id`

	linksRows, err := h.db.Query(linksQuery, workID)
	if err == nil {
		defer linksRows.Close()
		for linksRows.Next() {
			var linkID int
			var linkURL string
			var linkDesc sql.NullString

			err := linksRows.Scan(&linkID, &linkURL, &linkDesc)
			if err != nil {
				continue // Skip this link if there's an error
			}

			link := map[string]interface{}{
				"id":   linkID,
				"link": linkURL,
			}
			if linkDesc.Valid {
				link["description"] = linkDesc.String
			} else {
				link["description"] = nil
			}

			work.Links = append(work.Links, link)
		}
	}

	// Query work awards
	work.Awards = []map[string]interface{}{} // Initialize as empty slice
	awardsQuery := `
		SELECT aw.id, aw.year, a.id as award_id, a.name as award_name,
		       ac.id as category_id, ac.name as category_name,
		       w.id as work_id, w.title as work_title,
		       s.id as story_id, s.title as story_title
		FROM suomisf.awarded aw
		JOIN suomisf.award a ON aw.award_id = a.id
		LEFT JOIN suomisf.awardcategory ac ON aw.category_id = ac.id
		LEFT JOIN suomisf.work w ON aw.work_id = w.id
		LEFT JOIN suomisf.shortstory s ON aw.story_id = s.id
		WHERE aw.work_id = $1
		ORDER BY aw.year DESC, a.name`

	awardsRows, err := h.db.Query(awardsQuery, workID)
	if err == nil {
		defer awardsRows.Close()
		for awardsRows.Next() {
			var awardedID, year, awardID int
			var awardName string
			var categoryID sql.NullInt32
			var categoryName sql.NullString
			var workAwardID sql.NullInt32
			var workTitle sql.NullString
			var shortID sql.NullInt32
			var shortTitle sql.NullString

			err := awardsRows.Scan(&awardedID, &year, &awardID, &awardName, &categoryID, &categoryName,
				&workAwardID, &workTitle, &shortID, &shortTitle)
			if err != nil {
				continue // Skip this award if there's an error
			}

			award := map[string]interface{}{
				"id":   awardedID,
				"year": year,
				"award": map[string]interface{}{
					"id":   awardID,
					"name": awardName,
				},
			}

			if categoryID.Valid && categoryName.Valid {
				award["category"] = map[string]interface{}{
					"id":   int(categoryID.Int32),
					"name": categoryName.String,
				}
			} else {
				award["category"] = nil
			}

			// Add work object if it exists
			if workAwardID.Valid && workTitle.Valid {
				award["work"] = map[string]interface{}{
					"id":    int(workAwardID.Int32),
					"title": workTitle.String,
				}
			} else {
				award["work"] = nil
			}

			// Add short story object if it exists
			if shortID.Valid && shortTitle.Valid {
				award["short"] = map[string]interface{}{
					"id":    int(shortID.Int32),
					"title": shortTitle.String,
				}
			} else {
				award["short"] = nil
			}

			work.Awards = append(work.Awards, award)
		}
	}

	// Query work stories
	work.Stories = []map[string]interface{}{} // Initialize as empty slice
	storiesQuery := `
		SELECT p.id as part_id, p.order_num, p.title as part_title,
		       s.id as story_id, s.title as story_title, s.orig_title, s.pubyear,
		       l.name as language_name, st.id as type_id, st.name as type_name
		FROM suomisf.part p
		JOIN suomisf.shortstory s ON p.shortstory_id = s.id
		LEFT JOIN suomisf.language l ON s.language = l.id
		LEFT JOIN suomisf.storytype st ON s.story_type = st.id
		WHERE p.work_id = $1 AND p.shortstory_id IS NOT NULL`

	storiesRows, err := h.db.Query(storiesQuery, workID)
	if err == nil {
		defer storiesRows.Close()
		for storiesRows.Next() {
			var partID, storyID int
			var orderNum sql.NullInt32
			var partTitle, storyTitle sql.NullString
			var origTitle sql.NullString
			var pubYear sql.NullInt32
			var languageName sql.NullString
			var typeID sql.NullInt32
			var typeName sql.NullString

			err := storiesRows.Scan(&partID, &orderNum, &partTitle, &storyID, &storyTitle, &origTitle, &pubYear, &languageName, &typeID, &typeName)
			if err != nil {
				continue // Skip this story if there's an error
			}

			story := map[string]interface{}{
				"part_id":  partID,
				"story_id": storyID,
			}

			if orderNum.Valid {
				story["order_num"] = int(orderNum.Int32)
			} else {
				story["order_num"] = nil
			}

			if partTitle.Valid {
				story["part_title"] = partTitle.String
			} else {
				story["part_title"] = nil
			}

			if storyTitle.Valid {
				story["story_title"] = storyTitle.String
				story["title"] = storyTitle.String // Add title field as duplicate of story_title
			} else {
				story["story_title"] = nil
				story["title"] = nil
			}

			if origTitle.Valid {
				story["orig_title"] = origTitle.String
			} else {
				story["orig_title"] = nil
			}

			if pubYear.Valid {
				story["pubyear"] = int(pubYear.Int32)
			} else {
				story["pubyear"] = nil
			}

			if languageName.Valid {
				story["language"] = languageName.String
			} else {
				story["language"] = nil
			}

			if typeID.Valid && typeName.Valid {
				story["type"] = map[string]interface{}{
					"id":   int(typeID.Int32),
					"name": typeName.String,
				}
			} else {
				story["type"] = nil
			}

			// Query contributors for this story part
			contributorsQuery := `
				SELECT c.person_id, p.name as person_name, p.alt_name as person_alt_name, c.role_id, cr.name as role_name,
				       c.real_person_id, rp.name as real_person_name, rp.alt_name as real_person_alt_name, c.description
				FROM suomisf.contributor c
				JOIN suomisf.person p ON c.person_id = p.id
				LEFT JOIN suomisf.contributorrole cr ON c.role_id = cr.id
				LEFT JOIN suomisf.person rp ON c.real_person_id = rp.id
				WHERE c.part_id = $1
				ORDER BY p.name`

			contributorsRows, err := h.db.Query(contributorsQuery, partID)
			contributors := []map[string]interface{}{}
			if err == nil {
				defer contributorsRows.Close()
				for contributorsRows.Next() {
					var personID int
					var personName string
					var personAltName sql.NullString
					var roleID sql.NullInt32
					var roleName sql.NullString
					var realPersonID sql.NullInt32
					var realPersonName sql.NullString
					var realPersonAltName sql.NullString
					var description sql.NullString

					err := contributorsRows.Scan(&personID, &personName, &personAltName, &roleID, &roleName, &realPersonID, &realPersonName, &realPersonAltName, &description)
					if err != nil {
						continue // Skip this contributor if there's an error
					}

					contributor := map[string]interface{}{
						"person": map[string]interface{}{
							"id":   personID,
							"name": personName,
						},
					}

					// Add alt_name to person if it exists
					if personAltName.Valid {
						contributor["person"].(map[string]interface{})["alt_name"] = personAltName.String
					} else {
						contributor["person"].(map[string]interface{})["alt_name"] = nil
					}

					if roleID.Valid && roleName.Valid {
						contributor["role"] = map[string]interface{}{
							"id":   int(roleID.Int32),
							"name": roleName.String,
						}
					} else {
						contributor["role"] = nil
					}

					if realPersonID.Valid && realPersonName.Valid {
						realPersonObj := map[string]interface{}{
							"id":   int(realPersonID.Int32),
							"name": realPersonName.String,
						}
						// Add alt_name to real_person if it exists
						if realPersonAltName.Valid {
							realPersonObj["alt_name"] = realPersonAltName.String
						} else {
							realPersonObj["alt_name"] = nil
						}
						contributor["real_person"] = realPersonObj
					} else {
						contributor["real_person"] = nil
					}

					if description.Valid {
						contributor["description"] = description.String
					} else {
						contributor["description"] = nil
					}

					contributors = append(contributors, contributor)
				}
			}
			story["contributors"] = contributors

			// Query genres for this story
			genresQuery := `
				SELECT g.id, g.name, g.abbr
				FROM suomisf.genre g
				JOIN suomisf.storygenre sg ON g.id = sg.genre_id
				WHERE sg.shortstory_id = $1
				ORDER BY g.name`

			genresRows, err := h.db.Query(genresQuery, storyID)
			genres := []map[string]interface{}{}
			if err == nil {
				defer genresRows.Close()
				for genresRows.Next() {
					var genreID int
					var genreName, genreAbbr string

					err := genresRows.Scan(&genreID, &genreName, &genreAbbr)
					if err != nil {
						continue // Skip this genre if there's an error
					}

					genre := map[string]interface{}{
						"id":   genreID,
						"name": genreName,
						"abbr": genreAbbr,
					}

					genres = append(genres, genre)
				}
			}
			story["genres"] = genres

			work.Stories = append(work.Stories, story)
		}
	}

	c.JSON(http.StatusOK, work)
}

func (h *WorkHandler) GetWorkAwards(c *gin.Context) {
	workID, err := strconv.Atoi(c.Param("workId"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid work ID"})
		return
	}

	query := `SELECT id, work_id, name, year, category, winner FROM awards WHERE work_id = $1`
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
