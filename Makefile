.PHONY: help all artifacts build build-local build-test clean image-name lint lint-go run start stop test tidy vendor wire
BIN             := go-starter-project
PKG             := github.com/dqfan2012/$(BIN)
LOCAL_VERSION   := $(shell git describe --tags --always --dirty)
IMAGE_NAME      ?= $(BIN):$(LOCAL_VERSION)
TEST_IMAGE_NAME ?= $(BIN)-test:$(LOCAL_VERSION)
GO_VERSION      := 1.20
GO_CONTAINER    := golang:$(GO_VERSION)

all: vendor lint build

artifacts:
	mkdir -p ./artifacts/

build:  ## Build the docker container image
	docker build -f build/Dockerfile -t $(IMAGE_NAME) .

build-test:  ## Build the test docker container image for testing
	docker build -f build/tools/Dockerfile --target testing -t $(TEST_IMAGE_NAME) .

clean:  ## Clean any intermediate temp files
	rm -rf vendor/
	rm -rf artifacts/

dep-tidy: build-test  ## Remove unused dependencies and add missing dependencies
	docker run --rm -u `id -u` $(TEST_IMAGE_NAME) sh -c "go clean -modcache && go mod tidy -go=$(GO_VERSION)"

gofumpt: build-test  ## Enforce a stricter format than gofmt
	docker run --rm -u `id -u` $(TEST_IMAGE_NAME) sh -c "gofumpt -l -w ."

image-name:  ## Print the docker image name
	@echo "image: $(IMAGE_NAME)"

lint: gofumpt lint-go ## Run all linters

lint-go: build-test  ## Lint the go source code
	docker run --rm $(TEST_IMAGE_NAME) sh -c 'golangci-lint run --fix'

run:
	docker-compose up

start:
	docker-compose up --build

stop:
	docker-compose down

test: build-test  ## Run unit tests
	docker run --rm -u `id -u` $(TEST_IMAGE_NAME) bash -c "gocov test ./... | gocov report"

update-dep: build-test  ## Update specific dependencies. Example usage: make update-dep dependency=golang.org/x/crypto/ ...
	docker run --rm -u `id -u` $(TEST_IMAGE_NAME) sh -c "go get -u $(dependency)"

vendor:  ## Update vendor packages and lock file
	docker run --rm --volume `pwd`:/go/src/$(PKG) --workdir /go/src/$(PKG) $(GO_CONTAINER) sh -c "go mod vendor"

wire: build-test  ## Regenerate wire sources
	docker run --rm -v `pwd`:/go/src/$(PKG) -w /go/src/$(PKG) $(TEST_IMAGE_NAME) wire
