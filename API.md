# API Documentation

This document provides detailed information about the GoSuomiSF REST API endpoints.

## Base URL

```
http://localhost:8088/api
```

## Authentication

The API uses JWT (JSON Web Tokens) for authentication. To access protected endpoints, include the JWT token in the Authorization header:

```
Authorization: Bearer <your-jwt-token>
```

### Authentication Endpoints

#### POST /api/login

Authenticate a user and receive a JWT token.

**Request Body:**
```json
{
  "username": "string",
  "password": "string"
}
```

**Response (200 OK):**
```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "refresh_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "user": {
    "id": 1,
    "username": "user@example.com",
    "name": "User Name"
  }
}
```

#### POST /api/register

Register a new user account.

**Request Body:**
```json
{
  "username": "string",
  "email": "string",
  "password": "string",
  "name": "string"
}
```

**Response (201 Created):**
```json
{
  "message": "User created successfully",
  "user": {
    "id": 1,
    "username": "user@example.com",
    "name": "User Name"
  }
}
```

#### POST /api/refresh

Refresh an expired JWT token using a refresh token.

**Request Body:**
```json
{
  "refresh_token": "string"
}
```

**Response (200 OK):**
```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "refresh_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

## Works Endpoints

### GET /api/works

Get a paginated list of works (books, novels, collections).

**Query Parameters:**
- `page` (integer, default: 1) - Page number
- `pageSize` (integer, default: 20) - Items per page
- `search` (string) - Search term for title, original title, or description
- `sort` (string) - Sort field: `id`, `title`, `year`, `type`, `language`
- `order` (string) - Sort order: `asc` or `desc`

**Example Request:**
```
GET /api/works?page=1&pageSize=10&search=science&sort=year&order=desc
```

**Response (200 OK):**
```json
{
  "data": [
    {
      "id": 1,
      "title": "Example Novel",
      "subtitle": "A Subtitle",
      "orig_title": "Original Title",
      "pubyear": 2020,
      "language_id": 1,
      "language": "englanti",
      "bookseries_id": 215,
      "bookseries_name": "Example Series",
      "bookseriesnum": "1",
      "bookseriesorder": 1,
      "type_id": 1,
      "type": "Romaani",
      "misc": "Additional info",
      "description": "Work description",
      "author_str": "Author Name"
    }
  ],
  "page": 1,
  "page_size": 10,
  "total": 6504,
  "total_pages": 651
}
```

### GET /api/works/{workId}

Get detailed information about a specific work.

**Path Parameters:**
- `workId` (integer) - The ID of the work

**Response (200 OK):**
```json
{
  "id": 1,
  "title": "Example Novel",
  "subtitle": "A Subtitle",
  "orig_title": "Original Title",
  "pubyear": 2020,
  "language_id": 1,
  "language": "englanti",
  "bookseries_id": 215,
  "bookseries_name": "Example Series",
  "bookseriesnum": "1",
  "bookseriesorder": 1,
  "type_id": 1,
  "type": "Romaani",
  "misc": "Additional info",
  "description": "Work description",
  "author_str": "Author Name"
}
```

### GET /api/works/{workId}/awards

Get awards associated with a specific work.

**Path Parameters:**
- `workId` (integer) - The ID of the work

**Response (200 OK):**
```json
[
  {
    "id": 1,
    "work_id": 1,
    "name": "Hugo Award",
    "year": 2021,
    "category": "Best Novel",
    "winner": true
  }
]
```

## Tags Endpoints

### GET /api/tags

Get a paginated list of tags (genres, themes, categories).

**Query Parameters:**
- `page` (integer, default: 1) - Page number
- `pageSize` (integer, default: 20) - Items per page
- `search` (string) - Search term for tag name or description
- `sort` (string) - Sort field: `id`, `name`, `type`
- `order` (string) - Sort order: `asc` or `desc`

**Example Request:**
```
GET /api/tags?page=1&pageSize=10&search=science&sort=name
```

**Response (200 OK):**
```json
{
  "data": [
    {
      "id": 453,
      "name": "Cyberpunk",
      "type_id": 1,
      "type": "Alagenre",
      "description": "A subgenre of science fiction"
    }
  ],
  "page": 1,
  "page_size": 10,
  "total": 150,
  "total_pages": 15
}
```

### GET /api/tags/{tagId}

Get detailed information about a specific tag.

**Path Parameters:**
- `tagId` (integer) - The ID of the tag

**Response (200 OK):**
```json
{
  "id": 453,
  "name": "Cyberpunk",
  "type_id": 1,
  "type": "Alagenre",
  "description": "A subgenre of science fiction"
}
```

## People Endpoints

### GET /api/people

Get a paginated list of people (authors, editors, translators).

**Query Parameters:**
- `page` (integer, default: 1) - Page number
- `pageSize` (integer, default: 20) - Items per page
- `search` (string) - Search term for person name
- `sort` (string) - Sort field: `id`, `name`
- `order` (string) - Sort order: `asc` or `desc`

**Response (200 OK):**
```json
{
  "data": [
    {
      "id": 1,
      "name": "Isaac Asimov",
      "alt_name": "Alternative Name",
      "first_name": "Isaac",
      "last_name": "Asimov",
      "dob": "1920-01-02T00:00:00Z",
      "dod": "1992-04-06T00:00:00Z"
    }
  ],
  "page": 1,
  "page_size": 20,
  "total": 5000,
  "total_pages": 250
}
```

### GET /api/people/{personId}

Get detailed information about a specific person.

**Path Parameters:**
- `personId` (integer) - The ID of the person

**Response (200 OK):**
```json
{
  "id": 1,
  "name": "Isaac Asimov",
  "alt_name": "Alternative Name",
  "first_name": "Isaac",
  "last_name": "Asimov",
  "dob": "1920-01-02T00:00:00Z",
  "dod": "1992-04-06T00:00:00Z"
}
```

## Editions Endpoints

### GET /api/editions

Get a paginated list of book editions.

**Query Parameters:**
- `page` (integer, default: 1) - Page number
- `pageSize` (integer, default: 20) - Items per page
- `search` (string) - Search term for edition title
- `sort` (string) - Sort field: `id`, `title`, `year`
- `order` (string) - Sort order: `asc` or `desc`

**Response (200 OK):**
```json
{
  "data": [
    {
      "id": 1,
      "title": "Foundation",
      "subtitle": "First Novel",
      "pubyear": 1951,
      "publisher": "Gnome Press",
      "isbn": "978-0553293357",
      "pages": 244
    }
  ],
  "page": 1,
  "page_size": 20,
  "total": 8000,
  "total_pages": 400
}
```

### GET /api/editions/{editionId}

Get detailed information about a specific edition.

**Path Parameters:**
- `editionId` (integer) - The ID of the edition

## Short Stories Endpoints

### GET /api/shorts

Get a paginated list of short stories.

**Query Parameters:**
- `page` (integer, default: 1) - Page number
- `pageSize` (integer, default: 20) - Items per page
- `search` (string) - Search term for story title
- `sort` (string) - Sort field: `id`, `title`, `year`
- `order` (string) - Sort order: `asc` or `desc`

### GET /api/shorts/{shortId}

Get detailed information about a specific short story.

**Path Parameters:**
- `shortId` (integer) - The ID of the short story

## Other Endpoints

### GET /api/frontpagedata

Get summary statistics for the dashboard/front page.

**Response (200 OK):**
```json
{
  "total_works": 6504,
  "total_people": 5000,
  "total_editions": 8000,
  "total_shorts": 15000,
  "total_tags": 500,
  "recent_additions": 25
}
```

## Error Responses

All endpoints may return the following error responses:

### 400 Bad Request
```json
{
  "error": "Invalid request parameters"
}
```

### 401 Unauthorized
```json
{
  "error": "Authentication required"
}
```

### 403 Forbidden
```json
{
  "error": "Insufficient permissions"
}
```

### 404 Not Found
```json
{
  "error": "Resource not found"
}
```

### 500 Internal Server Error
```json
{
  "error": "Internal server error"
}
```

## Rate Limiting

The API implements rate limiting to prevent abuse:
- **Anonymous users**: 100 requests per hour
- **Authenticated users**: 1000 requests per hour

When rate limits are exceeded, the API returns a `429 Too Many Requests` status.

## CORS

The API supports Cross-Origin Resource Sharing (CORS) for web browsers. Configure allowed origins in the environment variables.

## Pagination

All list endpoints use cursor-based pagination:
- Default page size: 20 items
- Maximum page size: 100 items
- Total count is included in responses
- Page numbers start from 1

## Sorting

Most list endpoints support sorting by various fields. The default sort order is ascending (`asc`). Use `desc` for descending order.

## Search

Search functionality varies by endpoint but generally supports:
- Case-insensitive partial matching
- Multiple field searching (title, description, etc.)
- Special characters are escaped automatically

## Foreign Key Resolution

The API automatically resolves foreign key relationships, providing both the ID and the human-readable name:

```json
{
  "type_id": 1,
  "type": "Romaani",
  "language_id": 1,
  "language": "englanti"
}
```

This makes the API responses more useful for frontend applications without requiring additional API calls.
