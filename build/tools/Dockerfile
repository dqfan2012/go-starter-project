FROM golang:1.20 as testing

RUN mkdir 777 /.cache

RUN apt-get update && apt-get upgrade -y

RUN go install github.com/axw/gocov/gocov@latest
RUN go install github.com/AlekSi/gocov-xml@latest
RUN go install github.com/matm/gocov-html/cmd/gocov-html@latest
RUN go install mvdan.cc/gofumpt@latest
RUN go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest

RUN go install github.com/google/wire/cmd/wire@latest
