#!/bin/bash

# Quick test runner for specific test patterns

set -e

# Default test pattern
TEST_PATTERN=${1:-"./internal/handlers/"}
TEST_FLAGS=${2:-"-v"}

echo "🚀 Starting quick test environment..."

# Function to cleanup
cleanup() {
    echo "🧹 Cleaning up..."
    sudo docker-compose -f docker-compose.test.yml down
}

# Trap cleanup on script exit
trap cleanup EXIT

# Start database if not running
if ! sudo docker-compose -f docker-compose.test.yml ps test-db | grep -q "Up"; then
    echo "📦 Starting PostgreSQL test database..."
    sudo docker-compose -f docker-compose.test.yml up -d test-db

    # Wait for database
    echo "⏳ Waiting for database..."
    max_attempts=30
    attempt=0

    while [ $attempt -lt $max_attempts ]; do
        if sudo docker-compose -f docker-compose.test.yml exec test-db pg_isready -U postgres -d suomisf_test > /dev/null 2>&1; then
            echo "✅ Database is ready!"
            break
        fi
        attempt=$((attempt + 1))
        sleep 2
    done

    # Wait for SQL initialization
    sleep 5
fi

# Run specific tests
echo "🧪 Running tests: $TEST_PATTERN $TEST_FLAGS"
sudo docker-compose -f docker-compose.test.yml run --rm -e DATABASE_URL=postgresql://postgres:postgres@test-db:5432/suomisf_test?sslmode=disable test-runner go test $TEST_PATTERN $TEST_FLAGS

echo "✅ Tests completed!"
