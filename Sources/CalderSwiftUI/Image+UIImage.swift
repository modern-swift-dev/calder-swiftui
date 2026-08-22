#if canImport(SwiftUI)
import SwiftUI

#if canImport(UIKit)
import UIKit

public extension UIImage {
    /// Return a swift-ui image from this UIImage
    var asSwiftUIImage: Image {
        Image(uiImage: self)
    }
}
#endif

#if canImport(AppKit) && !targetEnvironment(macCatalyst)
import AppKit

public extension NSImage {
    /// Return a swift-ui image from this NSImage
    var asSwiftUIImage: Image {
        Image(nsImage: self)
    }
}
#endif

#endif
