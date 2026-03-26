SHELL := /bin/sh

.PHONY: build run clean

build:
	swift build -c release

run: build
	.build/release/TiltBrew

clean:
	swift package clean
