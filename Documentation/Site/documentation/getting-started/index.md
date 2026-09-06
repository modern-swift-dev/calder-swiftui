---
title: "Getting started with Calder"
description: "Add Calder from main and select the products your Swift target imports."
---

Getting started

# Add the package, then choose products.

Calder is split into nine products. A target should depend only on the modules it imports.

## 1. Check platform requirements

Calder uses Swift 6 and supports iOS 18, macOS 15, tvOS 18, watchOS 11, and visionOS 2.

## 2. Add the package

Until the first version is tagged, use the current `main` branch in your package manifest.

Package.swift

```swift
dependencies: [
    .package(
        url: "https://github.com/modern-swift-dev/calder-swiftui.git",
        branch: "main"
    )
]
```

## 3. Select products

Add a product for each Calder module imported by your target. This example uses the SwiftUI and theme modules.

Package.swift target

```swift
.target(
    name: "MyApp",
    dependencies: [
        .product(name: "CalderSwiftUI", package: "calder-swiftui"),
        .product(name: "CalderTheme", package: "calder-swiftui")
    ]
)
```

## 4. Open the API reference

The [documentation index](/docs/calder-swiftui/documentation/) links every product's generated DocC reference. The site publishes documentation from the current `main` branch.

For package internals and contribution instructions, [open the repository ↗](https://github.com/modern-swift-dev/calder-swiftui).
