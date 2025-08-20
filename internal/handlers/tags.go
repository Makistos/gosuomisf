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

	// Return all tags as a simple array
	c.JSON(http.StatusOK, tags)
}

func (h *TagHandler) GetTag(c *gin.Context) {
	tagID := c.Param("tagId")

	// Validate tag ID
	if tagID == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Tag ID is required"})
		return
	}

	// Check database connection
	if h.db == nil || h.db.DB == nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Database not available"})
		return
	}

	var tag models.Tag
	var typeID sql.NullInt64
	var typeName sql.NullString
	var descNull sql.NullString

	// Get basic tag information
	query := `
		SELECT
			t.id,
			t.name,
			t.type_id,
			tt.name as type_name,
			t.description
		FROM suomisf.tag t
		LEFT JOIN suomisf.tagtype tt ON t.type_id = tt.id
		WHERE t.id = $1`

	err := h.db.QueryRow(query, tagID).Scan(
		&tag.ID,
		&tag.Name,
		&typeID,
		&typeName,
		&descNull,
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

	// Query related works with more comprehensive fields
	worksQuery := `
		SELECT DISTINCT w.id, w.title, w.subtitle, w.orig_title, w.pubyear,
		       w.language, l.name as language_name, w.type, wt.name as type_name,
		       w.description, w.author_str, w.misc, w.bookseriesnum, w.bookseriesorder, w.imported_string
		FROM suomisf.work w
		INNER JOIN suomisf.worktag wt_rel ON w.id = wt_rel.work_id
		LEFT JOIN suomisf.language l ON w.language = l.id
		LEFT JOIN suomisf.worktype wt ON w.type = wt.id
		WHERE wt_rel.tag_id = $1
		ORDER BY w.title`

	worksRows, err := h.db.Query(worksQuery, tagID)
	var works []map[string]interface{}
	if err == nil {
		defer worksRows.Close()
		for worksRows.Next() {
			var work map[string]interface{} = make(map[string]interface{})
			var workID int
			var title, subtitle, origTitle, language, languageName, workType, typeName, description, authorStr, misc, bookseriesnum, importedString sql.NullString
			var pubyear, bookseriesorder sql.NullInt64

			err := worksRows.Scan(&workID, &title, &subtitle, &origTitle, &pubyear,
				&language, &languageName, &workType, &typeName, &description, &authorStr,
				&misc, &bookseriesnum, &bookseriesorder, &importedString)
			if err == nil {
				work["id"] = workID // Use integer to match expected format
				if title.Valid {
					work["title"] = title.String
				}
				if subtitle.Valid {
					work["subtitle"] = subtitle.String
				} else {
					work["subtitle"] = ""
				}
				if origTitle.Valid {
					work["orig_title"] = origTitle.String
				}
				if pubyear.Valid {
					work["pubyear"] = int(pubyear.Int64)
				}
				if authorStr.Valid {
					work["author_str"] = authorStr.String
				}
				if description.Valid {
					work["description"] = description.String
				}
				if misc.Valid {
					work["misc"] = misc.String
				} else {
					work["misc"] = ""
				}
				if bookseriesnum.Valid {
					work["bookseriesnum"] = bookseriesnum.String
				} else {
					work["bookseriesnum"] = ""
				}
				if bookseriesorder.Valid {
					work["bookseriesorder"] = int(bookseriesorder.Int64)
				} else {
					work["bookseriesorder"] = nil
				}

				// Add language_name as nested object to match expected format
				if language.Valid && languageName.Valid {
					if langID, err := strconv.Atoi(language.String); err == nil {
						work["language_name"] = map[string]interface{}{
							"id":   langID,
							"name": languageName.String,
						}
					} else {
						work["language_name"] = map[string]interface{}{
							"id":   language.String,
							"name": languageName.String,
						}
					}
				}

				// Add type as number to match expected format
				if workType.Valid {
					if typeID, err := strconv.Atoi(workType.String); err == nil {
						work["type"] = typeID
					} else {
						work["type"] = workType.String
					}
				}

				// Get editions for this work using extracted function
				work["editions"] = h.getEditionsForWork(workID)

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
				contributions := make([]map[string]interface{}, 0) // Initialize as empty slice
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

							contributions = append(contributions, contribution)
						}
					}
				}
				work["contributions"] = contributions

				// Query work genres
				genresQuery := `
					SELECT DISTINCT g.id, g.name, g.abbr
					FROM suomisf.genre g
					INNER JOIN suomisf.workgenre wg ON g.id = wg.genre_id
					WHERE wg.work_id = $1
					ORDER BY g.name`

				genresRows, err := h.db.Query(genresQuery, workID)
				genres := make([]map[string]interface{}, 0) // Initialize as empty slice
				if err == nil {
					defer genresRows.Close()
					for genresRows.Next() {
						var genre map[string]interface{} = make(map[string]interface{})
						var genreID int
						var genreName, genreAbbr sql.NullString

						err := genresRows.Scan(&genreID, &genreName, &genreAbbr)
						if err == nil {
							genre["id"] = genreID
							if genreName.Valid {
								genre["name"] = genreName.String
							}
							if genreAbbr.Valid {
								genre["abbr"] = genreAbbr.String
							}
							genres = append(genres, genre)
						}
					}
				}
				work["genres"] = genres

				// Query bookseries for this work
				bookseriesQuery := `
					SELECT bs.id, bs.name, bs.orig_name, bs.image_src, bs.image_attr, bs.important
					FROM suomisf.bookseries bs
					INNER JOIN suomisf.work w ON bs.id = w.bookseries_id
					WHERE w.id = $1`

				var bookseries map[string]interface{}
				var bsID int
				var bsName, bsOrigName, bsImageSrc, bsImageAttr sql.NullString
				var bsImportant sql.NullBool

				err = h.db.QueryRow(bookseriesQuery, workID).Scan(&bsID, &bsName, &bsOrigName, &bsImageSrc, &bsImageAttr, &bsImportant)
				if err == nil {
					bookseries = make(map[string]interface{})
					bookseries["id"] = bsID
					if bsName.Valid {
						bookseries["name"] = bsName.String
					}
					if bsOrigName.Valid {
						bookseries["orig_name"] = bsOrigName.String
					}
					if bsImageSrc.Valid {
						bookseries["image_src"] = bsImageSrc.String
					} else {
						bookseries["image_src"] = nil
					}
					if bsImageAttr.Valid {
						bookseries["image_attr"] = bsImageAttr.String
					} else {
						bookseries["image_attr"] = nil
					}
					if bsImportant.Valid {
						bookseries["important"] = bsImportant.Bool
					} else {
						bookseries["important"] = false
					}
					work["bookseries"] = bookseries
				} else {
					work["bookseries"] = nil
				}

				// Initialize empty arrays for complex nested data
				work["descr_attr"] = nil
				if importedString.Valid {
					work["imported_string"] = importedString.String
				} else {
					work["imported_string"] = ""
				}

				works = append(works, work)
			}
		}
	}
	// Initialize empty array if no works found
	if works == nil {
		works = []map[string]interface{}{}
	}

	// Query related articles
	articlesQuery := `
		SELECT DISTINCT a.id, a.title, a.person, a.author_rel, a.excerpt
		FROM suomisf.article a
		INNER JOIN suomisf.articletag at_rel ON a.id = at_rel.article_id
		WHERE at_rel.tag_id = $1
		ORDER BY a.title`

	articleRows, err := h.db.Query(articlesQuery, tagID)
	var articles []map[string]interface{}
	if err == nil {
		defer articleRows.Close()
		for articleRows.Next() {
			var article map[string]interface{} = make(map[string]interface{})
			var articleID int
			var title, person, authorRel, excerpt sql.NullString

			err := articleRows.Scan(&articleID, &title, &person, &authorRel, &excerpt)
			if err == nil {
				article["id"] = articleID
				if title.Valid {
					article["title"] = title.String
				}
				if person.Valid {
					article["person"] = person.String
				}
				if authorRel.Valid {
					article["author_rel"] = authorRel.String
				} else {
					article["author_rel"] = ""
				}
				if excerpt.Valid {
					article["excerpt"] = excerpt.String
				}
				articles = append(articles, article)
			}
		}
	}
	// Initialize empty array if no articles found
	if articles == nil {
		articles = []map[string]interface{}{}
	}

	// Query related short stories
	storiesQuery := `
		SELECT DISTINCT s.id, s.title, s.orig_title, s.language, l.name as language_name,
		       s.pubyear, s.story_type, st.name as story_type_name
		FROM suomisf.shortstory s
		INNER JOIN suomisf.storytag st_rel ON s.id = st_rel.shortstory_id
		LEFT JOIN suomisf.language l ON s.language = l.id
		LEFT JOIN suomisf.storytype st ON s.story_type = st.id
		WHERE st_rel.tag_id = $1
		ORDER BY s.title`

	storyRows, err := h.db.Query(storiesQuery, tagID)
	var stories []map[string]interface{}
	if err == nil {
		defer storyRows.Close()
		for storyRows.Next() {
			var story map[string]interface{} = make(map[string]interface{})
			var storyID int
			var title, origTitle, language, languageName, storyType, storyTypeName sql.NullString
			var pubyear sql.NullInt64

			err := storyRows.Scan(&storyID, &title, &origTitle, &language, &languageName,
				&pubyear, &storyType, &storyTypeName)
			if err == nil {
				story["id"] = storyID
				if title.Valid {
					story["title"] = title.String
				}
				if origTitle.Valid {
					story["orig_title"] = origTitle.String
				} else {
					story["orig_title"] = nil
				}
				if language.Valid {
					story["lang"] = language.String
				} else {
					story["lang"] = nil
				}
				if pubyear.Valid {
					story["pubyear"] = int(pubyear.Int64)
				} else {
					story["pubyear"] = nil
				}

				// Add type as nested object to match expected format
				if storyType.Valid && storyTypeName.Valid {
					story["type"] = map[string]interface{}{
						"id":   storyType.String, // Convert to int if it's a valid number
						"name": storyTypeName.String,
					}
					// Try to convert ID to integer to match reference format
					if typeID, err := strconv.Atoi(storyType.String); err == nil {
						story["type"] = map[string]interface{}{
							"id":   typeID,
							"name": storyTypeName.String,
						}
					}
				}

				// Query authors for this story using correct relationship: shortstory -> part -> contributor -> person - only role_ids 1, 2, 6
				authorsQuery := `
					SELECT DISTINCT p.id, p.name, p.alt_name, p.fullname, p.dob, p.dod,
					       p.image_src, p.image_attr, p.bio, p.bio_src, p.imported_string,
					       p.first_name, p.last_name, p.other_names, p.nationality_id,
					       c.id as country_id, c.name as country_name
					FROM suomisf.person p
					INNER JOIN suomisf.contributor con ON p.id = con.person_id
					INNER JOIN suomisf.part pt ON con.part_id = pt.id
					INNER JOIN suomisf.contributorrole cr ON con.role_id = cr.id
					LEFT JOIN suomisf.country c ON p.nationality_id = c.id
					WHERE pt.shortstory_id = $1 AND cr.id IN (1, 2, 6)`

				authorRows, err := h.db.Query(authorsQuery, storyID)
				var authors []map[string]interface{}
				if err != nil {
					println("Authors query error for story", storyID, ":", err.Error())
					authors = []map[string]interface{}{} // Initialize empty array
				}

				if err == nil {
					defer authorRows.Close()
					authorCount := 0
					for authorRows.Next() {
						authorCount++
						var author map[string]interface{} = make(map[string]interface{})
						var personID int
						var name, altName, fullname, firstName, lastName, otherNames, imageSrc, imageAttr, bio, bioSrc, importedString sql.NullString
						var dob, dod sql.NullInt64
						var nationalityID sql.NullInt64
						var countryID sql.NullInt64
						var countryName sql.NullString

						err := authorRows.Scan(&personID, &name, &altName, &fullname, &dob, &dod,
							&imageSrc, &imageAttr, &bio, &bioSrc, &importedString,
							&firstName, &lastName, &otherNames, &nationalityID,
							&countryID, &countryName)

						if err == nil {
							author["id"] = personID
							if name.Valid {
								author["name"] = name.String
							}
							if altName.Valid {
								author["alt_name"] = altName.String
							}
							if fullname.Valid {
								author["fullname"] = fullname.String
							} else {
								author["fullname"] = ""
							}
							if imageSrc.Valid {
								author["image_src"] = imageSrc.String
							} else {
								author["image_src"] = nil
							}
							if dob.Valid {
								author["dob"] = int(dob.Int64)
							} else {
								author["dob"] = nil
							}
							if dod.Valid {
								author["dod"] = int(dod.Int64)
							} else {
								author["dod"] = nil
							}
							if firstName.Valid {
								author["first_name"] = firstName.String
							}
							if lastName.Valid {
								author["last_name"] = lastName.String
							}
							if otherNames.Valid {
								author["other_names"] = otherNames.String
							} else {
								author["other_names"] = nil
							}
							if imageAttr.Valid {
								author["image_attr"] = imageAttr.String
							} else {
								author["image_attr"] = ""
							}
							if bio.Valid {
								author["bio"] = bio.String
							} else {
								author["bio"] = nil
							}
							if bioSrc.Valid {
								author["bio_src"] = bioSrc.String
							} else {
								author["bio_src"] = ""
							}
							if importedString.Valid {
								author["imported_string"] = importedString.String
							} else {
								author["imported_string"] = nil
							}

							// Add nationality with correct column references
							if countryID.Valid && countryName.Valid {
								author["nationality"] = map[string]interface{}{
									"id":   int(countryID.Int64),
									"name": countryName.String,
								}
							} else {
								author["nationality"] = nil
							}

							// Query roles for this person
							rolesQuery := `
								SELECT DISTINCT cr.name
								FROM suomisf.contributorrole cr
								INNER JOIN suomisf.contributor c ON cr.id = c.role_id
								WHERE c.person_id = $1`

							rolesRows, err := h.db.Query(rolesQuery, personID)
							var roles []interface{}
							if err == nil {
								defer rolesRows.Close()
								for rolesRows.Next() {
									var roleName sql.NullString
									if err := rolesRows.Scan(&roleName); err == nil && roleName.Valid {
										roles = append(roles, roleName.String)
									}
								}
							}
							author["roles"] = roles

							// Query work count for this person
							workCountQuery := `
								SELECT COUNT(DISTINCT pt.work_id)
								FROM suomisf.part pt
								INNER JOIN suomisf.contributor c ON pt.id = c.part_id
								WHERE c.person_id = $1 AND pt.work_id IS NOT NULL`

							var workCount sql.NullInt64
							if err := h.db.QueryRow(workCountQuery, personID).Scan(&workCount); err == nil && workCount.Valid {
								author["workcount"] = int(workCount.Int64)
							} else {
								author["workcount"] = 0
							}

							// Query story count for this person
							storyCountQuery := `
								SELECT COUNT(DISTINCT pt.shortstory_id)
								FROM suomisf.part pt
								INNER JOIN suomisf.contributor c ON pt.id = c.part_id
								WHERE c.person_id = $1 AND pt.shortstory_id IS NOT NULL`

							var storyCount sql.NullInt64
							if err := h.db.QueryRow(storyCountQuery, personID).Scan(&storyCount); err == nil && storyCount.Valid {
								author["storycount"] = int(storyCount.Int64)
							} else {
								author["storycount"] = 0
							}

							authors = append(authors, author)
						} else {
							println("Author scan error:", err.Error())
						}
					}
					println("Found", authorCount, "authors for story", storyID)
				}
				story["authors"] = authors

				// Query story contributors - only role_ids 1, 2, 6
				storyContributionsQuery := `
					SELECT DISTINCT p.id, p.name, p.alt_name, cr.id as role_id, cr.name as role_name,
					       c.description, c.real_person_id, rp.name as real_person_name
					FROM suomisf.part pt
					INNER JOIN suomisf.contributor c ON pt.id = c.part_id
					INNER JOIN suomisf.person p ON c.person_id = p.id
					INNER JOIN suomisf.contributorrole cr ON c.role_id = cr.id
					LEFT JOIN suomisf.person rp ON c.real_person_id = rp.id
					WHERE pt.shortstory_id = $1 AND cr.id IN (1, 2, 6)
					ORDER BY p.name`

				storyContribRows, err := h.db.Query(storyContributionsQuery, storyID)
				var storyContributions []map[string]interface{}
				if err == nil {
					defer storyContribRows.Close()
					for storyContribRows.Next() {
						var contrib map[string]interface{} = make(map[string]interface{})
						var personID, roleID int
						var personName, personAltName, roleName, description, realPersonName sql.NullString
						var realPersonID sql.NullInt64

						err := storyContribRows.Scan(&personID, &personName, &personAltName, &roleID, &roleName,
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

							storyContributions = append(storyContributions, contrib)
						}
					}
				}

				// Query story genres
				storyGenresQuery := `
					SELECT DISTINCT g.id, g.name, g.abbr
					FROM suomisf.genre g
					INNER JOIN suomisf.storygenre sg ON g.id = sg.genre_id
					WHERE sg.shortstory_id = $1
					ORDER BY g.name`

				storyGenresRows, err := h.db.Query(storyGenresQuery, storyID)
				var storyGenres []map[string]interface{}
				if err == nil {
					defer storyGenresRows.Close()
					for storyGenresRows.Next() {
						var genre map[string]interface{} = make(map[string]interface{})
						var genreID int
						var genreName, genreAbbr sql.NullString

						err := storyGenresRows.Scan(&genreID, &genreName, &genreAbbr)
						if err == nil {
							genre["id"] = genreID
							if genreName.Valid {
								genre["name"] = genreName.String
							}
							if genreAbbr.Valid {
								genre["abbr"] = genreAbbr.String
							}
							storyGenres = append(storyGenres, genre)
						}
					}
				}
				// Ensure genres is always an array, even if empty
				if storyGenres == nil {
					storyGenres = []map[string]interface{}{}
				}
				story["genres"] = storyGenres

				// Initialize empty arrays for complex nested data that we'll implement later
				story["issues"] = []interface{}{}
				story["editions"] = []interface{}{}
				story["contributors"] = storyContributions

				stories = append(stories, story)
			}
		}
	}
	// Initialize empty array if no stories found
	if stories == nil {
		stories = []map[string]interface{}{}
	}

	// Build comprehensive response matching legacy Python API exactly
	response := map[string]interface{}{
		"works":       works,           // Always include, even if empty array
		"articles":    articles,        // Always include, even if empty array
		"stories":     stories,         // Always include, even if empty array
		"magazines":   []interface{}{}, // Always empty array for now
		"people":      []interface{}{}, // Always empty array for now
		"type":        tag.Type,
		"id":          tag.ID,
		"name":        tag.Name,
		"description": tag.Description,
	}

	c.JSON(http.StatusOK, response)
}

// getEditionsForWork extracts and returns editions data for a given work ID
func (h *TagHandler) getEditionsForWork(workID int) []map[string]interface{} {
	// Query editions for this work through the part table
	editionsQuery := `
		SELECT e.id, e.title, e.subtitle, e.pubyear, e.editionnum, e.version, e.isbn,
		       e.printedin, e.pubseriesnum, e.coll_info, e.pages, e.size, e.dustcover,
		       e.coverimage, e.misc, e.imported_string, e.verified,
		       p.id as publisher_id, p.name as publisher_name
		FROM suomisf.edition e
		INNER JOIN suomisf.part pt ON e.id = pt.edition_id
		LEFT JOIN suomisf.publisher p ON e.publisher_id = p.id
		WHERE pt.work_id = $1
		ORDER BY e.pubyear, e.editionnum`

	editionsRows, err := h.db.Query(editionsQuery, workID)
	editions := make([]map[string]interface{}, 0) // Initialize as empty slice
	if err != nil {
		// Log the error for debugging
		println("Editions query error:", err.Error())
		return []map[string]interface{}{} // Return empty array
	}
	defer editionsRows.Close()

	editionCount := 0
	for editionsRows.Next() {
		editionCount++
		var edition map[string]interface{} = make(map[string]interface{})
		var editionID, pubyear, editionnum, version, pubseriesnum, pages, size, dustcover, coverimage sql.NullInt64
		var publisherID sql.NullInt64
		var eTitle, eSubtitle, isbn, printedin, collInfo, misc, importedString, publisherName sql.NullString
		var verified sql.NullBool

		err := editionsRows.Scan(&editionID, &eTitle, &eSubtitle, &pubyear, &editionnum, &version,
			&isbn, &printedin, &pubseriesnum, &collInfo, &pages, &size, &dustcover, &coverimage,
			&misc, &importedString, &verified, &publisherID, &publisherName)
		if err != nil {
			println("Edition scan error:", err.Error())
			continue
		}
		if editionID.Valid {
			edition["id"] = int(editionID.Int64)
		}
		if eTitle.Valid {
			edition["title"] = eTitle.String
		}
		if eSubtitle.Valid {
			edition["subtitle"] = eSubtitle.String
		} else {
			edition["subtitle"] = ""
		}
		if pubyear.Valid {
			edition["pubyear"] = int(pubyear.Int64)
		}
		// EditionNum should always have a value, default to 1 if not valid or 0
		if editionnum.Valid && editionnum.Int64 > 0 {
			edition["editionnum"] = int(editionnum.Int64)
		} else {
			edition["editionnum"] = 1
		}
		if version.Valid {
			edition["version"] = int(version.Int64)
		} else {
			edition["version"] = nil
		}
		if isbn.Valid {
			edition["isbn"] = isbn.String
		}
		if printedin.Valid {
			edition["printedin"] = printedin.String
		} else {
			edition["printedin"] = nil
		}
		if pubseriesnum.Valid {
			edition["pubseriesnum"] = int(pubseriesnum.Int64)
		} else {
			edition["pubseriesnum"] = nil
		}
		if collInfo.Valid {
			edition["coll_info"] = collInfo.String
		} else {
			edition["coll_info"] = ""
		}
		if pages.Valid {
			edition["pages"] = int(pages.Int64)
		}
		if size.Valid {
			edition["size"] = int(size.Int64)
		}
		if dustcover.Valid {
			edition["dustcover"] = int(dustcover.Int64)
		}
		if coverimage.Valid {
			edition["coverimage"] = int(coverimage.Int64)
		}
		if misc.Valid {
			edition["misc"] = misc.String
		} else {
			edition["misc"] = nil
		}
		if importedString.Valid {
			edition["imported_string"] = importedString.String
		} else {
			edition["imported_string"] = ""
		}
		if verified.Valid {
			edition["verified"] = verified.Bool
		} else {
			edition["verified"] = false
		}

		// Add publisher info as nested object
		if publisherID.Valid && publisherName.Valid {
			edition["publisher"] = map[string]interface{}{
				"id":   int(publisherID.Int64),
				"name": publisherName.String,
			}
		}

		// Query edition contributions through part table - only role_ids 2, 4, 5
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

		editionContribRows, err := h.db.Query(editionContributionsQuery, int(editionID.Int64))
		editionContributions := make([]map[string]interface{}, 0) // Initialize as empty slice
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

					editionContributions = append(editionContributions, contrib)
				}
			}
		}
		edition["contributions"] = editionContributions

		// Query edition images
		imagesQuery := `
			SELECT id, image_src, image_attr
			FROM suomisf.editionimage
			WHERE edition_id = $1
			ORDER BY id`

		imagesRows, err := h.db.Query(imagesQuery, int(editionID.Int64))
		images := make([]map[string]interface{}, 0) // Initialize as empty slice
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
					images = append(images, image)
				}
			}
		}
		edition["images"] = images

		// Query edition owners (condition_id < 6)
		ownersQuery := `
			SELECT u.id, u.name
			FROM suomisf."user" u
			INNER JOIN suomisf.userbook ub ON u.id = ub.user_id
			WHERE ub.edition_id = $1 AND ub.condition_id < 6
			ORDER BY u.name`

		ownersRows, err := h.db.Query(ownersQuery, int(editionID.Int64))
		edition["owners"] = make([]map[string]interface{}, 0) // Initialize as empty slice
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
					edition["owners"] = append(edition["owners"].([]map[string]interface{}), owner)
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

		wishlistedRows, err := h.db.Query(wishlistedQuery, int(editionID.Int64))
		edition["wishlisted"] = make([]map[string]interface{}, 0) // Initialize as empty slice
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
					edition["wishlisted"] = append(edition["wishlisted"].([]map[string]interface{}), wishlisted)
				}
			}
		}

		editions = append(editions, edition)
	}
	println("Found", editionCount, "editions for work", workID)

	return editions
}
