FROM golang:1.13-alpine AS compile-image
ENV GO111MODULE=on
WORKDIR /app
COPY go.mod .
RUN go mod download
COPY . .
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build

FROM scratch as build-image
COPY --from=compile-image /app/code /app/
WORKDIR /app
ENTRYPOINT ["./code"]