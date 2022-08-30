.PHONY: help
BIN				:= go-starter-project
PKG				:= github.com/dqfan2012/$(BIN)
LOCAL_VERSION	:= $(shell git describe --tags --always --dirty)
IMAGE_NAME		?= $(BIN):$(LOCAL_VERSION)
TEST_IMAGE_NAME	?= $(BIN)-test:$(LOCAL_VERSION)
GO_CONTAINER    ?= golang:1.19

DC_LOCAL = docker-composer -f docker-compose.local.yml
DC_PROD  = docker-compose -f docker-compose.yml

all: vendor lint test-ci build

help:  ## Display help
	@awk -F ':|##' \
		'/^[^\t].+?:.*?##/ {\
			printf "\033[36m%-30s\033[0m %s\n", $$1, $$NF \
}' $(MAKEFILE_LIST) | sort

build:  ## Build the docker container image
	docker build -f build/Dockerfile -t $(IMAGE_NAME) .

build-local: image-name .env ## Build the docker container image
	${DC_LOCAL} build --build-arg IMAGE_NAME=${IMAGE_NAME}

build-test:  ## Build the docker container image for testing
	docker build -f build/Dockerfile --target testing -t $(TEST_IMAGE_NAME) .

lint: lint-go ## Run all linters

lint-go: build-test  ## Lint the go source code
	docker run --rm $(TEST_IMAGE_NAME) sh -c 'golangci-lint run'

artifacts:
	mkdir -p ./artifacts/

test: build-test  ## Run unit tests
	docker run --rm -u `id -u` $(TEST_IMAGE_NAME) bash -c "gocov test ./... | gocov report"

clean:  ## Clean out any intermediate temp files
	rm -rf vendor/
	rm -rf artifacts/

image-name:  ## Print the docker image name
	@echo "image: $(IMAGE_NAME)"

vendor:  ## Update vendor packages and lock file
	docker run --rm --env GO111MODULE=on --volume `pwd`:/go/src/$(PKG) --workdir /go/src/$(PKG) $(GO_CONTAINER) sh -c \
		"git config --global url.'https://$(GITHUB_TOKEN):x-oauth-basic@github.com/'.insteadOf 'https://github.com/' \
		&& go mod vendor"

start:
	docker-compose up --build

run:
	docker-compose up

stop:
	docker-compose down

tidy:
	go mod tidy

wire: build-test  ## Regenerate wire sources
	docker run --rm -v `pwd`:/go/src/$(PKG) -w /go/src/$(PKG) $(TEST_IMAGE_NAME) wire


