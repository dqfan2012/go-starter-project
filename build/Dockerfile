FROM golang:1.20 as testing

RUN apt-get update && apt-get upgrade -y

WORKDIR /go/src/github.com/dqfan2012/go-starter-project/
COPY . .
RUN mkdir -m 777 /.cache

FROM testing as builder
RUN CGO_ENABLED=0 go build -ldflags '-s -w' -o go-starter-project

FROM scratch

WORKDIR /
COPY --from=builder /go/src/github.com/wpengine/dqfan2012/go-starter-project .
ENTRYPOINT ["/go-starter-project"]
