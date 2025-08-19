# Test Documentation for Works API

## Overview
This document describes the comprehensive test suite for the new work functionality including awards enhancement and refactored editions query.

## Test Files

### works_test.go
Tests the core work API functionality with comprehensive coverage of all new features.

#### Test Categories

1. **Basic Functionality Tests**
   - `TestWorkHandler_NilDatabase`: Tests proper error handling when database is not available
   - `TestGetWork`: Basic work retrieval with different scenarios (valid ID, invalid ID, non-numeric ID)

2. **Awards Enhancement Tests**
   - `TestGetWorkAwards`: Validates the enhanced awards structure with work and short objects
   - Tests that awards include proper id/title fields for both work and short references
   - Validates award, category, work, and short object structures

3. **Editions Integration Tests**
   - `TestGetWorkEditions`: Tests edition structure and proper field handling
   - Validates editionnum handling and null safety
   - Tests collections initialization (images, owners, wishlisted, contributions)

4. **Genre/Tag/Link Tests**
   - `TestGetWorkGenres`: Tests genre structure and relationships
   - `TestGetWorkTags`: Tests tag structure and data integrity
   - `TestGetWorkLinks`: Tests link structure and optional fields

5. **Story Integration Tests**
   - `TestGetWorkStories`: Tests complex story structure with contributors and genres
   - Validates story contributor alt_name fields
   - Tests genre and type object structures within stories

6. **Contributions Tests**
   - `TestGetWorkContributions`: Tests work-level contributor structure
   - Validates person objects with alt_name fields
   - Tests role object structures

7. **Bookseries Tests**
   - `TestGetWorkBookseries`: Tests bookseries integration
   - Validates optional bookseries fields (bookseriesnum, bookseriesorder)

8. **Performance Tests**
   - `BenchmarkGetWork`: Performance baseline for the enhanced work API

### tags_test.go (Enhanced)
Added tests for the refactored `getEditionsForWork` function.

#### New Test Functions

1. **Function Unit Tests**
   - `TestGetEditionsForWork`: Tests the extracted function directly
   - Validates edition structure and collection initialization
   - Tests with both existing and non-existing works

2. **Integration Tests**
   - `TestGetTagWithEditionsIntegration`: Tests that the refactored function works correctly in the tag endpoint
   - Validates that edition data structure matches between endpoints

## Test Database Requirements

Tests are designed to gracefully handle missing database connections:
- Database-dependent tests skip when no connection available
- Nil database tests validate proper error handling
- Database URL: `postgresql://postgres:postgres@127.0.0.1:5432/suomisf_test?sslmode=disable`

## Test Data Expectations

Some tests expect specific data to be present in the test database:
- Work ID 1: Basic work with editions
- Work ID 23: Work with awards data
- Work ID 731: Work with bookseries information
- Work ID 5881: Work with stories
- Tag ID 1: Tag with associated works

## Key Testing Features

### Awards Enhancement Validation
Tests validate the new awards structure includes:
```json
{
  "id": number,
  "year": number,
  "award": {"id": number, "name": string},
  "category": {"id": number, "name": string} | null,
  "work": {"id": number, "title": string} | null,
  "short": {"id": number, "title": string} | null
}
```

### Edition Structure Validation
Tests ensure editions include:
- Proper editionnum handling (not null, positive values)
- Initialized collections (images, owners, wishlisted, contributions)
- Null safety for optional fields

### Contributor alt_name Testing
Tests validate that all contributor objects include alt_name fields:
```json
{
  "person": {
    "id": number,
    "name": string,
    "alt_name": string | null
  },
  "role": {"id": number, "name": string}
}
```

## Running Tests

```bash
# Run all tests
go test ./internal/handlers -v

# Run specific work tests
go test ./internal/handlers -v -run "TestGetWork"

# Run refactored function tests
go test ./internal/handlers -v -run "TestGetEditionsForWork"

# Run with database (requires test database setup)
DATABASE_URL="postgresql://postgres:postgres@127.0.0.1:5432/suomisf_test?sslmode=disable" \
go test ./internal/handlers -v
```

## Test Coverage

The test suite provides comprehensive coverage of:
- ✅ All new work API fields and relationships
- ✅ Awards enhancement with work/short objects
- ✅ Refactored getEditionsForWork function
- ✅ Proper null handling and error cases
- ✅ Collection initialization and structure validation
- ✅ Integration between components
- ✅ Performance benchmarking

## Future Enhancements

Potential areas for test expansion:
- Database transaction testing
- Concurrent access testing
- Error injection testing
- Response time validation
- Memory usage benchmarking
