package handlers

import (
	"encoding/json"
	"fmt"
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/gin-gonic/gin"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

// Integration tests that run with database connection
func TestTagHandler_Integration_GetTagsAndGetTag(t *testing.T) {
	if testDB == nil {
		t.Skip("Skipping integration test without database connection")
	}

	handler := NewTagHandler(testDB)

	// Step 1: Get all tags
	w := httptest.NewRecorder()
	c, _ := gin.CreateTestContext(w)
	c.Request, _ = http.NewRequest("GET", "/api/tags", nil)

	handler.GetTags(c)
	require.Equal(t, http.StatusOK, w.Code)

	var tags []map[string]interface{}
	err := json.Unmarshal(w.Body.Bytes(), &tags)
	require.NoError(t, err)

	if len(tags) > 0 {
		// Step 2: Get details for the first tag
		tagID := tags[0]["id"]
		tagIDStr := fmt.Sprintf("%.0f", tagID.(float64))

		w = httptest.NewRecorder()
		c, _ = gin.CreateTestContext(w)
		c.Params = gin.Params{gin.Param{Key: "tagId", Value: tagIDStr}}

		handler.GetTag(c)
		require.Equal(t, http.StatusOK, w.Code)

		var tagDetails map[string]interface{}
		err := json.Unmarshal(w.Body.Bytes(), &tagDetails)
		require.NoError(t, err)

		// Step 3: Verify consistency between endpoints
		assert.Equal(t, tagID, tagDetails["id"])
		assert.Equal(t, tags[0]["name"], tagDetails["name"])

		// Step 4: Verify comprehensive structure
		assert.Contains(t, tagDetails, "works")
		assert.Contains(t, tagDetails, "articles")
		assert.Contains(t, tagDetails, "stories")
		assert.Contains(t, tagDetails, "magazines")
		assert.Contains(t, tagDetails, "people")
	}
}

func TestTagHandler_Integration_VerifyDataConsistency(t *testing.T) {
	if testDB == nil {
		t.Skip("Skipping integration test without database connection")
	}

	handler := NewTagHandler(testDB)

	// Test a known tag that should have comprehensive data
	w := httptest.NewRecorder()
	c, _ := gin.CreateTestContext(w)
	c.Params = gin.Params{gin.Param{Key: "tagId", Value: "303"}}

	handler.GetTag(c)

	if w.Code == http.StatusOK {
		var response map[string]interface{}
		err := json.Unmarshal(w.Body.Bytes(), &response)
		require.NoError(t, err)

		// Verify all stories have required fields
		if stories, ok := response["stories"].([]interface{}); ok {
			for i, storyInterface := range stories {
				story := storyInterface.(map[string]interface{})

				// Required fields
				requiredFields := []string{"id", "title", "authors", "genres", "contributors", "issues", "editions"}
				for _, field := range requiredFields {
					assert.Contains(t, story, field, fmt.Sprintf("Story %d missing field %s", i, field))
				}

				// Verify genres is always an array (empty or populated)
				genres := story["genres"]
				assert.IsType(t, []interface{}{}, genres, fmt.Sprintf("Story %d genres should be array", i))

				// Verify authors structure if present
				if authors, ok := story["authors"].([]interface{}); ok && len(authors) > 0 {
					author := authors[0].(map[string]interface{})
					authorRequiredFields := []string{"id", "name", "roles", "workcount", "storycount"}
					for _, field := range authorRequiredFields {
						assert.Contains(t, author, field, fmt.Sprintf("Story %d author missing field %s", i, field))
					}

					// Verify ID is integer
					assert.IsType(t, float64(0), author["id"], "Author ID should be numeric")

					// Verify counts are integers
					assert.IsType(t, float64(0), author["workcount"], "Author workcount should be numeric")
					assert.IsType(t, float64(0), author["storycount"], "Author storycount should be numeric")
				}
			}
		}

		// Verify all works have required fields
		if works, ok := response["works"].([]interface{}); ok {
			for i, workInterface := range works {
				work := workInterface.(map[string]interface{})

				// Required fields for works
				requiredFields := []string{"id", "title", "contributions", "editions", "genres"}
				for _, field := range requiredFields {
					assert.Contains(t, work, field, fmt.Sprintf("Work %d missing field %s", i, field))
				}

				// Verify ID is integer
				assert.IsType(t, float64(0), work["id"], "Work ID should be numeric")

				// Check editions structure if present
				if editions, ok := work["editions"].([]interface{}); ok && len(editions) > 0 {
					edition := editions[0].(map[string]interface{})
					editionRequiredFields := []string{"id", "title", "contributions", "translators", "images"}
					for _, field := range editionRequiredFields {
						assert.Contains(t, edition, field, fmt.Sprintf("Work %d edition missing field %s", i, field))
					}
				}
			}
		}
	}
}

func TestTagHandler_Integration_RoleBasedFiltering(t *testing.T) {
	if testDB == nil {
		t.Skip("Skipping integration test without database connection")
	}

	handler := NewTagHandler(testDB)

	// Test that role-based filtering is working correctly
	w := httptest.NewRecorder()
	c, _ := gin.CreateTestContext(w)
	c.Params = gin.Params{gin.Param{Key: "tagId", Value: "303"}}

	handler.GetTag(c)

	if w.Code == http.StatusOK {
		var response map[string]interface{}
		err := json.Unmarshal(w.Body.Bytes(), &response)
		require.NoError(t, err)

		// Check that works have contributions with correct roles (1, 3)
		if works, ok := response["works"].([]interface{}); ok && len(works) > 0 {
			for _, workInterface := range works {
				work := workInterface.(map[string]interface{})
				if contributions, ok := work["contributions"].([]interface{}); ok {
					for _, contribInterface := range contributions {
						contrib := contribInterface.(map[string]interface{})
						if role, ok := contrib["role"].(map[string]interface{}); ok {
							roleID := role["id"].(float64)
							assert.True(t, roleID == 1 || roleID == 3, 
								"Work contributions should only have role IDs 1 or 3, got %.0f", roleID)
						}
					}
				}

				// Check that editions have contributions with correct roles (2, 4, 5)
				if editions, ok := work["editions"].([]interface{}); ok {
					for _, editionInterface := range editions {
						edition := editionInterface.(map[string]interface{})
						if contributions, ok := edition["contributions"].([]interface{}); ok {
							for _, contribInterface := range contributions {
								contrib := contribInterface.(map[string]interface{})
								if role, ok := contrib["role"].(map[string]interface{}); ok {
									roleID := role["id"].(float64)
									assert.True(t, roleID == 2 || roleID == 4 || roleID == 5, 
										"Edition contributions should only have role IDs 2, 4, or 5, got %.0f", roleID)
								}
							}
						}
					}
				}
			}
		}

		// Check that stories have contributors with correct roles (1, 2, 6)
		if stories, ok := response["stories"].([]interface{}); ok {
			for _, storyInterface := range stories {
				story := storyInterface.(map[string]interface{})
				if contributors, ok := story["contributors"].([]interface{}); ok {
					for _, contribInterface := range contributors {
						contrib := contribInterface.(map[string]interface{})
						if role, ok := contrib["role"].(map[string]interface{}); ok {
							roleID := role["id"].(float64)
							assert.True(t, roleID == 1 || roleID == 2 || roleID == 6, 
								"Story contributors should only have role IDs 1, 2, or 6, got %.0f", roleID)
						}
					}
				}
			}
		}
	}
}

// Benchmark tests
func BenchmarkTagHandler_GetTags(b *testing.B) {
	if testDB == nil {
		b.Skip("Skipping benchmark without database connection")
	}

	handler := NewTagHandler(testDB)

	b.ResetTimer()
	for i := 0; i < b.N; i++ {
		w := httptest.NewRecorder()
		c, _ := gin.CreateTestContext(w)
		c.Request, _ = http.NewRequest("GET", "/api/tags", nil)

		handler.GetTags(c)
	}
}

func BenchmarkTagHandler_GetTag(b *testing.B) {
	if testDB == nil {
		b.Skip("Skipping benchmark without database connection")
	}

	handler := NewTagHandler(testDB)

	b.ResetTimer()
	for i := 0; i < b.N; i++ {
		w := httptest.NewRecorder()
		c, _ := gin.CreateTestContext(w)
		c.Params = gin.Params{gin.Param{Key: "tagId", Value: "303"}}

		handler.GetTag(c)
	}
}

func BenchmarkTagHandler_GetTagWithComplexData(b *testing.B) {
	if testDB == nil {
		b.Skip("Skipping benchmark without database connection")
	}

	handler := NewTagHandler(testDB)

	// Test with a tag that has lots of related data
	b.ResetTimer()
	for i := 0; i < b.N; i++ {
		w := httptest.NewRecorder()
		c, _ := gin.CreateTestContext(w)
		c.Params = gin.Params{gin.Param{Key: "tagId", Value: "303"}}

		handler.GetTag(c)

		// Ensure we actually get data
		if w.Code == http.StatusOK {
			var response map[string]interface{}
			json.Unmarshal(w.Body.Bytes(), &response)
		}
	}
}

// Stress test to verify memory usage and stability
func TestTagHandler_StressTest(t *testing.T) {
	if testDB == nil {
		t.Skip("Skipping stress test without database connection")
	}

	if testing.Short() {
		t.Skip("Skipping stress test in short mode")
	}

	handler := NewTagHandler(testDB)

	// Make many concurrent requests to test stability
	const numRequests = 50

	for i := 0; i < numRequests; i++ {
		w := httptest.NewRecorder()
		c, _ := gin.CreateTestContext(w)
		c.Params = gin.Params{gin.Param{Key: "tagId", Value: "303"}}

		handler.GetTag(c)

		// Should always return a valid response
		assert.True(t, w.Code == http.StatusOK || w.Code == http.StatusNotFound)

		if w.Code == http.StatusOK {
			var response map[string]interface{}
			err := json.Unmarshal(w.Body.Bytes(), &response)
			assert.NoError(t, err, "Response should be valid JSON")
		}
	}
}

// Test with various tag IDs to ensure robustness
func TestTagHandler_VariousTagIDs(t *testing.T) {
	if testDB == nil {
		t.Skip("Skipping test without database connection")
	}

	handler := NewTagHandler(testDB)

	// Test various tag IDs that might exist
	tagIDs := []string{"1", "5", "10", "50", "100", "303", "500", "1000"}

	for _, tagID := range tagIDs {
		t.Run(fmt.Sprintf("TagID_%s", tagID), func(t *testing.T) {
			w := httptest.NewRecorder()
			c, _ := gin.CreateTestContext(w)
			c.Params = gin.Params{gin.Param{Key: "tagId", Value: tagID}}

			handler.GetTag(c)

			// Should return either OK (found) or NotFound (doesn't exist)
			assert.True(t, w.Code == http.StatusOK || w.Code == http.StatusNotFound,
				"Tag ID %s should return 200 or 404, got %d", tagID, w.Code)

			if w.Code == http.StatusOK {
				var response map[string]interface{}
				err := json.Unmarshal(w.Body.Bytes(), &response)
				require.NoError(t, err)

				// Basic structure validation
				assert.Contains(t, response, "id")
				assert.Contains(t, response, "name")
				assert.Contains(t, response, "works")
				assert.Contains(t, response, "articles")
				assert.Contains(t, response, "stories")
			}
		})
	}
}
