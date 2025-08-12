# Tag Handler Tests

This directory contains comprehensive tests for the Tag API functionality.

## Test Files

### `tags_test.go`
Core unit tests that test basic functionality and error cases. These tests include:

- **Success Tests**: Test normal operation of GetTags and GetTag endpoints
- **Pagination Tests**: Verify pagination parameters work correctly
- **Search Tests**: Test search functionality
- **Sorting Tests**: Test different sorting options (name, type, id)
- **Error Cases**: Test empty tag ID, nil database, not found scenarios
- **Data Integrity**: Verify consistent data types and required fields
- **Edge Cases**: Test with various tag ID formats
- **Performance Baseline**: Basic performance measurement

### `tags_integration_test.go`
Integration tests that require a database connection. These tests include:

- **Integration Tests**: Test complete workflows between GetTags and GetTag
- **Data Consistency**: Verify comprehensive data structure and field presence
- **Role-Based Filtering**: Verify correct role filtering for contributions
- **Benchmark Tests**: Performance benchmarks for optimization
- **Stress Tests**: Stability testing under load
- **Robustness Tests**: Test with various tag IDs

## Running Tests

### Prerequisites

1. **PostgreSQL Database**: Set up a PostgreSQL database with the suomisf schema
2. **Environment Variable**: Set `DATABASE_URL` or use default test database URL
3. **Test Data**: Ensure database contains test data for comprehensive testing

### Basic Test Commands

```bash
# Run all tag tests
go test ./internal/handlers -v -run TestTagHandler

# Run only unit tests (no database required)
go test ./internal/handlers -v -run "TestTagHandler_.*_NilDatabase|TestTagHandler_.*_EmptyTagID"

# Run integration tests (requires database)
go test ./internal/handlers -v -run TestTagHandler_Integration

# Run benchmark tests
go test ./internal/handlers -bench=BenchmarkTagHandler -benchmem

# Run stress tests (long running)
go test ./internal/handlers -v -run TestTagHandler_StressTest

# Run all tests in short mode (skips long-running tests)
go test ./internal/handlers -v -short
```

### Test Categories

#### 1. Unit Tests (No Database Required)
- `TestTagHandler_GetTags_NilDatabase`
- `TestTagHandler_GetTag_EmptyTagID`
- `TestTagHandler_GetTag_NilDatabase`

#### 2. Database Integration Tests
- `TestTagHandler_GetTags_Success`
- `TestTagHandler_GetTags_WithPagination`
- `TestTagHandler_GetTags_WithSearch`
- `TestTagHandler_GetTags_WithSorting`
- `TestTagHandler_GetTag_Success`
- `TestTagHandler_GetTag_CompleteStructure`
- `TestTagHandler_GetTag_NotFound`

#### 3. Data Validation Tests
- `TestTagHandler_DataIntegrity`
- `TestTagHandler_Integration_VerifyDataConsistency`
- `TestTagHandler_Integration_RoleBasedFiltering`

#### 4. Performance Tests
- `BenchmarkTagHandler_GetTags`
- `BenchmarkTagHandler_GetTag`
- `BenchmarkTagHandler_GetTagWithComplexData`
- `TestTagHandler_StressTest`
- `TestTagHandler_PerformanceBaseline`

#### 5. Robustness Tests
- `TestTagHandler_EdgeCases`
- `TestTagHandler_VariousTagIDs`
- `TestTagHandler_ResponseHeaders`

## Test Data Requirements

For comprehensive testing, the database should contain:

1. **Tags with different types** (to test type filtering and sorting)
2. **Tags with works, articles, and stories** (to test relationship queries)
3. **Complex data structures** including:
   - Works with multiple editions
   - Stories with multiple authors
   - Various contributor roles (1, 2, 3, 4, 5, 6)
   - Genre associations
   - Ownership data

### Recommended Test Tag: ID 303
Tag ID 303 is used in many tests as it contains comprehensive data including:
- Multiple stories with authors
- Stories with genres (including empty genres for array testing)
- Complex nested structures
- Role-based contributions

## Test Coverage

The tests cover:

### API Endpoints
- ✅ `GET /api/tags` - List all tags
- ✅ `GET /api/tags/:tagId` - Get specific tag details

### Functionality Coverage
- ✅ Basic CRUD operations
- ✅ Pagination and search
- ✅ Sorting in multiple directions
- ✅ Error handling and validation
- ✅ Database connection handling
- ✅ Response format validation
- ✅ Data type consistency
- ✅ Role-based filtering
- ✅ Empty array guarantees
- ✅ Complex nested structures
- ✅ Performance characteristics

### Edge Cases
- ✅ Empty tag ID
- ✅ Non-existent tag ID
- ✅ Nil database connection
- ✅ Invalid parameters
- ✅ Various tag ID formats
- ✅ Large tag IDs
- ✅ Concurrent requests

## Continuous Integration

These tests are designed to:

1. **Skip gracefully** when database is not available
2. **Provide meaningful output** for debugging
3. **Run quickly** for fast feedback
4. **Scale appropriately** (short mode for CI, full mode for comprehensive testing)

## Adding New Tests

When adding new tests:

1. **Use descriptive test names** following the pattern `TestTagHandler_Feature_Scenario`
2. **Check for database availability** and skip if not present
3. **Use table-driven tests** for multiple similar scenarios
4. **Include both positive and negative test cases**
5. **Add appropriate assertions** with descriptive error messages
6. **Consider performance impact** for benchmark tests

## Test Database Setup

For local development, set up a test database:

```sql
-- Create test database
CREATE DATABASE suomisf_test;

-- Import schema and test data
psql -d suomisf_test -f schema.sql
psql -d suomisf_test -f test_data.sql
```

Set environment variable:
```bash
export DATABASE_URL="postgresql://postgres:postgres@127.0.0.1:5432/suomisf_test?sslmode=disable"
```

## Troubleshooting

### Common Issues

1. **Tests skipping**: Database not available - check DATABASE_URL
2. **Panic in tests**: Nil pointer - ensure test database has schema
3. **Slow tests**: Large dataset - use smaller test data or short mode
4. **Flaky tests**: Race conditions - check for proper test isolation

### Debug Commands

```bash
# Verbose output with test details
go test ./internal/handlers -v -run TestTagHandler_GetTag_Success

# Run single test with debug info
go test ./internal/handlers -v -run TestTagHandler_DataIntegrity -test.timeout=30s

# Check test coverage
go test ./internal/handlers -cover -coverprofile=coverage.out
go tool cover -html=coverage.out
```
