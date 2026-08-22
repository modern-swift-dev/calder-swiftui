#if os(iOS) || targetEnvironment(macCatalyst)
import SnapshotTesting
import UIKit

@MainActor enum PreviewSnapshotConfigurations {
    static let imageOptions = ImageSnapshotOptions(precision: 1, perceptualPrecision: 0.96)

    static let compact: [NamedViewImageConfig] = [
        configuration(
            name: "iphone-portrait-light-lg-regular-srgb-ltr",
            size: CGSize(width: 320, height: 568),
            style: .light,
            horizontalSizeClass: .compact,
            verticalSizeClass: .regular
        ),
        configuration(
            name: "iphone-portrait-dark-lg-regular-srgb-ltr",
            size: CGSize(width: 320, height: 568),
            style: .dark,
            horizontalSizeClass: .compact,
            verticalSizeClass: .regular
        ),
        configuration(
            name: "iphone-landscape-light-lg-regular-srgb-ltr",
            size: compactLandscapeSize,
            style: .light,
            horizontalSizeClass: .regular,
            verticalSizeClass: .compact
        ),
        configuration(
            name: "iphone-landscape-dark-lg-regular-srgb-ltr",
            size: compactLandscapeSize,
            style: .dark,
            horizontalSizeClass: .regular,
            verticalSizeClass: .compact
        )
    ]

    private static var compactLandscapeSize: CGSize {
        #if targetEnvironment(macCatalyst)
        CGSize(width: 320, height: 568)
        #else
        CGSize(width: 568, height: 320)
        #endif
    }

    private static func configuration(
        name: String,
        size: CGSize,
        style: UIUserInterfaceStyle,
        horizontalSizeClass: UIUserInterfaceSizeClass,
        verticalSizeClass: UIUserInterfaceSizeClass
    ) -> NamedViewImageConfig {
        let traits = UITraitCollection { traits in
            traits.displayGamut = .SRGB
            traits.userInterfaceStyle = style
            traits.preferredContentSizeCategory = .large
            traits.legibilityWeight = .regular
            traits.layoutDirection = .leftToRight
            traits.accessibilityContrast = .normal
            traits.displayScale = 1
            traits.userInterfaceLevel = .base
            traits.forceTouchCapability = .unavailable
            traits.userInterfaceIdiom = .phone
            traits.horizontalSizeClass = horizontalSizeClass
            traits.verticalSizeClass = verticalSizeClass
        }

        return NamedViewImageConfig(
            name: "\(name)-\(Int(size.width))x\(Int(size.height))",
            device: ViewImageConfig(safeArea: .zero, size: size, traits: traits)
        )
    }
}
#endif
