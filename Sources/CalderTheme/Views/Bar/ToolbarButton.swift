#if canImport(SwiftUI)
import CalderSwiftUI
import CalderUIKit
import Foundation
import SFSafeSymbols
import SwiftUI

/// A custom `ToolbarContent` that displays a button in the navigation bar with a specific style.
/// This button applies the `BarButtonStyle` automatically.
public struct ToolbarButton<Label: View>: ToolbarContent {

    private var label: () -> Label
    private var action: @Sendable @MainActor () -> Void
    private var placement: ToolbarItemPlacement
    private var enabled: Bool
    private let variant: BarButtonStyle.Variant

    /// Initializes a `ToolbarButton` with a custom label view, an action, and a placement.
    ///
    /// - Parameters:
    ///   - placement: The placement of the toolbar item within the navigation bar.
    ///   - action: The action to perform when the button is tapped.
    ///   - label: A `ViewBuilder` that creates the content of the button's label.
    public init(
        placement: ToolbarItemPlacement,
        variant: BarButtonStyle.Variant = .regular,
        enabled: Bool = true,
        action: @escaping @Sendable @MainActor () -> Void,
        @ViewBuilder label: @escaping () -> Label
    ) {
        self.action = action
        self.enabled = enabled
        self.label = label
        self.placement = placement
        self.variant = variant
    }

    @ToolbarContentBuilder public var body: some ToolbarContent {
        ToolbarItem(placement: placement) {
            Button(action: {
                action()
            }, label: label)
                .buttonStyle(BarButtonStyle(variant: variant))
                .disabled(!enabled)
                .fixedSize(horizontal: true, vertical: true)
        }
        .disableSharedbackground(disable: variant.sharedBackgroundDisabled)
    }
}

public extension ToolbarButton where Label == Text {
    /// Initializes a `ToolbarButton` with a plain text label.
    ///
    /// - Parameters:
    ///   - placement: The placement of the toolbar item within the navigation bar.
    ///   - action: The action to perform when the button is tapped.
    ///   - text: The string to display as the button's label.
    init(
        placement: ToolbarItemPlacement,
        variant: BarButtonStyle.Variant = .regular,
        text: String,
        enabled: Bool = true,
        action: @escaping @Sendable @MainActor () -> Void
    ) {
        self.placement = placement
        self.variant = variant
        self.enabled = enabled
        self.action = action
        self.label = {
            Text(text)
        }
    }
}

public extension ToolbarButton where Label == Image {
    /// Initializes a `ToolbarButton` with a custom image as its label.
    ///
    /// - Parameters:
    ///   - placement: The placement of the toolbar item within the navigation bar.
    ///   - action: The action to perform when the button is tapped.
    ///   - icon: The `Image` to display as the button's label.
    init(
        placement: ToolbarItemPlacement,
        variant: BarButtonStyle.Variant = .regular,
        icon: Image,
        enabled: Bool = true,
        action: @escaping @Sendable @MainActor () -> Void
    ) {
        self.placement = placement
        self.variant = variant
        self.enabled = enabled
        self.action = action
        self.label = {
            icon
        }
    }

    /// Initializes a `ToolbarButton` with an SF Symbols icon as its label.
    ///
    /// - Parameters:
    ///   - placement: The placement of the toolbar item within the navigation bar.
    ///   - action: The action to perform when the button is tapped.
    ///   - symbol: The `SFSymbol` to display as the button's label.
    init(
        placement: ToolbarItemPlacement,
        variant: BarButtonStyle.Variant = .regular,
        symbol: SFSymbol,
        enabled: Bool = true,
        action: @escaping @Sendable @MainActor () -> Void
    ) {
        self.placement = placement
        self.variant = variant
        self.enabled = enabled
        self.action = action
        self.label = {
            Image(systemSymbol: symbol)
        }
    }
}

#endif

#if canImport(SwiftUI)
#if os(iOS)
import SFSafeSymbols
import SnapshotPreviews
import SwiftUI

@MainActor enum ToolbarButtonPreviews: PreviewProvider, SnapshotProvider {
    static let defaultLayout: PreviewSnapshotLayout = .device

    static var snapshots: [PreviewSnapshot] {
        PreviewSnapshot("regular") {
            PreviewContent(variant: .regular)
        }

        PreviewSnapshot("primary") {
            PreviewContent(variant: .primary)
        }

        PreviewSnapshot("secondary") {
            PreviewContent(variant: .secondary)
        }

        PreviewSnapshot("destructive") {
            PreviewContent(variant: .destructive)
        }

        PreviewSnapshot("disabled primary") {
            PreviewContent(variant: .primary, enabled: false)
        }
    }

    private struct PreviewContent: View {
        @Environment(\.theme) private var theme

        let variant: BarButtonStyle.Variant
        var enabled = true

        var body: some View {
            NavigationStack {
                VStack {
                    Spacer()
                    Text("Empty!")
                    Spacer()
                }
                .frame(maxWidth: .infinity)
                .background(theme.backgroundGradient)
                .toolbar {
                    ToolbarButton(placement: .topBarTrailing, variant: variant, symbol: .trash, enabled: enabled, action: {})
                }
            }
        }
    }
}
#endif
#endif
