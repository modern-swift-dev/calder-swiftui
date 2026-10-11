# Contributing

## Set up the repository

Install the tools pinned by `Mintfile` and enable the pre-commit hooks:

```sh
make setup
```

## Validate a change

Format and lint Swift files before running tests:

```sh
make format
make lint
make test
```

The package declares macOS, iOS, tvOS, watchOS, and visionOS support. Run the matching platform target when a change touches platform-specific code:

```sh
make test-ios
make test-tvos
make test-watchos
make test-visionos
```

`make test` runs the macOS tests followed by every platform target above.

### Simulator runtimes and snapshot baselines

CI and the Makefile pin iOS, tvOS, watchOS, and visionOS simulator runtimes to 27.0. Install the matching runtime before running each platform's tests.

Record and verify iOS snapshots using Xcode 27.0 and the iPhone 17 Pro simulator running iOS 27.0. Newer iOS runtimes can render differently even with the same Xcode and SDK. When intentionally changing a runtime, update `.github/workflows/ci.yml`, `.github/workflows/release.yml`, and `Makefile`, and review and update any affected snapshots.

## Documentation

The [central documentation repository](https://github.com/modern-swift-dev/docs) owns Astro, the shared theme, and website/API generation. It builds from `main` daily and on manual runs. Edit page Markdown in `Documentation/Site/` and keep DocC catalogs beside the module sources. See the [docs README](https://github.com/modern-swift-dev/docs/blob/main/README.md) for local build and preview commands. Do not commit generated HTML to this repository.

## Build the release documentation archive

```sh
make documentation
```

The command builds the four DocC archives, one per library product, and writes `.build/documentation/Calder-Documentation.zip`. This archive is separate from the Pages site.

## Publish a release

Push a `MAJOR.MINOR.PATCH` tag without a `v` prefix, such as `1.0.0`, to run the release workflow in `.github/workflows/release.yml`. It runs `make documentation` and attaches `Calder-Documentation.zip` to the GitHub release for that tag. If the release does not exist yet, the workflow creates it with generated release notes.
