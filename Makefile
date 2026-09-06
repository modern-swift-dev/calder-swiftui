SHELL := /bin/bash

SCHEME ?= Calder-Package
IOS_DESTINATION ?= platform=iOS Simulator,name=iPhone 17 Pro,OS=26.5
TVOS_DESTINATION ?= platform=tvOS Simulator,name=Apple TV 4K (3rd generation),OS=26.5
WATCHOS_DESTINATION ?= platform=watchOS Simulator,name=Apple Watch Series 11 (46mm),OS=26.5
VISIONOS_DESTINATION ?= platform=visionOS Simulator,name=Apple Vision Pro,OS=26.5

.PHONY: setup lint format documentation test test-macos test-ios test-tvos test-watchos test-visionos

setup:
	brew bundle install
	mint bootstrap
	lefthook install

lint:
	mint run --no-install realm/SwiftLint --config .swiftlint.yml --quiet

format:
	mint run --no-install nicklockwood/SwiftFormat . --config .swiftformat --quiet
	mint run --no-install realm/SwiftLint --config .swiftlint.yml --fix --quiet

documentation:
	bash Scripts/build-documentation.sh

test-macos: 
	set -o pipefail && \
	swift test | mint run --no-install cpisciotta/xcbeautify -q

test-ios:
	set -o pipefail && \
	TEST_RUNNER_TZ=UTC xcodebuild test \
		-scheme "$(SCHEME)" \
		-destination "$(IOS_DESTINATION)" | mint run --no-install cpisciotta/xcbeautify -q

test: test-macos test-ios test-tvos test-watchos test-visionos

test-tvos:
	set -o pipefail && \
	xcodebuild test \
		-scheme "$(SCHEME)" \
		-destination "$(TVOS_DESTINATION)" | mint run --no-install cpisciotta/xcbeautify -q

test-watchos:
	set -o pipefail && \
	xcodebuild test \
		-scheme "$(SCHEME)" \
		-destination "$(WATCHOS_DESTINATION)" | mint run --no-install cpisciotta/xcbeautify -q

test-visionos:
	set -o pipefail && \
	xcodebuild test \
		-scheme "$(SCHEME)" \
		-destination "$(VISIONOS_DESTINATION)" | mint run --no-install cpisciotta/xcbeautify -q
