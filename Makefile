.PHONY: build run dev test clean install-deps migrate docker-up docker-down

# Build the application
build:
	go build -o bin/suomisf ./main.go

# Run the application
run: build
	./bin/suomisf

# Run in development mode with hot reload (requires air)
dev:
	air

# Run tests
test:
	go test -v ./...

# Clean build artifacts
clean:
	rm -rf bin/

# Install dependencies
install-deps:
	go mod download
	go mod tidy

# Install development tools
install-dev-tools:
	go install github.com/cosmtrek/air@latest

# Run database migrations
migrate:
	mysql -u root -p suomisf < migrations/001_initial_schema.sql

# Format code
fmt:
	go fmt ./...

# Lint code
lint:
	golangci-lint run

# Generate API documentation (requires swaggo/swag)
docs:
	swag init -g main.go

# Docker commands
docker-build:
	docker build -t suomisf-api .

docker-up:
	docker-compose up -d

docker-down:
	docker-compose down

# Database commands
db-create:
	psql -U postgres -c "CREATE DATABASE IF NOT EXISTS suomisf;"

db-drop:
	psql -U postgres -c "DROP DATABASE IF EXISTS suomisf;"

db-reset: db-drop db-create migrate

# Help
help:
	@echo "Available commands:"
	@echo "  build          - Build the application"
	@echo "  run            - Build and run the application"
	@echo "  dev            - Run in development mode with hot reload"
	@echo "  test           - Run tests"
	@echo "  clean          - Clean build artifacts"
	@echo "  install-deps   - Install Go dependencies"
	@echo "  migrate        - Run database migrations"
	@echo "  fmt            - Format code"
	@echo "  lint           - Lint code"
	@echo "  docker-build   - Build Docker image"
	@echo "  docker-up      - Start Docker containers"
	@echo "  docker-down    - Stop Docker containers"
	@echo "  db-create      - Create database"
	@echo "  db-drop        - Drop database"
	@echo "  db-reset       - Reset database (drop, create, migrate)"
