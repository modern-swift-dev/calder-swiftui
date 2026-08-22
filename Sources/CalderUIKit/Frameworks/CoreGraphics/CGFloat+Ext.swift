#if canImport(Darwin)
#if canImport(CoreGraphics)
import CoreGraphics
import Foundation

#if canImport(UIKit)
import UIKit
#endif

#if canImport(SwiftUI)
import SwiftUI
#endif

// MARK: Computed Properties
public extension CGFloat {
    /// Returns a `CGSize` with both width and height equal to the `CGFloat` value.
    var size: CGSize {
        CGSize(self, self)
    }

    /// Returns a `CGPoint` with both x and y coordinates equal to the `CGFloat` value.
    var point: CGPoint {
        CGPoint(self, self)
    }

    /// Returns a `CGRect` with origin at `.zero` and width/height equal to the `CGFloat` value.
    var rect: CGRect {
        CGRect(origin: .zero, size: size)
    }

    #if canImport(SwiftUI)
    /// Returns a `EdgeInsets` with all insets equal to the `CGFloat` value.
    var edgeInset: EdgeInsets {
        EdgeInsets(top: self, leading: self, bottom: self, trailing: self)
    }
    #endif

    #if canImport(UIKit)
    /// Returns a `UIEdgeInsets` with all insets equal to the `CGFloat` value.
    var uiEdgeInset: UIEdgeInsets {
        UIEdgeInsets(top: self, left: self, bottom: self, right: self)
    }

    /// Returns a `NSDirectionalEdgeInsets` with all insets equal to the `CGFloat` value.
    var directionalEdgeInset: NSDirectionalEdgeInsets {
        NSDirectionalEdgeInsets(top: self, leading: self, bottom: self, trailing: self)
    }
    #endif

}

// MARK: - Debugging
public extension CGFloat {
    /// A debug description of the `CGFloat` value.
    var debugDescription: String {
        "CGFloat(\(self))"
    }
}
#endif

#endif
