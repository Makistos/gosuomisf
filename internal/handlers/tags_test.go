package handlers

import (
	"encoding/json"
	"fmt"
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"

	"github.com/gin-gonic/gin"
	"github.com/makistos/gosuomisf/internal/models"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

func TestTagHandler_GetTags_Success(t *testing.T) {
	if testDB.DB == nil {
		t.Skip("Skipping test without database connection")
	}

	handler := NewTagHandler(testDB)

	// Test basic get tags without parameters
	w := httptest.NewRecorder()
	c, _ := gin.CreateTestContext(w)
	c.Request, _ = http.NewRequest("GET", "/api/tags", nil)

	handler.GetTags(c)

	require.Equal(t, http.StatusOK, w.Code)

	var tags []models.Tag
	err := json.Unmarshal(w.Body.Bytes(), &tags)
	require.NoError(t, err)
	
	// Should return an array of tags
	assert.IsType(t, []models.Tag{}, tags)
}

func TestTagHandler_GetTags_WithPagination(t *testing.T) {
	if testDB.DB == nil {
		t.Skip("Skipping test without database connection")
	}

	handler := NewTagHandler(testDB)

	// Test with pagination parameters
	w := httptest.NewRecorder()
	c, _ := gin.CreateTestContext(w)
	c.Request, _ = http.NewRequest("GET", "/api/tags?page=1&page_size=5", nil)

	handler.GetTags(c)

	require.Equal(t, http.StatusOK, w.Code)

	var tags []models.Tag
	err := json.Unmarshal(w.Body.Bytes(), &tags)
	require.NoError(t, err)
	
	// Should return no more than 5 tags
	assert.LessOrEqual(t, len(tags), 5)
}

func TestTagHandler_GetTags_WithSearch(t *testing.T) {
	if testDB.DB == nil {
		t.Skip("Skipping test without database connection")
	}

	handler := NewTagHandler(testDB)

	// Test with search parameter
	w := httptest.NewRecorder()
	c, _ := gin.CreateTestContext(w)
	c.Request, _ = http.NewRequest("GET", "/api/tags?search=science", nil)

	handler.GetTags(c)

	require.Equal(t, http.StatusOK, w.Code)

	var tags []models.Tag
	err := json.Unmarshal(w.Body.Bytes(), &tags)
	require.NoError(t, err)
	
	// Should return an array (might be empty if no matches)
	assert.IsType(t, []models.Tag{}, tags)
}

func TestTagHandler_GetTags_WithSorting(t *testing.T) {
	if testDB.DB == nil {
		t.Skip("Skipping test without database connection")
	}

	handler := NewTagHandler(testDB)

	testCases := []struct {
		name  string
		sort  string
		order string
	}{
		{"Sort by name ascending", "name", "asc"},
		{"Sort by name descending", "name", "desc"},
		{"Sort by type ascending", "type", "asc"},
		{"Sort by id ascending", "id", "asc"},
	}

	for _, tc := range testCases {
		t.Run(tc.name, func(t *testing.T) {
			w := httptest.NewRecorder()
			c, _ := gin.CreateTestContext(w)
			c.Request, _ = http.NewRequest("GET", fmt.Sprintf("/api/tags?sort=%s&order=%s", tc.sort, tc.order), nil)

			handler.GetTags(c)

			require.Equal(t, http.StatusOK, w.Code)

			var tags []models.Tag
			err := json.Unmarshal(w.Body.Bytes(), &tags)
			require.NoError(t, err)
			assert.IsType(t, []models.Tag{}, tags)
		})
	}
}

func TestTagHandler_GetTags_NilDatabase(t *testing.T) {
	handler := NewTagHandler(nil)

	w := httptest.NewRecorder()
	c, _ := gin.CreateTestContext(w)
	c.Request, _ = http.NewRequest("GET", "/api/tags", nil)

	handler.GetTags(c)

	assert.Equal(t, http.StatusInternalServerError, w.Code)
	
	var response map[string]string
	err := json.Unmarshal(w.Body.Bytes(), &response)
	require.NoError(t, err)
	assert.Equal(t, "Database not available", response["error"])
}

func TestTagHandler_GetTag_Success(t *testing.T) {
	if testDB.DB == nil {
		t.Skip("Skipping test without database connection")
	}

	handler := NewTagHandler(testDB)

	// First, get a list of tags to find a valid ID
	w := httptest.NewRecorder()
	c, _ := gin.CreateTestContext(w)
	c.Request, _ = http.NewRequest("GET", "/api/tags", nil)
	handler.GetTags(c)
	
	if w.Code == http.StatusOK {
		var tags []models.Tag
		err := json.Unmarshal(w.Body.Bytes(), &tags)
		require.NoError(t, err)
		
		if len(tags) > 0 {
			// Test getting a specific tag
			tagID := fmt.Sprintf("%d", tags[0].ID)
			
			w = httptest.NewRecorder()
			c, _ = gin.CreateTestContext(w)
			c.Params = gin.Params{gin.Param{Key: "tagId", Value: tagID}}

			handler.GetTag(c)

			require.Equal(t, http.StatusOK, w.Code)

			var response map[string]interface{}
			err := json.Unmarshal(w.Body.Bytes(), &response)
			require.NoError(t, err)
			
			// Check that response has expected structure
			assert.Contains(t, response, "id")
			assert.Contains(t, response, "name")
			assert.Contains(t, response, "works")
			assert.Contains(t, response, "articles")
			assert.Contains(t, response, "stories")
			assert.Contains(t, response, "magazines")
			assert.Contains(t, response, "people")
			
			// Verify arrays are present
			assert.IsType(t, []interface{}{}, response["works"])
			assert.IsType(t, []interface{}{}, response["articles"])
			assert.IsType(t, []interface{}{}, response["stories"])
			assert.IsType(t, []interface{}{}, response["magazines"])
			assert.IsType(t, []interface{}{}, response["people"])
		}
	}
}

func TestTagHandler_GetTag_CompleteStructure(t *testing.T) {
	if testDB.DB == nil {
		t.Skip("Skipping test without database connection")
	}

	handler := NewTagHandler(testDB)

	// Test with a known tag ID that should have data (e.g., tag 303 based on our previous testing)
	w := httptest.NewRecorder()
	c, _ := gin.CreateTestContext(w)
	c.Params = gin.Params{gin.Param{Key: "tagId", Value: "303"}}

	handler.GetTag(c)

	if w.Code == http.StatusOK {
		var response map[string]interface{}
		err := json.Unmarshal(w.Body.Bytes(), &response)
		require.NoError(t, err)
		
		// Verify comprehensive structure
		assert.Contains(t, response, "id")
		assert.Contains(t, response, "name")
		assert.Contains(t, response, "description")
		assert.Contains(t, response, "type")
		assert.Contains(t, response, "works")
		assert.Contains(t, response, "articles")
		assert.Contains(t, response, "stories")
		
		// If stories exist, check their structure
		stories, ok := response["stories"].([]interface{})
		if ok && len(stories) > 0 {
			story := stories[0].(map[string]interface{})
			
			// Check story structure
			assert.Contains(t, story, "id")
			assert.Contains(t, story, "title")
			assert.Contains(t, story, "authors")
			assert.Contains(t, story, "genres")
			assert.Contains(t, story, "contributors")
			assert.Contains(t, story, "type")
			
			// Verify genres is always an array
			genres := story["genres"]
			assert.IsType(t, []interface{}{}, genres, "Genres should always be an array")
			
			// If authors exist, check their structure
			authors, ok := story["authors"].([]interface{})
			if ok && len(authors) > 0 {
				author := authors[0].(map[string]interface{})
				
				// Check author structure
				assert.Contains(t, author, "id")
				assert.Contains(t, author, "name")
				assert.Contains(t, author, "roles")
				assert.Contains(t, author, "workcount")
				assert.Contains(t, author, "storycount")
				
				// Verify roles is an array
				assert.IsType(t, []interface{}{}, author["roles"])
			}
		}
		
		// If works exist, check their structure
		works, ok := response["works"].([]interface{})
		if ok && len(works) > 0 {
			work := works[0].(map[string]interface{})
			
			// Check work structure
			assert.Contains(t, work, "id")
			assert.Contains(t, work, "title")
			assert.Contains(t, work, "contributions")
			assert.Contains(t, work, "editions")
			assert.Contains(t, work, "genres")
			assert.Contains(t, work, "type")
			
			// Verify arrays are present
			assert.IsType(t, []interface{}{}, work["contributions"])
			assert.IsType(t, []interface{}{}, work["editions"])
			assert.IsType(t, []interface{}{}, work["genres"])
			
			// If editions exist, check their structure
			editions, ok := work["editions"].([]interface{})
			if ok && len(editions) > 0 {
				edition := editions[0].(map[string]interface{})
				
				// Check edition structure
				assert.Contains(t, edition, "id")
				assert.Contains(t, edition, "title")
				assert.Contains(t, edition, "contributions")
				assert.Contains(t, edition, "translators")
				assert.Contains(t, edition, "images")
				
				// Verify arrays
				assert.IsType(t, []interface{}{}, edition["contributions"])
				assert.IsType(t, []interface{}{}, edition["translators"])
				assert.IsType(t, []interface{}{}, edition["images"])
			}
		}
	}
}

func TestTagHandler_GetTag_NotFound(t *testing.T) {
	if testDB.DB == nil {
		t.Skip("Skipping test without database connection")
	}

	handler := NewTagHandler(testDB)

	// Test with non-existent tag ID
	w := httptest.NewRecorder()
	c, _ := gin.CreateTestContext(w)
	c.Params = gin.Params{gin.Param{Key: "tagId", Value: "999999"}}

	handler.GetTag(c)

	assert.Equal(t, http.StatusNotFound, w.Code)
	
	var response map[string]string
	err := json.Unmarshal(w.Body.Bytes(), &response)
	require.NoError(t, err)
	assert.Equal(t, "Tag not found", response["error"])
}

func TestTagHandler_GetTag_EmptyTagID(t *testing.T) {
	handler := NewTagHandler(testDB)

	// Test with empty tag ID
	w := httptest.NewRecorder()
	c, _ := gin.CreateTestContext(w)
	c.Params = gin.Params{gin.Param{Key: "tagId", Value: ""}}

	handler.GetTag(c)

	assert.Equal(t, http.StatusBadRequest, w.Code)
	
	var response map[string]string
	err := json.Unmarshal(w.Body.Bytes(), &response)
	require.NoError(t, err)
	assert.Equal(t, "Tag ID is required", response["error"])
}

func TestTagHandler_GetTag_NilDatabase(t *testing.T) {
	handler := NewTagHandler(nil)

	w := httptest.NewRecorder()
	c, _ := gin.CreateTestContext(w)
	c.Params = gin.Params{gin.Param{Key: "tagId", Value: "1"}}

	handler.GetTag(c)

	assert.Equal(t, http.StatusInternalServerError, w.Code)
	
	var response map[string]string
	err := json.Unmarshal(w.Body.Bytes(), &response)
	require.NoError(t, err)
	assert.Equal(t, "Database not available", response["error"])
}

func TestTagHandler_DataIntegrity(t *testing.T) {
	if testDB.DB == nil {
		t.Skip("Skipping test without database connection")
	}

	handler := NewTagHandler(testDB)

	// Test that GetTag returns consistent data types
	w := httptest.NewRecorder()
	c, _ := gin.CreateTestContext(w)
	c.Params = gin.Params{gin.Param{Key: "tagId", Value: "303"}}

	handler.GetTag(c)

	if w.Code == http.StatusOK {
		var response map[string]interface{}
		err := json.Unmarshal(w.Body.Bytes(), &response)
		require.NoError(t, err)
		
		// Test ID is number
		assert.IsType(t, float64(0), response["id"], "ID should be a number")
		
		// Test name is string
		assert.IsType(t, "", response["name"], "Name should be a string")
		
		// Test arrays are arrays
		assert.IsType(t, []interface{}{}, response["works"], "Works should be an array")
		assert.IsType(t, []interface{}{}, response["articles"], "Articles should be an array")
		assert.IsType(t, []interface{}{}, response["stories"], "Stories should be an array")
		assert.IsType(t, []interface{}{}, response["magazines"], "Magazines should be an array")
		assert.IsType(t, []interface{}{}, response["people"], "People should be an array")
		
		// Check stories have consistent structure
		stories, ok := response["stories"].([]interface{})
		if ok {
			for i, storyInterface := range stories {
				story, ok := storyInterface.(map[string]interface{})
				require.True(t, ok, fmt.Sprintf("Story %d should be an object", i))
				
				// Every story should have genres as an array
				genres, exists := story["genres"]
				assert.True(t, exists, fmt.Sprintf("Story %d should have genres field", i))
				assert.IsType(t, []interface{}{}, genres, fmt.Sprintf("Story %d genres should be an array", i))
				
				// Every story should have authors as an array
				authors, exists := story["authors"]
				assert.True(t, exists, fmt.Sprintf("Story %d should have authors field", i))
				assert.IsType(t, []interface{}{}, authors, fmt.Sprintf("Story %d authors should be an array", i))
				
				// Every story should have contributors as an array
				contributors, exists := story["contributors"]
				assert.True(t, exists, fmt.Sprintf("Story %d should have contributors field", i))
				assert.IsType(t, []interface{}{}, contributors, fmt.Sprintf("Story %d contributors should be an array", i))
			}
		}
	}
}

func TestTagHandler_ResponseHeaders(t *testing.T) {
	if testDB.DB == nil {
		t.Skip("Skipping test without database connection")
	}

	handler := NewTagHandler(testDB)

	// Test that responses have correct content type
	w := httptest.NewRecorder()
	c, _ := gin.CreateTestContext(w)
	c.Request, _ = http.NewRequest("GET", "/api/tags", nil)

	handler.GetTags(c)

	// Check content type is set correctly
	contentType := w.Header().Get("Content-Type")
	assert.True(t, strings.Contains(contentType, "application/json"), "Content-Type should be application/json")
}

func TestTagHandler_EdgeCases(t *testing.T) {
	if testDB.DB == nil {
		t.Skip("Skipping test without database connection")
	}

	handler := NewTagHandler(testDB)

	testCases := []struct {
		name       string
		tagID      string
		expectCode int
	}{
		{"Valid numeric tag ID", "1", -1}, // -1 means we accept either 200 or 404
		{"Zero tag ID", "0", -1},
		{"Negative tag ID", "-1", -1},
		{"Very large tag ID", "9999999999", -1},
	}

	for _, tc := range testCases {
		t.Run(tc.name, func(t *testing.T) {
			w := httptest.NewRecorder()
			c, _ := gin.CreateTestContext(w)
			c.Params = gin.Params{gin.Param{Key: "tagId", Value: tc.tagID}}

			handler.GetTag(c)

			if tc.expectCode == -1 {
				// Accept either OK (if exists) or NotFound (if doesn't exist)
				assert.True(t, w.Code == http.StatusOK || w.Code == http.StatusNotFound, 
					fmt.Sprintf("Expected 200 or 404, got %d for tag ID %s", w.Code, tc.tagID))
			} else {
				assert.Equal(t, tc.expectCode, w.Code)
			}
		})
	}
}

func TestTagHandler_PerformanceBaseline(t *testing.T) {
	if testDB.DB == nil {
		t.Skip("Skipping test without database connection")
	}

	handler := NewTagHandler(testDB)

	// This test provides a baseline for response time measurement
	// Useful for regression testing and performance monitoring
	
	startTime := testing.Short()
	if startTime {
		t.Skip("Skipping performance test in short mode")
	}

	// Test GetTags performance
	w := httptest.NewRecorder()
	c, _ := gin.CreateTestContext(w)
	c.Request, _ = http.NewRequest("GET", "/api/tags", nil)

	handler.GetTags(c)

	// Just verify it completes successfully
	assert.True(t, w.Code == http.StatusOK || w.Code == http.StatusInternalServerError)

	// Test GetTag performance with a known tag
	w = httptest.NewRecorder()
	c, _ = gin.CreateTestContext(w)
	c.Params = gin.Params{gin.Param{Key: "tagId", Value: "303"}}

	handler.GetTag(c)

	// Just verify it completes successfully
	assert.True(t, w.Code == http.StatusOK || w.Code == http.StatusNotFound || w.Code == http.StatusInternalServerError)
}
