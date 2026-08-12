# FROM golang:1.25
# WORKDIR /app
# COPY go.mod go.sum ./
# RUN go mod download
# COPY . .
# RUN go build -o server ./cmd/server
# CMD ["./server"]


# FROM golang:1.25 AS builder

# WORKDIR /app

# COPY go.mod go.sum ./
# RUN go mod download

# COPY . .

# RUN CGO_ENABLED=0 GOOS=linux go build -o server ./cmd/server




FROM alpine:3.22

WORKDIR /app

COPY server .

EXPOSE 8080

CMD ["./server"]