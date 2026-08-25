#if canImport(SwiftUI)
import CalderSwiftUI
import CalderUIKit
import Foundation
import SwiftUI

/// A view modifier that wraps any view in a styled “card”:
/// applies the theme’s background, rounds its corners, and adds a subtle shadow.
///
/// `Cardify` provides a consistent visual presentation for content blocks,
/// making them stand out and organizing information within the UI.
public struct Cardify: ViewModifier {

    @Environment(\.theme) var theme
    public var horizontalPadding: CGFloat
    public var verticalPadding: CGFloat
    public var radius: CGFloat
    public var thick: Bool

    /// Initializes a new instance of `Cardify`.
    public init(
        horizontalPadding: CGFloat = .medium,
        verticalPadding: CGFloat = .medium,
        radius: CGFloat = .small,
        thick: Bool = false
    ) {
        self.horizontalPadding = horizontalPadding
        self.verticalPadding = verticalPadding
        self.radius = radius
        self.thick = thick
    }

    /// The content and behavior of the `Cardify` modifier.
    /// - Parameter content: The content view to which the modifier is applied.
    /// - Returns: A view that wraps the content in a card-like style.
    public func body(content: Content) -> some View {
        content
            .padding(.horizontal, horizontalPadding)
            .padding(.vertical, verticalPadding)
            .background(thick ? Material.thick : Material.thin)
            .contentShape(RoundedRectangle(cornerRadius: radius))
            .clipShape(RoundedRectangle(cornerRadius: radius))
            .overlay {
                RoundedRectangle(cornerRadius: radius)
                    .stroke(theme.border, lineWidth: 1)
                    .shadow(color: theme.shadow, radius: 4, x: 2, y: 2)
            }
    }
}

/// Applies a card-like style around the view:
/// uses `Cardify` to add background, rounded corners, and shadow.
public extension View {
    /// Applies a card-like style to the view.
    ///
    /// This modifier wraps the view in a styled "card," adding the theme's
    /// background, rounded corners, and a subtle shadow, as defined by `Cardify`.
    /// - Returns: A view with the card-like style applied.
    func cardify(
        horizontalPadding: CGFloat = .medium,
        verticalPadding: CGFloat = .medium,
        radius: CGFloat = .small,
        thick: Bool = false
    ) -> some View {
        modifier(
            Cardify(
                horizontalPadding: horizontalPadding,
                verticalPadding: verticalPadding,
                radius: radius,
                thick: thick
            )
        )
    }

    func cardify(
        padding: CGFloat,
        radius: CGFloat = .small,
        thick: Bool = false
    ) -> some View {
        modifier(
            Cardify(
                horizontalPadding: padding,
                verticalPadding: padding,
                radius: radius,
                thick: thick
            )
        )
    }
}

#endif

#if canImport(SwiftUI)
import CalderUIKit
import SnapshotPreviews
import SwiftUI

#if DEBUG
@MainActor enum CardifyPreviews: PreviewProvider, SnapshotProvider {
    static let defaultLayout: PreviewSnapshotLayout = .device

    static var snapshots: [PreviewSnapshot] {
        PreviewSnapshot("default") {
            VStack(alignment: .leading, spacing: .xxs) {
                Text("Card Title")
                    .font(.headline)
                Text("This is a sample card.")
                    .font(.subheadline)
            }
            .padding(.medium)
            .cardify()
        }

        PreviewSnapshot("custom") {
            Text("Custom card")
                .cardify(horizontalPadding: .large, verticalPadding: .xxs, radius: .large, thick: true)
        }
    }
}
#endif
#endif
