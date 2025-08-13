#!/bin/bash

# Test runner script for Docker environment

set -e

echo "🚀 Starting SuomiSF test environment..."

# Function to cleanup
cleanup() {
    echo "🧹 Cleaning up..."
    sudo docker-compose -f docker-compose.test.yml down -v
}

# Trap cleanup on script exit
trap cleanup EXIT

# Start the test environment
echo "📦 Starting PostgreSQL test database..."
sudo docker-compose -f docker-compose.test.yml up --build -d test-db

# Wait for database to be ready
echo "⏳ Waiting for database to be ready..."
max_attempts=30
attempt=0

while [ $attempt -lt $max_attempts ]; do
    if sudo docker-compose -f docker-compose.test.yml exec test-db pg_isready -U postgres -d suomisf_test > /dev/null 2>&1; then
        echo "✅ Database is ready!"
        break
    fi
    
    attempt=$((attempt + 1))
    echo "   Attempt $attempt/$max_attempts - Database not ready yet..."
    sleep 2
done

if [ $attempt -eq $max_attempts ]; then
    echo "❌ Database failed to start within timeout"
    exit 1
fi

# Give the database a moment to fully initialize with the SQL dump
echo "⏳ Waiting for database initialization..."
sleep 10

# Run the tests
echo "🧪 Running tests..."
sudo docker-compose -f docker-compose.test.yml run --rm test-runner

echo "✅ Tests completed!"
