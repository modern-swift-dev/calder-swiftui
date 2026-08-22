#if canImport(Darwin)
#if !os(watchOS)
#if os(iOS) || targetEnvironment(macCatalyst) || os(tvOS) || os(visionOS)
import UIKit
#endif

#if os(macOS) && !targetEnvironment(macCatalyst)
import AppKit
#endif

/// A protocol defining the common layout anchors and dimensions available for auto layout.
/// Types conforming to `Pinnable` can be used as reference guides for creating constraints.
@MainActor public protocol Pinnable {
    /// The layout anchor for the leading edge of the object.
    var leadingAnchor: NSLayoutXAxisAnchor { get }
    /// The layout anchor for the trailing edge of the object.
    var trailingAnchor: NSLayoutXAxisAnchor { get }
    /// The layout anchor for the top edge of the object.
    var topAnchor: NSLayoutYAxisAnchor { get }
    /// The layout anchor for the bottom edge of the object.
    var bottomAnchor: NSLayoutYAxisAnchor { get }
    /// The layout anchor for the width of the object.
    var widthAnchor: NSLayoutDimension { get }
    /// The layout anchor for the height of the object.
    var heightAnchor: NSLayoutDimension { get }
    /// The layout anchor for the horizontal center of the object.
    var centerXAnchor: NSLayoutXAxisAnchor { get }
    /// The layout anchor for the vertical center of the object.
    var centerYAnchor: NSLayoutYAxisAnchor { get }
}

#if os(iOS) || targetEnvironment(macCatalyst) || os(tvOS) || os(visionOS)
/// Conforms `UIView` to the `Pinnable` protocol, allowing UIViews to be used as layout guides.
extension UIView: Pinnable {}
/// Conforms `UILayoutGuide` to the `Pinnable` protocol, allowing UILayoutGuides to be used as layout guides.
extension UILayoutGuide: Pinnable {}
#endif
#endif

#endif
