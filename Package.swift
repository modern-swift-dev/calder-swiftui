// swift-tools-version: 6.2

import PackageDescription

let testSwiftSettings: [SwiftSetting] = [
    .enableExperimentalFeature("StrictConcurrency"),
    .enableUpcomingFeature("MemberImportVisibility")
]

let swiftSettings: [SwiftSetting] = testSwiftSettings + [
    .enableUpcomingFeature("ExistentialAny")
]

let packageDependencies: [Package.Dependency] = [
    .package(url: "https://github.com/apple/swift-collections.git", .upToNextMajor(from: "1.1.4")),
    .package(url: "https://github.com/swiftlang/swift-docc-plugin", exact: "1.5.0"),
    .package(url: "https://github.com/modern-swift-dev/swift-snapshot-testing", exact: "2.2.1"),
    .package(url: "https://github.com/SFSafeSymbols/SFSafeSymbols.git", .upToNextMajor(from: "7.0.0")),
    .package(url: "https://github.com/modern-swift-dev/swift-markdown-ui.git", exact: "3.0.0")
]

let markdownUIDependency: [Target.Dependency] = [
    .product(name: "MarkdownUI", package: "swift-markdown-ui", condition: .when(platforms: [.iOS, .macOS, .tvOS, .macCatalyst, .watchOS, .visionOS]))
]

let sfSafeSymbolsDependency: [Target.Dependency] = [
    .product(name: "SFSafeSymbols", package: "SFSafeSymbols", condition: .when(platforms: [.iOS, .macOS, .tvOS, .macCatalyst, .watchOS, .visionOS]))
]

let snapshotTestingDependency: [Target.Dependency] = [
    .product(name: "SnapshotTesting", package: "swift-snapshot-testing", condition: .when(platforms: [.iOS, .macOS, .tvOS, .macCatalyst]))
]

let snapshotPreviewsDependency: [Target.Dependency] = [
    .product(name: "SnapshotPreviews", package: "swift-snapshot-testing")
]

let package = Package(
    name: "Calder",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v18),
        .macOS(.v15),
        .tvOS(.v18),
        .watchOS(.v11),
        .visionOS(.v2)
    ],
    products: [
        .library(name: "CalderStdLib", targets: ["CalderStdLib"]),
        .library(name: "CalderSwiftUI", targets: ["CalderSwiftUI"]),
        .library(name: "CalderTheme", targets: ["CalderTheme"]),
        .library(name: "CalderUIKit", targets: ["CalderUIKit"])
    ],
    dependencies: packageDependencies,
    targets: [
        .target(
            name: "CalderStdLib",
            swiftSettings: swiftSettings
        ),
        .target(
            name: "CalderUIKit",
            dependencies: ["CalderStdLib"],
            swiftSettings: swiftSettings
        ),
        .target(
            name: "CalderSwiftUI",
            dependencies: ["CalderStdLib", "CalderUIKit"] + snapshotPreviewsDependency,
            swiftSettings: swiftSettings
        ),
        .target(
            name: "CalderTheme",
            dependencies: [
                "CalderStdLib",
                "CalderSwiftUI",
                "CalderUIKit",
                .product(name: "Collections", package: "swift-collections")
            ] + markdownUIDependency + sfSafeSymbolsDependency + snapshotPreviewsDependency,
            swiftSettings: swiftSettings
        ),
        .testTarget(
            name: "CalderStdLibTests",
            dependencies: ["CalderStdLib"],
            swiftSettings: testSwiftSettings
        ),
        .testTarget(
            name: "CalderSwiftUITests",
            dependencies: ["CalderSwiftUI", "CalderUIKit"] + snapshotTestingDependency,
            exclude: ["__Snapshots__"],
            swiftSettings: testSwiftSettings
        ),
        .testTarget(
            name: "CalderThemeTests",
            dependencies: [
                "CalderStdLib",
                "CalderSwiftUI",
                "CalderTheme",
                "CalderUIKit"
            ] + sfSafeSymbolsDependency + snapshotTestingDependency,
            exclude: ["__Snapshots__"],
            swiftSettings: testSwiftSettings
        ),
        .testTarget(
            name: "CalderUIKitTests",
            dependencies: ["CalderStdLib", "CalderUIKit"],
            swiftSettings: testSwiftSettings
        )
    ],
    swiftLanguageModes: [.v6]
)
