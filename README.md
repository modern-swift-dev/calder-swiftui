# Calder for Swift

Calder contains application utilities for Swift and Apple platforms. The package separates each concern into a small Swift module and keeps Apple UI code out of the foundational targets.

## Products

- `CalderStdLib` contains the small set of Swift type helpers shared by the UI modules.
- `CalderUIKit` contains UIKit and AppKit helpers.
- `CalderSwiftUI` contains SwiftUI values, views, and extensions.
- `CalderTheme` provides reusable themed controls and layouts.

## Install

Until the first release is tagged, add the `main` branch:

```swift
dependencies: [
    .package(
        url: "https://github.com/modern-swift-dev/calder-swiftui.git",
        branch: "main"
    )
]
```

Then add only the products your target imports:

```swift
.product(name: "CalderSwiftUI", package: "calder-swiftui")
.product(name: "CalderTheme", package: "calder-swiftui")
```

## Documentation

The [Calder documentation site](https://modern-swift-dev.github.io/calder-swiftui/) publishes guides and API documentation from `main`.

- [CalderStdLib API](https://modern-swift-dev.github.io/calder-swiftui/api/calder-stdlib/documentation/calderstdlib/)
- [CalderSwiftUI API](https://modern-swift-dev.github.io/calder-swiftui/api/calder-swiftui/documentation/calderswiftui/)
- [CalderTheme API](https://modern-swift-dev.github.io/calder-swiftui/api/calder-theme/documentation/caldertheme/)
- [CalderUIKit API](https://modern-swift-dev.github.io/calder-swiftui/api/calder-uikit/documentation/calderuikit/)

The Pages workflow builds the site from `main` and deploys the generated `docs/` directory as an artifact. Run the workflow manually between releases to publish the current `main` documentation.

Release documentation is a separate archive. Build it locally with:

```sh
make documentation
```

The command creates `.build/documentation/Calder-Documentation.zip`. Tagged GitHub releases attach that archive.

## Pagination

Create `PaginatedList.DataSource(items:)` to supply a paginated list. Use
`configureAndLoad(firstPageLoader:nextPageLoader:)` to install asynchronous loaders,
`reload()` to refresh, and `next()` to request another page. The loaded `items`,
`count`, `state`, and `hasNext` are readable by client applications; use the data
source's mutation methods to insert, update, or remove items.

## Development

Install tools and hooks, then run the checks:

```sh
make setup
make format
make lint
make test
```

See [CONTRIBUTING.md](CONTRIBUTING.md) for platform tests and release details.
