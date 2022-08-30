FROM golang:1.19 as testing

RUN apt-get update && apt-get upgrade -y

RUN curl -sSfL https://raw.githubusercontent.com/golangci/golangci-lint/master/install.sh | sh -s -- -b $(go env GOPATH)/bin v1.49.0

RUN go install github.com/google/wire/cmd/wire@latest
RUN go install github.com/axw/gocov/gocov@latest
RUN go install github.com/AlekSi/gocov-xml@latest
RUN go install github.com/matm/gocov-html@latest

WORKDIR /go/src/github.com/dqfan2012/go-starter-project/
COPY . .
RUN mkdir -m 777 /.cache

FROM testing as builder
RUN CGO_ENABLED=0 go build -ldflags '-s -w' -o go-starter-project

FROM scratch

WORKDIR /
COPY --from=builder /go/src/github.com/wpengine/dqfan2012/go-starter-project .
ENTRYPOINT ["/go-starter-project"]
