package handlers

import (
	"encoding/json"
	"fmt"
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/gin-gonic/gin"
	"github.com/makistos/gosuomisf/internal/models"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

// getValidWorkID returns a valid work ID from the database that can actually be retrieved by GetWork, or skips the test if none found
func getValidWorkID(t *testing.T) string {
	if testDB == nil {
		t.Skip("Database not available")
	}

	// Use the exact same query as the GetWork handler to ensure we find a work that can actually be retrieved
	var workID int
	var title string
	query := `SELECT w.id, w.title
		FROM work w
		LEFT JOIN worktype wt ON w.type = wt.id
		LEFT JOIN language l ON w.language = l.id
		LEFT JOIN bookseries bs ON w.bookseries_id = bs.id
		LIMIT 1`

	row := testDB.DB.QueryRow(query)
	err := row.Scan(&workID, &title)
	if err != nil {
		t.Skip("No works found in database")
	}
	return fmt.Sprintf("%d", workID)
}

func TestWorkHandler_NilDatabase(t *testing.T) {
	gin.SetMode(gin.TestMode)
	router := gin.New()
	handler := NewWorkHandler(nil) // Test with nil database
	router.GET("/api/works/:workId", handler.GetWork)

	req, err := http.NewRequest("GET", "/api/works/999", nil)
	require.NoError(t, err)

	w := httptest.NewRecorder()
	router.ServeHTTP(w, req)

	// Should return error with nil database
	assert.Equal(t, http.StatusInternalServerError, w.Code)
}

func TestGetWork(t *testing.T) {
	if testDB == nil {
		t.Skip("Database not available")
	}

	gin.SetMode(gin.TestMode)
	router := gin.New()
	handler := NewWorkHandler(testDB)
	router.GET("/api/works/:workId", handler.GetWork)

	validWorkID := getValidWorkID(t)

	tests := []struct {
		name           string
		workId         string
		expectedStatus int
		shouldHaveBody bool
	}{
		{
			name:           "Valid work ID",
			workId:         validWorkID,
			expectedStatus: http.StatusOK,
			shouldHaveBody: true,
		},
		{
			name:           "Invalid work ID",
			workId:         "999999",
			expectedStatus: http.StatusNotFound,
			shouldHaveBody: false,
		},
		{
			name:           "Non-numeric work ID",
			workId:         "invalid",
			expectedStatus: http.StatusBadRequest,
			shouldHaveBody: false,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			req, err := http.NewRequest("GET", fmt.Sprintf("/api/works/%s", tt.workId), nil)
			require.NoError(t, err)

			w := httptest.NewRecorder()
			router.ServeHTTP(w, req)

			assert.Equal(t, tt.expectedStatus, w.Code)

			if tt.shouldHaveBody {
				var work models.Work
				err := json.Unmarshal(w.Body.Bytes(), &work)
				require.NoError(t, err)

				// Test basic work structure
				assert.NotZero(t, work.ID)
				assert.NotEmpty(t, work.Title)

				// Test that collections are initialized (not nil)
				assert.NotNil(t, work.Editions)
				assert.NotNil(t, work.Contributions)
				assert.NotNil(t, work.Genres)
				assert.NotNil(t, work.Tags)
				assert.NotNil(t, work.Links)
				assert.NotNil(t, work.Awards)
				assert.NotNil(t, work.Stories)
			}
		})
	}
}

func TestGetWorkAwards(t *testing.T) {
	if testDB == nil {
		t.Skip("Database not available")
	}

	gin.SetMode(gin.TestMode)
	router := gin.New()
	handler := NewWorkHandler(testDB)
	router.GET("/api/works/:workId", handler.GetWork)

	// Test with a work that has awards (based on our database query)
	req, err := http.NewRequest("GET", "/api/works/23", nil)
	require.NoError(t, err)

	w := httptest.NewRecorder()
	router.ServeHTTP(w, req)

	if w.Code == http.StatusOK {
		var work models.Work
		err := json.Unmarshal(w.Body.Bytes(), &work)
		require.NoError(t, err)

		// Test awards structure
		assert.NotNil(t, work.Awards)

		if len(work.Awards) > 0 {
			award := work.Awards[0]

			// Test that award has all required fields
			assert.Contains(t, award, "id")
			assert.Contains(t, award, "year")
			assert.Contains(t, award, "award")
			assert.Contains(t, award, "category")
			assert.Contains(t, award, "work")
			assert.Contains(t, award, "short")

			// Test award object structure
			awardObj, ok := award["award"].(map[string]interface{})
			assert.True(t, ok)
			assert.Contains(t, awardObj, "id")
			assert.Contains(t, awardObj, "name")

			// Test category object structure (if not nil)
			if award["category"] != nil {
				categoryObj, ok := award["category"].(map[string]interface{})
				assert.True(t, ok)
				assert.Contains(t, categoryObj, "id")
				assert.Contains(t, categoryObj, "name")
			}

			// Test work object structure (if not nil)
			if award["work"] != nil {
				workObj, ok := award["work"].(map[string]interface{})
				assert.True(t, ok)
				assert.Contains(t, workObj, "id")
				assert.Contains(t, workObj, "title")
			}

			// Test short object structure (if not nil)
			if award["short"] != nil {
				shortObj, ok := award["short"].(map[string]interface{})
				assert.True(t, ok)
				assert.Contains(t, shortObj, "id")
				assert.Contains(t, shortObj, "title")
			}
		}
	}
}

func TestGetWorkEditions(t *testing.T) {
	if testDB == nil {
		t.Skip("Database not available")
	}

	gin.SetMode(gin.TestMode)
	router := gin.New()
	handler := NewWorkHandler(testDB)
	router.GET("/api/works/:workId", handler.GetWork)

	validWorkID := getValidWorkID(t)
	req, err := http.NewRequest("GET", fmt.Sprintf("/api/works/%s", validWorkID), nil)
	require.NoError(t, err)

	w := httptest.NewRecorder()
	router.ServeHTTP(w, req)

	if w.Code == http.StatusOK {
		var work models.Work
		err := json.Unmarshal(w.Body.Bytes(), &work)
		require.NoError(t, err)

		// Test editions structure
		assert.NotNil(t, work.Editions)

		if len(work.Editions) > 0 {
			edition := work.Editions[0]

			// Test basic edition fields
			assert.NotZero(t, edition.ID)
			assert.NotNil(t, edition.Title)

			// Test that edition collections are initialized
			assert.NotNil(t, edition.Images)
			assert.NotNil(t, edition.Owners)
			assert.NotNil(t, edition.Wishlisted)
			assert.NotNil(t, edition.Contributions)

			// Test editionnum is properly set (should not be nil and should have a value)
			assert.NotNil(t, edition.EditionNum)
			if edition.EditionNum != nil {
				assert.Greater(t, *edition.EditionNum, 0)
			}

			// Test version handling (can be nil)
			// Version is optional, so we just check it's handled properly

			// Test that null fields are handled correctly
			// Some fields can be nil, which is acceptable
		}
	}
}

func TestGetWorkGenres(t *testing.T) {
	if testDB == nil {
		t.Skip("Database not available")
	}

	gin.SetMode(gin.TestMode)
	router := gin.New()
	handler := NewWorkHandler(testDB)
	router.GET("/api/works/:workId", handler.GetWork)

	validWorkID := getValidWorkID(t)
	req, err := http.NewRequest("GET", fmt.Sprintf("/api/works/%s", validWorkID), nil)
	require.NoError(t, err)

	w := httptest.NewRecorder()
	router.ServeHTTP(w, req)

	if w.Code == http.StatusOK {
		var work models.Work
		err := json.Unmarshal(w.Body.Bytes(), &work)
		require.NoError(t, err)

		// Test genres structure
		assert.NotNil(t, work.Genres)

		// Genres can be empty, but should be an initialized slice
		for _, genre := range work.Genres {
			assert.Greater(t, genre.ID, 0)
			assert.NotEmpty(t, genre.Name)
			// Abbreviation can be empty, so we don't require it
		}
	}
}

func TestGetWorkTags(t *testing.T) {
	if testDB == nil {
		t.Skip("Database not available")
	}

	gin.SetMode(gin.TestMode)
	router := gin.New()
	handler := NewWorkHandler(testDB)
	router.GET("/api/works/:workId", handler.GetWork)

	validWorkID := getValidWorkID(t)
	req, err := http.NewRequest("GET", fmt.Sprintf("/api/works/%s", validWorkID), nil)
	require.NoError(t, err)

	w := httptest.NewRecorder()
	router.ServeHTTP(w, req)

	if w.Code == http.StatusOK {
		var work models.Work
		err := json.Unmarshal(w.Body.Bytes(), &work)
		require.NoError(t, err)

		// Test tags structure
		assert.NotNil(t, work.Tags)

		// Tags can be empty, but should be an initialized slice
		for _, tag := range work.Tags {
			assert.NotZero(t, tag.ID)
			assert.NotEmpty(t, tag.Name)
			// Description and Type can be nil
		}
	}
}

func TestGetWorkLinks(t *testing.T) {
	if testDB == nil {
		t.Skip("Database not available")
	}

	gin.SetMode(gin.TestMode)
	router := gin.New()
	handler := NewWorkHandler(testDB)
	router.GET("/api/works/:workId", handler.GetWork)

	validWorkID := getValidWorkID(t)
	req, err := http.NewRequest("GET", fmt.Sprintf("/api/works/%s", validWorkID), nil)
	require.NoError(t, err)

	w := httptest.NewRecorder()
	router.ServeHTTP(w, req)

	if w.Code == http.StatusOK {
		var work models.Work
		err := json.Unmarshal(w.Body.Bytes(), &work)
		require.NoError(t, err)

		// Test links structure
		assert.NotNil(t, work.Links)

		// Links can be empty, but should be an initialized slice
		for _, link := range work.Links {
			assert.Contains(t, link, "id")
			assert.Contains(t, link, "link")
			// description can be nil
		}
	}
}

func TestGetWorkStories(t *testing.T) {
	if testDB == nil {
		t.Skip("Database not available")
	}

	gin.SetMode(gin.TestMode)
	router := gin.New()
	handler := NewWorkHandler(testDB)
	router.GET("/api/works/:workId", handler.GetWork)

	// Test with a work that has stories (based on our database queries)
	req, err := http.NewRequest("GET", "/api/works/5881", nil)
	require.NoError(t, err)

	w := httptest.NewRecorder()
	router.ServeHTTP(w, req)

	if w.Code == http.StatusOK {
		var work models.Work
		err := json.Unmarshal(w.Body.Bytes(), &work)
		require.NoError(t, err)

		// Test stories structure
		assert.NotNil(t, work.Stories)

		if len(work.Stories) > 0 {
			story := work.Stories[0]

			// Test story structure
			assert.Contains(t, story, "part_id")
			assert.Contains(t, story, "story_id")
			assert.Contains(t, story, "title")
			assert.Contains(t, story, "contributors")
			assert.Contains(t, story, "genres")
			assert.Contains(t, story, "type")

			// Test contributors structure
			contributors, ok := story["contributors"].([]interface{})
			assert.True(t, ok)
			if len(contributors) > 0 {
				contributor := contributors[0].(map[string]interface{})
				assert.Contains(t, contributor, "person")
				assert.Contains(t, contributor, "role")

				// Test person object
				person, ok := contributor["person"].(map[string]interface{})
				assert.True(t, ok)
				assert.Contains(t, person, "id")
				assert.Contains(t, person, "name")
				assert.Contains(t, person, "alt_name")
			}

			// Test genres structure
			genres, ok := story["genres"].([]interface{})
			assert.True(t, ok)
			for _, genreInterface := range genres {
				genre := genreInterface.(map[string]interface{})
				assert.Contains(t, genre, "id")
				assert.Contains(t, genre, "name")
			}

			// Test type structure (if not nil)
			if story["type"] != nil {
				typeObj, ok := story["type"].(map[string]interface{})
				assert.True(t, ok)
				assert.Contains(t, typeObj, "id")
				assert.Contains(t, typeObj, "name")
			}
		}
	}
}

func TestGetWorkContributions(t *testing.T) {
	if testDB == nil {
		t.Skip("Database not available")
	}

	gin.SetMode(gin.TestMode)
	router := gin.New()
	handler := NewWorkHandler(testDB)
	router.GET("/api/works/:workId", handler.GetWork)

	validWorkID := getValidWorkID(t)
	req, err := http.NewRequest("GET", fmt.Sprintf("/api/works/%s", validWorkID), nil)
	require.NoError(t, err)

	w := httptest.NewRecorder()
	router.ServeHTTP(w, req)

	if w.Code == http.StatusOK {
		var work models.Work
		err := json.Unmarshal(w.Body.Bytes(), &work)
		require.NoError(t, err)

		// Test contributions structure
		assert.NotNil(t, work.Contributions)

		if len(work.Contributions) > 0 {
			contribution := work.Contributions[0]

			// Test contribution structure - person field should exist
			assert.NotEqual(t, 0, contribution.Person.ID)
			assert.NotEmpty(t, contribution.Person.Name)

			// Test role object - may be nil
			if contribution.Role != nil {
				assert.NotEqual(t, 0, contribution.Role.ID)
				assert.NotEmpty(t, contribution.Role.Name)
			}

			// real_person and description can be nil - test if they exist without asserting values
		}
	}
}

func TestGetWorkBookseries(t *testing.T) {
	if testDB == nil {
		t.Skip("Database not available")
	}

	gin.SetMode(gin.TestMode)
	router := gin.New()
	handler := NewWorkHandler(testDB)
	router.GET("/api/works/:workId", handler.GetWork)

	// Test with work 731 which should have bookseries info
	req, err := http.NewRequest("GET", "/api/works/731", nil)
	require.NoError(t, err)

	w := httptest.NewRecorder()
	router.ServeHTTP(w, req)

	if w.Code == http.StatusOK {
		var work models.Work
		err := json.Unmarshal(w.Body.Bytes(), &work)
		require.NoError(t, err)

		// Test bookseries structure (if present)
		if work.Bookseries != nil {
			assert.Contains(t, *work.Bookseries, "id")
			assert.Contains(t, *work.Bookseries, "name")
		}

		// Test bookseries fields
		// bookseriesnum and bookseriesorder can be nil
	}
}

// Benchmark tests for performance
func BenchmarkGetWork(b *testing.B) {
	if testDB == nil {
		b.Skip("Database not available")
	}

	// Get a valid work ID for benchmarking
	var workID int
	row := testDB.DB.QueryRow("SELECT id FROM suomisf.work LIMIT 1")
	err := row.Scan(&workID)
	if err != nil {
		b.Skip("No works found in database")
	}
	validWorkID := fmt.Sprintf("%d", workID)

	gin.SetMode(gin.TestMode)
	router := gin.New()
	handler := NewWorkHandler(testDB)
	router.GET("/api/works/:workId", handler.GetWork)

	b.ResetTimer()
	for i := 0; i < b.N; i++ {
		req, _ := http.NewRequest("GET", fmt.Sprintf("/api/works/%s", validWorkID), nil)
		w := httptest.NewRecorder()
		router.ServeHTTP(w, req)
	}
}
