# Build stage
FROM golang:1.23.3-alpine AS builder
WORKDIR /app

# Install required tools for your Makefile
RUN apk add --no-cache make curl nodejs npm

# Install pinned templ and sqlc versions
RUN go install github.com/a-h/templ/cmd/templ@v0.3.943
RUN go install github.com/sqlc-dev/sqlc/cmd/sqlc@v1.30.0

# Copy Go dependencies first
COPY go.mod go.sum ./
RUN go mod download

# Copy everything needed for the build
COPY . .

# Use your Makefile to build everything
RUN make assets/install
ARG VERSION=development
RUN make build/api VERSION=${VERSION}

# Final stage
FROM scratch

# Copy SSL certificates for HTTPS support
COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/

# Copy the binary from builder (with embedded static files)
COPY --from=builder /app/bin/api /api

# Copy required template files (if not embedded)
COPY --from=builder /app/templates /templates
COPY --from=builder /app/internal/mailer/templates /internal/mailer/templates

# Command to run
ENTRYPOINT ["/api"]