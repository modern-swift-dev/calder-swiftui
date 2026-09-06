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

`make test-all` runs all supported Apple platform tests.

## Documentation

The [central documentation repository](https://github.com/modern-swift-dev/docs) owns Astro, the shared theme, and website/API generation. It builds from `main` daily and on manual runs. Edit page Markdown in `Documentation/Site/` and keep DocC catalogs beside the module sources. See the [docs README](https://github.com/modern-swift-dev/docs/blob/main/README.md) for local build and preview commands. Do not commit generated HTML to this repository.

## Build the release documentation archive

```sh
make documentation
```

The command builds all nine DocC archives and writes `.build/documentation/Calder-Documentation.zip`. This archive is separate from the Pages site.

## Publish a release

The release workflow accepts semantic-version tags without a `v` prefix, such as `1.0.0`. It runs the documentation build and attaches `Calder-Documentation.zip` to the GitHub release.
