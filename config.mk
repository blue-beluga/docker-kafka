# encoding: UTF-8

GIT_REVISION=$(shell git rev-parse --short HEAD)

REGISTRY = docker.io
FROM = bluebeluga/jdk:8
REPOSITORY = bluebeluga/kafka

PUSH_REGISTRIES = $(REGISTRY)
