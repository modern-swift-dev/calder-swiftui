# Override with a shell-quoted file list to check only changed Swift files.
SWIFT_FILES ?= .

SHELL := /bin/bash

SCHEME ?= Calder-Package
# iOS runs on the runtime the snapshot baselines were recorded on (Xcode 27.2 with iOS 27.0). The other platforms
# have no snapshots and use the newest installed 27.x runtime. Each test target creates its simulator when it doesn't
# exist; override a *_DESTINATION (for example `id=<udid>`) or a *_RUNTIME to use another device or runtime.
IOS_RUNTIME ?= 27.0
OTHER_RUNTIME ?= 27
IOS_DESTINATION ?= id=$$(bash Scripts/ensure-simulator.sh 'iPhone 17 Pro' iOS $(IOS_RUNTIME))
TVOS_DESTINATION ?= id=$$(bash Scripts/ensure-simulator.sh 'Apple TV 4K (3rd generation)' tvOS $(OTHER_RUNTIME))
WATCHOS_DESTINATION ?= id=$$(bash Scripts/ensure-simulator.sh 'Apple Watch Series 12 (46mm)' watchOS $(OTHER_RUNTIME))
VISIONOS_DESTINATION ?= id=$$(bash Scripts/ensure-simulator.sh 'Apple Vision Pro' visionOS $(OTHER_RUNTIME))

.PHONY: setup lint format documentation test test-macos test-ios test-tvos test-watchos test-visionos

setup:
	brew bundle install
	mint bootstrap
	lefthook install

lint: lint-workflows
	mint run --no-install nicklockwood/SwiftFormat $(SWIFT_FILES) --config .swiftformat --lint --quiet
	mint run --no-install realm/SwiftLint lint --config .swiftlint.yml --quiet --force-exclude $(SWIFT_FILES)

format:
	mint run --no-install nicklockwood/SwiftFormat $(SWIFT_FILES) --config .swiftformat --quiet
	mint run --no-install realm/SwiftLint lint --config .swiftlint.yml --fix --quiet --force-exclude $(SWIFT_FILES)

documentation:
	bash Scripts/build-documentation.sh

test-macos: 
	set -o pipefail && \
	TZ=UTC swift test | mint run --no-install cpisciotta/xcbeautify -q

test-ios:
	set -o pipefail && \
	TEST_RUNNER_TZ=UTC xcodebuild test \
		-scheme "$(SCHEME)" \
		-destination "$(IOS_DESTINATION)" | mint run --no-install cpisciotta/xcbeautify -q

test: test-macos test-ios test-tvos test-watchos test-visionos

test-tvos:
	set -o pipefail && \
	TEST_RUNNER_TZ=UTC xcodebuild test \
		-scheme "$(SCHEME)" \
		-destination "$(TVOS_DESTINATION)" | mint run --no-install cpisciotta/xcbeautify -q

test-watchos:
	set -o pipefail && \
	TEST_RUNNER_TZ=UTC xcodebuild test \
		-scheme "$(SCHEME)" \
		-destination "$(WATCHOS_DESTINATION)" | mint run --no-install cpisciotta/xcbeautify -q

test-visionos:
	set -o pipefail && \
	TEST_RUNNER_TZ=UTC xcodebuild test \
		-scheme "$(SCHEME)" \
		-destination "$(VISIONOS_DESTINATION)" | mint run --no-install cpisciotta/xcbeautify -q

.PHONY: lint-workflows

lint-workflows:
	actionlint
