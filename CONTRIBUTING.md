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

## Build the documentation site

Install the website dependencies and build the local `docs/` directory:

```sh
make site-setup
make site-build
make site-check
make site-preview
```

The preview server runs at `http://127.0.0.1:4321/calder-swiftui/`. `make site-build` replaces the ignored `docs/` directory with the Astro site and static API documentation for all nine products.

The `Deploy Pages` workflow runs for pull requests and pushes to `main`. Pull requests validate the build without deploying. Pushes deploy the generated site through a GitHub Pages artifact. To publish documentation between releases, run that workflow manually in GitHub Actions. Manual runs always check out `main`, regardless of the ref selected in the workflow interface, and do not read GitHub release data.

## Build the release documentation archive

```sh
make documentation
```

The command builds all nine DocC archives and writes `.build/documentation/Calder-Documentation.zip`. This archive is separate from the Pages site.

## Publish a release

The release workflow accepts semantic-version tags without a `v` prefix, such as `1.0.0`. It runs the documentation build and attaches `Calder-Documentation.zip` to the GitHub release.
