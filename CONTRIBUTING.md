# Contributing to GoSuomiSF

Thank you for your interest in contributing to GoSuomiSF! This document provides guidelines and information for contributors.

## 🤝 How to Contribute

### Reporting Issues

1. **Search existing issues** first to avoid duplicates
2. **Use the issue template** and provide as much detail as possible
3. **Include steps to reproduce** the problem
4. **Add relevant labels** to help categorize the issue

### Submitting Changes

1. **Fork the repository** and create your branch from `main`
2. **Create a feature branch** with a descriptive name:
   ```bash
   git checkout -b feature/add-new-endpoint
   git checkout -b fix/pagination-bug
   git checkout -b docs/update-readme
   ```
3. **Make your changes** following the coding standards
4. **Add or update tests** for your changes
5. **Update documentation** if needed
6. **Commit your changes** with clear, descriptive messages
7. **Push to your fork** and submit a pull request

### Pull Request Process

1. **Update the README.md** with details of changes if applicable
2. **Add tests** that prove your fix is effective or that your feature works
3. **Make sure all tests pass** and the build succeeds
4. **Request review** from maintainers
5. **Address feedback** promptly and professionally

## 🛠️ Development Setup

### Prerequisites

- Go 1.22 or higher
- MySQL 8.0 or higher
- Docker and Docker Compose (optional)

### Local Development

1. **Clone your fork**:
   ```bash
   git clone https://github.com/yourusername/gosuomisf.git
   cd gosuomisf
   ```

2. **Set up environment**:
   ```bash
   cp .env.example .env
   # Edit .env with your local database settings
   ```

3. **Start dependencies** (using Docker):
   ```bash
   docker-compose up -d db
   ```

4. **Run migrations**:
   ```bash
   mysql -u root -p < migrations/001_initial_schema.sql
   ```

5. **Install dependencies**:
   ```bash
   go mod download
   ```

6. **Run the application**:
   ```bash
   go run main.go
   ```

### Running Tests

```bash
# Run all tests
go test ./...

# Run tests with coverage
go test -cover ./...

# Run tests for specific package
go test ./internal/handlers

# Run tests with verbose output
go test -v ./...
```

### Live Reload Development

Install Air for live reloading:

```bash
go install github.com/cosmtrek/air@latest
air
```

## 📝 Coding Standards

### Go Style Guide

- Follow the [Go Code Review Comments](https://github.com/golang/go/wiki/CodeReviewComments)
- Use `gofmt` to format your code
- Use `go vet` to check for suspicious constructs
- Use meaningful variable and function names
- Write clear, concise comments for exported functions

### Code Organization

- **Handlers**: HTTP request handlers in `internal/handlers/`
- **Models**: Data structures in `internal/models/`
- **Database**: Database operations in `internal/database/`
- **Authentication**: Auth middleware in `internal/auth/`
- **Configuration**: Config management in `internal/config/`

### Naming Conventions

- **Files**: Use snake_case for file names (e.g., `user_handler.go`)
- **Functions**: Use camelCase for function names (e.g., `getUserByID`)
- **Constants**: Use UPPER_CASE for constants (e.g., `MAX_PAGE_SIZE`)
- **Variables**: Use camelCase for variables (e.g., `userID`)

### Error Handling

- Always handle errors explicitly
- Use meaningful error messages
- Return appropriate HTTP status codes
- Log errors for debugging purposes

Example:
```go
func (h *UserHandler) GetUser(c *gin.Context) {
    userID, err := strconv.Atoi(c.Param("userID"))
    if err != nil {
        c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid user ID"})
        return
    }

    user, err := h.db.GetUserByID(userID)
    if err != nil {
        log.Printf("Error getting user %d: %v", userID, err)
        c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to get user"})
        return
    }

    c.JSON(http.StatusOK, user)
}
```

### Testing

- Write unit tests for all new functionality
- Use table-driven tests where appropriate
- Mock external dependencies
- Aim for high test coverage
- Use descriptive test names

Example:
```go
func TestUserHandler_GetUser(t *testing.T) {
    tests := []struct {
        name           string
        userID         string
        expectedStatus int
        expectedUser   *models.User
    }{
        {
            name:           "valid user ID",
            userID:         "1",
            expectedStatus: http.StatusOK,
            expectedUser:   &models.User{ID: 1, Name: "Test User"},
        },
        {
            name:           "invalid user ID",
            userID:         "invalid",
            expectedStatus: http.StatusBadRequest,
            expectedUser:   nil,
        },
    }

    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            // Test implementation
        })
    }
}
```

## 📊 Database Guidelines

### Schema Changes

- **Never** modify existing migrations
- **Always** create new migration files for schema changes
- **Test migrations** both up and down
- **Document** complex schema changes

### Queries

- Use prepared statements to prevent SQL injection
- Optimize queries for performance
- Use appropriate indexes
- Handle NULL values properly

## 🚀 Release Process

1. **Version bumping** follows semantic versioning (SemVer)
2. **Changelog** is updated with all changes
3. **Tags** are created for releases
4. **GitHub releases** include compiled binaries

## 📞 Getting Help

- **GitHub Issues**: For bug reports and feature requests
- **Discussions**: For questions and general discussion
- **Code Review**: Request reviews on your pull requests

## 🏷️ Issue Labels

- `bug`: Something isn't working
- `enhancement`: New feature or request
- `documentation`: Improvements or additions to documentation
- `good first issue`: Good for newcomers
- `help wanted`: Extra attention is needed
- `question`: Further information is requested

## 🎯 Areas for Contribution

We welcome contributions in these areas:

- **API endpoints**: New endpoints or improvements to existing ones
- **Performance**: Query optimization, caching, etc.
- **Testing**: Unit tests, integration tests, test coverage
- **Documentation**: README, code comments, API documentation
- **DevOps**: CI/CD improvements, Docker optimizations
- **Security**: Authentication, authorization, input validation
- **Frontend integration**: CORS, API design improvements

Thank you for contributing to GoSuomiSF! 🙏
