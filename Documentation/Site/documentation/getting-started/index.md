---
title: "Getting started with Calder"
description: "Add a Calder release and select the products your Swift target imports."
---

Getting started

# Add the package, then choose products.

Calder is split into nine products. A target should depend only on the modules it imports.

## 1. Check platform requirements

Calder uses Swift 6 and supports iOS 18, macOS 15, tvOS 18, watchOS 11, and visionOS 2.

## 2. Add the package

Add Calder to your package manifest with a version requirement.

Package.swift

```swift
dependencies: [
    .package(
        url: "https://github.com/modern-swift-dev/calder-swiftui.git",
        from: "1.1.3"
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

### Camera access for barcode scanning

`BarcodeScanner` and `BarcodeSelector` in CalderTheme use the camera. An app that shows either view must add `NSCameraUsageDescription` to its `Info.plist` with a message that explains why it needs the camera. Without that key, the system terminates the app the first time the view accesses the camera.

Info.plist

```xml
<key>NSCameraUsageDescription</key>
<string>The camera scans barcodes and QR codes.</string>
```

## 4. Open the API reference

The [documentation index](/docs/calder-swiftui/documentation/) links every product's generated DocC reference. The site publishes documentation from the current `main` branch.

For package internals and contribution instructions, [open the repository ↗](https://github.com/modern-swift-dev/calder-swiftui).
