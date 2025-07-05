#!/bin/bash

# SuomiSF Database Setup Script

echo "Setting up SuomiSF database..."

# Check if MySQL is running
if ! mysql -u root -p --execute="SELECT 1;" > /dev/null 2>&1; then
    echo "Error: Cannot connect to MySQL. Please make sure MySQL is running and you have the correct credentials."
    exit 1
fi

# Create database
echo "Creating database..."
mysql -u root -p -e "CREATE DATABASE IF NOT EXISTS suomisf CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"

if [ $? -eq 0 ]; then
    echo "Database 'suomisf' created successfully."
else
    echo "Error creating database."
    exit 1
fi

# Run migrations
echo "Running migrations..."
mysql -u root -p suomisf < migrations/001_initial_schema.sql

if [ $? -eq 0 ]; then
    echo "Migrations completed successfully."
    echo ""
    echo "Setup complete! You can now start the server with:"
    echo "  make run"
    echo "or"
    echo "  ./bin/suomisf"
else
    echo "Error running migrations."
    exit 1
fi
