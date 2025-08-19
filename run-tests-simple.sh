#!/bin/bash

# Simple test runner without Docker

set -e

echo "🚀 Starting SuomiSF test suite..."

# Check if we can connect to the existing database
echo "🔍 Checking database connection..."

# Test with the existing database first
export DATABASE_URL="postgresql://mep:password@127.0.0.1:5432/suomisf?sslmode=disable"

if PGPASSWORD=password psql -h 127.0.0.1 -U mep -d suomisf -c "SELECT 1;" > /dev/null 2>&1; then
    echo "✅ Connected to existing database"

    echo "🧪 Running tests with existing database..."
    echo "Note: Tests will run against the main database with test data"

    # Clean the test cache to ensure environment variables are picked up
    go clean -testcache

    # Run tests with explicit environment variable
    DATABASE_URL="postgresql://mep:password@127.0.0.1:5432/suomisf?sslmode=disable" go test ./internal/handlers/ -v

    echo "✅ Tests completed!"
else
    echo "❌ Cannot connect to database"
    echo "Note: Tests will run in mock mode (many will be skipped)"

    # Clean the test cache
    go clean -testcache

    # Run tests in mock mode
    go test ./internal/handlers/ -v

    echo "✅ Mock tests completed!"
fi
