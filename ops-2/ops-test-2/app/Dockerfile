FROM golang:1.22 AS builder

WORKDIR /app
# Copy specific files first for better caching
COPY go.mod go.sum ./
RUN go mod download

# Copy source code and build
COPY *.go ./
RUN CGO_ENABLED=0 GOOS=linux go build -o server .

# --- final image ---
FROM alpine:3.21
RUN apk add --no-cache ca-certificates

WORKDIR /app
COPY --from=builder /app/server .

RUN addgroup -S appgroup && adduser -S appuser -G appgroup
USER appuser

EXPOSE 8080
ENTRYPOINT ["./server"]
