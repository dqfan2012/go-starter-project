.PHONY: help
BIN				:= go-starter-project
PKG				:= github.com/dqfan2012/$(BIN)
LOCAL_VERSION	:= $(shell git describe --tags --always --dirty)
IMAGE_NAME		?= $(BIN):$(LOCAL_VERSION)
TEST_IMAGE_NAME	?= $(BIN)-test:$(LOCAL_VERSION)
#GO_CONTAINER    ?: golang:1.19

DC_LOCAL = docker-composer -f docker-compose.local.yml
DC_PROD  = docker-compose -f docker-compose.yml

help:
	@fgrep -h "##" $(MAKEFILE_LIST) | fgrep -v fgrep | sed -e 's/\\$$//' | sed -e 's/##//'

