# Build stage
FROM golang:1.24-alpine AS builder

# Install security updates and build dependencies
RUN apk update && apk upgrade && apk add --no-cache git ca-certificates tzdata && \
    apk add --no-cache --update && \
    rm -rf /var/cache/apk/*

WORKDIR /app

# Copy go mod files first for better layer caching
COPY go.mod go.sum ./

# Download dependencies
RUN go mod download && go mod verify

# Copy source code
COPY . .

# Build the application with security flags
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build \
    -ldflags='-w -s -extldflags "-static"' \
    -a -installsuffix cgo \
    -o main .

# Test stage - for running tests
FROM golang:1.24-alpine AS test

# Install git for go modules
RUN apk add --no-cache git

WORKDIR /app

# Copy go mod files
COPY go.mod go.sum ./

# Download dependencies
RUN go mod download

# Copy source code
COPY . .

# Set environment for testing
ENV ENVIRONMENT=test

# Command will be overridden by docker-compose
CMD ["go", "test", "./...", "-v"]

# Final stage - use distroless for security
FROM gcr.io/distroless/static-debian12:nonroot

# Copy timezone data and certificates from builder
COPY --from=builder /usr/share/zoneinfo /usr/share/zoneinfo
COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/

# Copy the binary from builder stage
COPY --from=builder /app/main /app/main

# Use non-root user (distroless provides this)
USER nonroot:nonroot

# Expose port
EXPOSE 5050

# Run the application
ENTRYPOINT ["/app/main"]
