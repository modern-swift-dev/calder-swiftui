#if canImport(Darwin)
import Foundation

#if os(iOS) || targetEnvironment(macCatalyst) || os(tvOS) || os(visionOS)
import UIKit
#endif

#if os(macOS) && !targetEnvironment(macCatalyst)
import AppKit
#endif

/// A struct that provides convenient methods for defining layout margins.
public struct LayoutConstraintMargin: Sendable {
    /// The top margin.
    public let top: CGFloat
    /// The bottom margin.
    public let bottom: CGFloat
    /// The leading margin.
    public let leading: CGFloat
    /// The trailing margin.
    public let trailing: CGFloat

    /// A `LayoutConstraintMargin` with all margins set to 0.
    public static let zero: LayoutConstraintMargin = .init(
        top: 0,
        leading: 0,
        bottom: 0,
        trailing: 0
    )

    /// Initializes a `LayoutConstraintMargin` with specified top, leading, bottom, and trailing values.
    /// - Parameters:
    ///   - top: The top margin.
    ///   - leading: The leading margin.
    ///   - bottom: The bottom margin.
    ///   - trailing: The trailing margin.
    public init(
        top: CGFloat,
        leading: CGFloat,
        bottom: CGFloat,
        trailing: CGFloat
    ) {
        self.top = top
        self.bottom = bottom
        self.leading = leading
        self.trailing = trailing
    }

    /// Initializes a `LayoutConstraintMargin` with a uniform vertical margin.
    /// - Parameters:
    ///   - vertical: The value for the vertical padding.
    ///   - divider: In case of padding that needs to be divided between top / bottom margin, you can increase the divider to 2. Defaults to 1.0.
    public init(vertical: CGFloat, divider: CGFloat = 1.0) {
        self.init(
            top: vertical / divider,
            leading: 0,
            bottom: vertical / divider,
            trailing: 0
        )
    }

    /// Initializes a `LayoutConstraintMargin` with a uniform horizontal margin.
    /// - Parameters:
    ///   - horizontal: The value for the horizontal padding.
    ///   - divider: In case of padding that needs to be divided between leading / trailing margin, you can increase the divider to 2. Defaults to 1.0.
    public init(horizontal: CGFloat, divider: CGFloat = 1.0) {
        self.init(
            top: 0,
            leading: horizontal / divider,
            bottom: 0,
            trailing: horizontal / divider
        )
    }

    /// Initializes a `LayoutConstraintMargin` with a uniform margin for all sides.
    /// - Parameters:
    ///   - both: The value for all side paddings.
    ///   - divider: In case of padding that needs to be divided, you can increase the divider to 2. Defaults to 1.0.
    public init(both: CGFloat, divider: CGFloat = 1.0) {
        self.init(
            top: both / divider,
            leading: both / divider,
            bottom: both / divider,
            trailing: both / divider
        )
    }

    /// Initializes a `LayoutConstraintMargin` with distinct horizontal and vertical margins.
    /// - Parameters:
    ///   - horizontal: The value for the horizontal padding.
    ///   - vertical: The value for the vertical padding.
    ///   - divider: In case of padding that needs to be divided between leading / trailing / top / bottom margin, you can increase the divider to 2. Defaults to 1.0.
    public init(horizontal: CGFloat, vertical: CGFloat, divider: CGFloat = 1.0) {
        self.init(
            top: vertical / divider,
            leading: horizontal / divider,
            bottom: vertical / divider,
            trailing: horizontal / divider
        )
    }
}

#endif
