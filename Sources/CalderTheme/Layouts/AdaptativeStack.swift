#if canImport(SwiftUI)
import CalderUIKit
import Foundation
import SFSafeSymbols
import SnapshotPreviews
import SwiftUI

/// An adaptive stack container that switches between a `VStack` for compact horizontal size classes
/// and an `HStack` for regular horizontal size classes.
///
/// This is useful for creating layouts that dynamically adjust their orientation
/// based on the available horizontal space (e.g., iPhone portrait vs. iPhone landscape/iPad).
public struct AdaptativeStack<Content: View>: View {

    /// The horizontal alignment for the `VStack` when in a compact size class.
    public let verticalAlignment: HorizontalAlignment
    /// The spacing between views in the `VStack` when in a compact size class.
    public let verticalSpacing: CGFloat
    /// The vertical alignment for the `HStack` when in a regular size class.
    public let horizontalAlignment: VerticalAlignment
    /// The spacing between views in the `HStack` when in a regular size class.
    public let horizontalSpacing: CGFloat
    /// A `ViewBuilder` closure that provides the content of the stack. It receives the current
    /// `UserInterfaceSizeClass` to allow for adaptive content adjustments.
    public let content: (UserInterfaceSizeClass?) -> Content

    @Environment(\.horizontalSizeClass) var horizontalSizeClass

    /// Initializes a new `AdaptativeStack`.
    ///
    /// - Parameters:
    ///   - verticalAlignment: The horizontal alignment for the `VStack`. Defaults to `.leading`.
    ///   - verticalSpacing: The spacing for the `VStack`. Defaults to `.xs`.
    ///   - horizontalAlignment: The vertical alignment for the `HStack`. Defaults to `.center`.
    ///   - horizontalSpacing: The spacing for the `HStack`. Defaults to `.xs`.
    ///   - content: A `ViewBuilder` that creates the content of the stack, receiving the current
    ///              `UserInterfaceSizeClass`.
    public init(
        verticalAlignment: HorizontalAlignment = .leading,
        verticalSpacing: CGFloat = .xs,
        horizontalAlignment: VerticalAlignment = .center,
        horizontalSpacing: CGFloat = .xs,
        @ViewBuilder content: @escaping (UserInterfaceSizeClass?) -> Content
    ) {
        self.verticalAlignment = verticalAlignment
        self.verticalSpacing = verticalSpacing
        self.horizontalAlignment = horizontalAlignment
        self.horizontalSpacing = horizontalSpacing
        self.content = content
    }

    public var body: some View {
        if horizontalSizeClass == .compact {
            VStack(alignment: verticalAlignment, spacing: verticalSpacing) {
                content(horizontalSizeClass)
            }
        } else {
            HStack(alignment: horizontalAlignment, spacing: horizontalSpacing) {
                content(horizontalSizeClass)
            }
        }
    }
}

#endif

#if DEBUG
@MainActor enum AdaptativeStackPreviews: PreviewProvider, SnapshotProvider {
    static let defaultLayout: PreviewSnapshotLayout = .device

    static var snapshots: [PreviewSnapshot] {
        PreviewSnapshot("default") {
            AdaptativeStack(verticalSpacing: 0, horizontalSpacing: 0) { _ in
                Image(systemSymbol: .stopwatch)
                Image(systemSymbol: .clock)
                Image(systemSymbol: .ant)
            }
            .padding(.small)
        }
    }
}
#endif
