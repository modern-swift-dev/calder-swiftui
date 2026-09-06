---
title: "Calder for Swift"
description: "Focused Swift utilities for Apple application code, split into nine modules."
---

Swift utilities for Apple apps

# Take only the modules your app uses.

Calder packages UI components, asynchronous helpers, logging, image loading, and Foundation extensions as separate Swift products.

[Get started](/docs/calder-swiftui/documentation/getting-started/) · [View on GitHub ↗](https://github.com/modern-swift-dev/calder-swiftui)

A SwiftUI view

```swift
import CalderSwiftUI
import SwiftUI

struct ContentView: View {
    var body: some View {
        Text("Hello, Calder")
    }
}
```

## Nine products

Choose a foundational module, an Apple UI module, or the shared XCTest helpers. Each product has its own DocC reference.

## Apple platforms

Calder supports iOS 18, macOS 15, tvOS 18, watchOS 11, and visionOS 2 with Swift 6.

## Source and docs

The package source and DocC catalogs live in the public repository. Documentation on this site follows the current `main` branch.

[Inspect the source ↗](https://github.com/modern-swift-dev/calder-swiftui)

Start here

## [Getting started](/docs/calder-swiftui/documentation/getting-started/)

Add the main branch and select the Calder products your target imports.

[Read more →](/docs/calder-swiftui/documentation/getting-started/)

## [API documentation](/docs/calder-swiftui/documentation/)

Open the generated DocC reference for any of Calder's nine products.

[Read more →](/docs/calder-swiftui/documentation/)
