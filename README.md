# GoSuomiSF

A modern REST API backend for the Finnish Science Fiction Bibliography (SuomiSF) built with Go, Gin, and PostgreSQL. This is a Go rewrite of the original Python/Flask SuomiSF project.

[![Go Version](https://img.shields.io/badge/Go-1.22+-00ADD8?style=flat&logo=go)](https://golang.org/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Database](https://img.shields.io/badge/Database-PostgreSQL-4169E1?style=flat&logo=postgresql&logoColor=white)](https://postgresql.org/)

## 🚀 Features

- **🔐 Authentication**: JWT-based authentication with login, registration, and token refresh
- **📚 REST API**: Full CRUD operations for works, people, editions, short stories, and tags
- **🔍 Search & Filter**: Advanced search capabilities with pagination and sorting
- **🔗 Foreign Key Resolution**: Automatic resolution of foreign keys to human-readable values
- **🗄️ Database**: PostgreSQL with proper indexing and relationships
- **📄 Pagination**: Efficient pagination for large datasets
- **🌐 CORS**: Configurable CORS support for frontend integration
- **🔒 Authorization**: Role-based access control
- **📊 JSON API**: All responses use JSON format

## 🏗️ Architecture

```
gosuomisf/
├── internal/
│   ├── api/          # API route definitions
│   ├── auth/         # Authentication middleware
│   ├── config/       # Configuration management
│   ├── database/     # Database connection and queries
│   ├── handlers/     # HTTP request handlers
│   └── models/       # Data models and structures
├── migrations/       # Database migration scripts
├── scripts/          # Utility scripts
├── main.go          # Application entry point
└── docker-compose.yml # Docker setup
```

## 🛠️ Technology Stack

- **Language**: Go 1.22+
- **Web Framework**: [Gin](https://gin-gonic.com/)
- **Database**: PostgreSQL 15+
- **Authentication**: JWT tokens
- **Password Hashing**: bcrypt
- **Testing**: Go testing framework with testify
- **Containerization**: Docker & Docker Compose

## 📋 Prerequisites

- Go 1.22 or higher
- PostgreSQL 15 or higher
- Docker and Docker Compose (optional)

## 🚀 Quick Start

### Using Docker Compose (Recommended)

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/gosuomisf.git
   cd gosuomisf
   ```

2. **Start the services**
   ```bash
   docker-compose up -d
   ```

3. **The API will be available at**
   ```
   http://localhost:8088
   ```

### Manual Installation

1. **Clone and build**
   ```bash
   git clone https://github.com/yourusername/gosuomisf.git
   cd gosuomisf
   go mod download
   go build
   ```

2. **Set up environment variables**
   ```bash
   cp .env.example .env
   # Edit .env with your database credentials
   ```

3. **Set up PostgreSQL database**
   ```bash
   psql -U postgres -c "CREATE DATABASE suomisf;"
   # Import the sample data
   psql -U postgres -d suomisf < suomisf.sql
   ```

4. **Run the application**
   ```bash
   ./gosuomisf
   ```

## 🔧 Configuration

The application uses environment variables for configuration. Create a `.env` file:

```env
# Database
DB_HOST=localhost
DB_PORT=5432
DB_USER=mep
DB_PASSWORD=password
DB_NAME=suomisf

# JWT
JWT_SECRET=your-secret-key-here

# Server
PORT=8088
GIN_MODE=debug
```

## 📡 API Endpoints

### Authentication
- `POST /api/login` - User login
- `POST /api/register` - User registration
- `POST /api/refresh` - Refresh access token

### Works (Books & Literature)
- `GET /api/works` - List works with pagination, search, and filtering
- `GET /api/works/{workId}` - Get specific work with full details
- `GET /api/works/{workId}/awards` - Get awards for a specific work

### People (Authors & Contributors)
- `GET /api/people` - List people with pagination and search
- `GET /api/people/{personId}` - Get specific person details

### Editions (Book Editions)
- `GET /api/editions` - List editions with pagination and search
- `GET /api/editions/{editionId}` - Get specific edition details

### Short Stories
- `GET /api/shorts` - List short stories with pagination and search
- `GET /api/shorts/{shortId}` - Get specific short story details

### Tags (Categories & Genres)
- `GET /api/tags` - List tags with pagination and search
- `GET /api/tags/{tagId}` - Get specific tag details

### Other
- `GET /api/frontpagedata` - Get summary statistics for dashboard

## 🔍 Query Parameters

All list endpoints support the following query parameters:

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `page` | integer | 1 | Page number for pagination |
| `pageSize` | integer | 20 | Number of items per page |
| `search` | string | - | Search term for filtering results |
| `sort` | string | id | Field to sort by (varies by endpoint) |
| `order` | string | asc | Sort order: "asc" or "desc" |

### Example API Calls

```bash
# Get first page of works
curl "http://localhost:8088/api/works?page=1&pageSize=10"

# Search for works containing "science fiction"
curl "http://localhost:8088/api/works?search=science%20fiction"

# Get works sorted by publication year (descending)
curl "http://localhost:8088/api/works?sort=year&order=desc"

# Get a specific work with foreign key resolution
curl "http://localhost:8088/api/works/1"
```

## 🔗 Foreign Key Resolution

One of the key features of this API is automatic foreign key resolution. Instead of returning just numeric IDs, the API resolves foreign keys to human-readable values:

**Works Example:**
```json
{
  "id": 1,
  "title": "Example Novel",
  "type_id": 1,
  "type": "Romaani",           // ← Resolved from worktype table
  "language_id": 1,
  "language": "englanti",      // ← Resolved from language table
  "bookseries_id": 215,
  "bookseries_name": "Example Series" // ← Resolved from bookseries table
}
```

**Tags Example:**
```json
{
  "id": 453,
  "name": "Cyberpunk",
  "type_id": 1,
  "type": "Alagenre"          // ← Resolved from tagtype table
}
```

## 🧪 Testing

Run the test suite:

```bash
# Run all tests
go test ./...

# Run tests with coverage
go test -cover ./...

# Run tests for a specific package
go test ./internal/handlers
```

## 🐳 Docker Development

For development with live reload:

```bash
# Install Air for live reloading
go install github.com/cosmtrek/air@latest

# Run with live reload
air
```

## � Security

This application implements several security best practices:

### Docker Security
- **Distroless base image**: Uses `gcr.io/distroless/static-debian12:nonroot` to minimize attack surface
- **Non-root user**: Runs as unprivileged user for enhanced security
- **Static binary**: Compiled with security flags (`-w -s -extldflags "-static"`)
- **Multi-stage build**: Reduces final image size and removes build dependencies

### Authentication Security
- **JWT tokens**: Secure token-based authentication
- **Password hashing**: Uses bcrypt for secure password storage
- **HTTPS ready**: Configured for TLS termination at reverse proxy level

### Database Security
- **Parameterized queries**: All database queries use parameter binding to prevent SQL injection
- **Connection pooling**: Efficient and secure database connection management
- **Environment variables**: Sensitive configuration stored in environment variables

## �📊 Database Schema

The application uses the original SuomiSF database schema with tables for:

- **work** - Books, novels, collections
- **worktype** - Types of works (novel, collection, etc.)
- **language** - Languages
- **bookseries** - Book series information
- **tag** - Tags and categories
- **tagtype** - Types of tags (genre, theme, etc.)
- **person** - Authors and contributors
- **edition** - Book editions and publications
- **shortstory** - Short stories and novellas

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Original SuomiSF project and database schema
- Finnish Science Fiction & Fantasy community
- Go community for excellent libraries and tools

## 📞 Support

If you have any questions or issues, please:

1. Check the [Issues](https://github.com/yourusername/gosuomisf/issues) page
2. Create a new issue if your problem isn't already reported
3. Provide as much detail as possible including error messages and steps to reproduce

---

**Note**: This is a Go rewrite of the original Python/Flask SuomiSF project, designed to provide better performance and easier deployment while maintaining full compatibility with the existing database schema.
- **Environment**: godotenv

## Project Structure

```
├── main.go                 # Application entry point
├── internal/
│   ├── api/               # API router and middleware
│   ├── auth/              # Authentication and JWT utilities
│   ├── config/            # Configuration management
│   ├── database/          # Database connection and utilities
│   ├── handlers/          # HTTP request handlers
│   └── models/            # Data models and structs
├── migrations/            # Database migration scripts
├── .env                   # Environment variables
├── go.mod                 # Go module dependencies
├── Dockerfile             # Docker configuration
├── docker-compose.yml     # Docker Compose setup
├── Makefile              # Build and development commands
└── openapi.yaml          # API specification
```

## Quick Start

### Prerequisites
- Go 1.22 or later
- MySQL 8.0 or later
- Make (optional, for using Makefile commands)

### Installation

1. **Clone and setup dependencies**:
   ```bash
   git clone <repository-url>
   cd gosuomisf
   make install-deps
   ```

2. **Set up the database**:
   ```bash
   # Create database
   mysql -u root -p -e "CREATE DATABASE IF NOT EXISTS suomisf;"

   # Run migrations
   make migrate
   ```

3. **Configure environment**:
   Update `.env` file with your database connection details and JWT secret.

4. **Run the application**:
   ```bash
   make run
   ```

The API will be available at `http://localhost:8080/api`

### Using Docker

1. **Start with Docker Compose**:
   ```bash
   docker-compose up -d
   ```

This will start:
- API server on port 8080
- MySQL database on port 3306
- Adminer (database admin) on port 8081

## Development

### Available Make Commands

- `make build` - Build the application
- `make run` - Build and run the application
- `make dev` - Run with hot reload (requires air)
- `make test` - Run tests
- `make migrate` - Run database migrations
- `make fmt` - Format code
- `make clean` - Clean build artifacts

### Install development tools

```bash
make install-dev-tools
```

### Hot Reload Development

Install air for hot reload:
```bash
go install github.com/cosmtrek/air@latest
```

Then run:
```bash
make dev
```

## Environment Variables

Create a `.env` file with the following variables:

```env
# Environment
ENVIRONMENT=development

# Database
DATABASE_URL=root:password@tcp(localhost:3306)/suomisf?parseTime=true

# JWT
JWT_SECRET=your-secret-key-change-in-production
JWT_EXPIRY_HOURS=24
REFRESH_EXPIRY_HOURS=168

# Server
PORT=8080
```

## Database Schema

The application uses the following main tables:
- `users` - User accounts and authentication
- `works` - Literary works (books, novels, etc.)
- `people` - Authors and other persons
- `editions` - Published editions of works
- `shorts` - Short stories
- `tags` - Classification tags
- `awards` - Awards for works

## API Documentation

The API follows the OpenAPI 3.0 specification defined in `openapi.yaml`. Key features:

- **Authentication**: Bearer token authentication for protected endpoints
- **Pagination**: Consistent pagination across all list endpoints
- **Error Handling**: Standardized error responses
- **Search**: Text search capabilities on relevant fields
- **Sorting**: Configurable sorting on multiple fields

## Authentication Flow

1. **Register**: `POST /api/register` with username, email, and password
2. **Login**: `POST /api/login` with username and password
3. **Receive tokens**: Get access token (24h) and refresh token (7 days)
4. **Use API**: Include `Authorization: Bearer <access_token>` header
5. **Refresh**: Use `POST /api/refresh` with refresh token when access token expires

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Run tests: `make test`
5. Format code: `make fmt`
6. Submit a pull request

## License

This project is licensed under the MIT License.
