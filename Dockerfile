# Build stage
FROM golang:1.23.3-alpine AS builder
WORKDIR /app

# Install required tools for your Makefile
RUN apk add --no-cache make curl nodejs npm

# Install templ
RUN go install github.com/a-h/templ/cmd/templ@latest

# Copy Go dependencies first
COPY go.mod go.sum ./
RUN go mod download

# Copy everything needed for the build
COPY . .

# Use your Makefile to build everything
RUN make assets/install
RUN make build/api

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