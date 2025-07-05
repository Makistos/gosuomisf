package handlers

import (
	"net/http"
	"strconv"

	"github.com/gin-gonic/gin"
	"github.com/makistos/gosuomisf/internal/database"
	"github.com/makistos/gosuomisf/internal/models"
)

type PersonHandler struct {
	db *database.DB
}

func NewPersonHandler(db *database.DB) *PersonHandler {
	return &PersonHandler{db: db}
}

func (h *PersonHandler) GetPeople(c *gin.Context) {
	var query models.PaginationQuery
	if err := c.ShouldBindQuery(&query); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	offset := (query.Page - 1) * query.PageSize

	baseQuery := `SELECT id, name, alt_name, first_name, last_name, dob, dod, bio, nationality, created_at, updated_at FROM people`
	countQuery := `SELECT COUNT(*) FROM people`

	var args []interface{}
	var whereClause string

	if query.Search != "" {
		whereClause = " WHERE name LIKE ? OR first_name LIKE ? OR last_name LIKE ?"
		searchTerm := "%" + query.Search + "%"
		args = append(args, searchTerm, searchTerm, searchTerm)
		baseQuery += whereClause
		countQuery += whereClause
	}

	orderClause := " ORDER BY "
	switch query.Sort {
	case "name":
		orderClause += "name"
	case "last_name":
		orderClause += "last_name"
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
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to query people"})
		return
	}
	defer rows.Close()

	var people []models.Person
	for rows.Next() {
		var person models.Person
		err := rows.Scan(
			&person.ID, &person.Name, &person.AltName, &person.FirstName,
			&person.LastName, &person.DOB, &person.DOD, &person.Bio,
			&person.Nationality, &person.CreatedAt, &person.UpdatedAt,
		)
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to scan person"})
			return
		}
		people = append(people, person)
	}

	totalPages := (total + query.PageSize - 1) / query.PageSize

	response := models.PaginatedResponse{
		Data:       people,
		Page:       query.Page,
		PageSize:   query.PageSize,
		Total:      total,
		TotalPages: totalPages,
	}

	c.JSON(http.StatusOK, response)
}

func (h *PersonHandler) GetPerson(c *gin.Context) {
	personID, err := strconv.Atoi(c.Param("personId"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid person ID"})
		return
	}

	var person models.Person
	query := `SELECT id, name, alt_name, first_name, last_name, dob, dod, bio, nationality, created_at, updated_at FROM people WHERE id = ?`
	err = h.db.QueryRow(query, personID).Scan(
		&person.ID, &person.Name, &person.AltName, &person.FirstName,
		&person.LastName, &person.DOB, &person.DOD, &person.Bio,
		&person.Nationality, &person.CreatedAt, &person.UpdatedAt,
	)
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Person not found"})
		return
	}

	c.JSON(http.StatusOK, person)
}
