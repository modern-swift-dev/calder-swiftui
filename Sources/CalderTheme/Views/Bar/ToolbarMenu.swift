#if canImport(SwiftUI)
#if !os(watchOS)
import CalderSwiftUI
import Foundation
import SFSafeSymbols
import SwiftUI

/// A custom `ToolbarContent` that displays a menu in the navigation bar with a specific style.
/// This menu automatically applies the `BarButtonStyle` to its label.
public struct ToolbarMenu<Content: View, Label: View>: ToolbarContent {

    private var label: () -> Label
    private var content: () -> Content
    private var placement: ToolbarItemPlacement
    private var variant: BarButtonStyle.Variant = .regular
    private var enabled: Bool

    /// Initializes a `ToolbarMenu` with a custom label view, menu content, and a placement.
    ///
    /// - Parameters:
    ///   - placement: The placement of the toolbar item within the navigation bar.
    ///   - enabled: A boolean value indicating whether the menu is enabled. Defaults to `true`.
    ///   - content: A `ViewBuilder` that creates the content of the menu. This is the view that appears when the menu is tapped.
    ///   - label: A `ViewBuilder` that creates the content of the menu's label. This is the view visible in the toolbar.
    public init(
        placement: ToolbarItemPlacement,
        enabled: Bool = true,
        variant: BarButtonStyle.Variant = .regular,
        @ViewBuilder content: @escaping () -> Content,
        @ViewBuilder label: @escaping () -> Label
    ) {
        self.content = content
        self.enabled = enabled
        self.variant = variant
        self.label = label
        self.placement = placement
    }

    @ToolbarContentBuilder public var body: some ToolbarContent {
        ToolbarItem(placement: placement) {
            Menu(content: {
                content()
            }, label: {
                Button(action: {}, label: label)
                    .buttonStyle(BarButtonStyle(variant: variant))
                    .opacity(enabled ? 1 : 0.5)
                    .disabled(!enabled)
            })
            .disabled(!enabled)
        }
        .disableSharedbackground(disable: variant.sharedBackgroundDisabled)
    }
}

public extension ToolbarMenu where Label == Text {
    /// Initializes a text menu using the original argument ordering.
    init(
        placement: ToolbarItemPlacement,
        enabled: Bool,
        variant: BarButtonStyle.Variant,
        @ViewBuilder content: @escaping () -> Content,
        text: String
    ) {
        self.init(placement: placement, variant: variant, enabled: enabled, content: content, text: text)
    }

    /// Initializes a `ToolbarMenu` with a plain text label.
    ///
    /// - Parameters:
    ///   - placement: The placement of the toolbar item within the navigation bar.
    ///   - enabled: A boolean value indicating whether the menu is enabled. Defaults to `true`.
    ///   - content: A `ViewBuilder` that creates the content of the menu.
    ///   - text: The string to display as the menu's label.
    init(
        placement: ToolbarItemPlacement,
        variant: BarButtonStyle.Variant = .regular,
        enabled: Bool = true,
        @ViewBuilder content: @escaping () -> Content,
        text: String
    ) {
        self.placement = placement
        self.enabled = enabled
        self.variant = variant
        self.content = content
        self.label = {
            Text(verbatim: text)
        }
    }
}

public extension ToolbarMenu where Label == Image {
    /// Initializes an image menu using the original argument ordering.
    init(
        placement: ToolbarItemPlacement,
        enabled: Bool,
        variant: BarButtonStyle.Variant,
        @ViewBuilder content: @escaping () -> Content,
        icon: Image
    ) {
        self.init(placement: placement, variant: variant, content: content, enabled: enabled, icon: icon)
    }

    /// Initializes a `ToolbarMenu` with a custom image as its label.
    ///
    /// - Parameters:
    ///   - placement: The placement of the toolbar item within the navigation bar.
    ///   - content: A `ViewBuilder` that creates the content of the menu.
    ///   - enabled: A boolean value indicating whether the menu is enabled. Defaults to `true`.
    ///   - icon: The `Image` to display as the menu's label.
    init(
        placement: ToolbarItemPlacement,
        variant: BarButtonStyle.Variant = .regular,
        @ViewBuilder content: @escaping () -> Content,
        enabled: Bool = true,
        icon: Image
    ) {
        self.placement = placement
        self.enabled = enabled
        self.variant = variant
        self.content = content
        self.label = {
            icon
        }
    }

    /// Initializes a symbol menu using the original argument ordering.
    init(
        placement: ToolbarItemPlacement,
        enabled: Bool,
        variant: BarButtonStyle.Variant,
        @ViewBuilder content: @escaping () -> Content,
        symbol: SFSymbol
    ) {
        self.init(placement: placement, variant: variant, content: content, enabled: enabled, symbol: symbol)
    }

    /// Initializes a `ToolbarMenu` with an SF Symbols icon as its label.
    ///
    /// - Parameters:
    ///   - placement: The placement of the toolbar item within the navigation bar.
    ///   - content: A `ViewBuilder` that creates the content of the menu.
    ///   - enabled: A boolean value indicating whether the menu is enabled. Defaults to `true`.
    ///   - symbol: The `SFSymbol` to display as the menu's label.
    init(
        placement: ToolbarItemPlacement,
        variant: BarButtonStyle.Variant = .regular,
        @ViewBuilder content: @escaping () -> Content,
        enabled: Bool = true,
        symbol: SFSymbol
    ) {
        self.placement = placement
        self.enabled = enabled
        self.variant = variant
        self.content = content
        self.label = {
            Image(systemSymbol: symbol)
        }
    }
}

#endif
#endif

#if canImport(SwiftUI)
#if os(iOS)
import SnapshotPreviews
import SwiftUI

@MainActor enum ToolbarMenuPreviews: PreviewProvider, SnapshotProvider {
    static let defaultLayout: PreviewSnapshotLayout = .device

    static var snapshots: [PreviewSnapshot] {
        PreviewSnapshot("default") {
            PreviewContent(variant: .title, enabled: true)
        }

        PreviewSnapshot("disabled primary") {
            PreviewContent(variant: .primary, enabled: false)
        }
    }

    private struct PreviewContent: View {
        @Environment(\.theme) private var theme
        let variant: BarButtonStyle.Variant
        let enabled: Bool

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
                    ToolbarMenu(
                        placement: .title,
                        enabled: enabled,
                        variant: variant,
                        content: {
                            Button("actioN!", action: {})
                        },
                        text: "Menu"
                    )
                }
            }
        }
    }
}
#endif
#endif
