# Build stage
FROM golang:1.23.3-alpine AS builder

WORKDIR /app

# Install required build tools
RUN apk add --no-cache make tzdata

# Install templ
RUN go install github.com/a-h/templ/cmd/templ@latest

# Copy only the files needed for downloading dependencies first
COPY go.mod go.sum ./
RUN go mod download

# Copy the rest of the source code
COPY . .

# Build the binary using the existing Makefile target
RUN make build/api

# Final stage
FROM scratch

# Copy SSL certificates for HTTPS support
COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/

# Copy the binary from builder
COPY --from=builder /app/bin/api /api

# Copy required template files
COPY --from=builder /app/templates /templates
COPY --from=builder /app/internal/mailer/templates /internal/mailer/templates

# Command to run
ENTRYPOINT ["/api"]
