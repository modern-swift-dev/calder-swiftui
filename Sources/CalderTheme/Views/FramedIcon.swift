#if canImport(SwiftUI)
import CalderUIKit
import Foundation
import SFSafeSymbols
import SwiftUI

/// A view that displays an icon centered inside a styled frame.
/// You can customize the shape, background, foreground color, and size.
///
/// `FramedIcon` provides a versatile way to present SF Symbols or other images
/// within a distinct, customizable frame. It's ideal for creating visually consistent
/// icon elements across an application.
public struct FramedIcon: View {

    @Environment(\.theme) var theme
    /// The background color for the frame. If `nil`, defaults to `theme.background3`.
    public var background: Color?

    /// The foreground color for the icon. If `nil`, defaults to `theme.text1`.
    public var foreground: Color?

    /// The width and height of the frame.
    public var size: CGFloat

    /// The `Image` to display inside the frame.
    public var icon: Image

    /// The enclosing shape for the frame (e.g., `RoundedRectangle`, `Circle`).
    public var shape: any Shape

    /// Creates a framed icon view.
    /// - Parameters:
    ///   - icon: The image to display inside the frame.
    ///   - foreground: Optional color for the icon (defaults to `theme.text1`).
    ///   - background: Optional frame background color (defaults to `theme.background3`).
    ///   - size: Width and height of the frame. Defaults to `40`.
    ///   - shape: The enclosing shape (e.g., `RoundedRectangle`, `Circle`). Defaults to `RoundedRectangle(cornerRadius: CGFloat.xxs)`.
    public init(
        icon: Image,
        foreground: Color? = nil,
        background: Color? = nil,
        size: CGFloat = 40,
        shape: any Shape = RoundedRectangle(cornerRadius: CGFloat.xxs)
    ) {
        self.foreground = foreground
        self.background = background
        self.size = size
        self.icon = icon
        self.shape = shape
    }

    /// Creates a framed sf symbol view.
    /// - Parameters:
    ///   - symbol: The symbol to display inside the frame.
    ///   - foreground: Optional color for the icon (defaults to `theme.text1`).
    ///   - background: Optional frame background color (defaults to `theme.background3`).
    ///   - size: Width and height of the frame. Defaults to `40`.
    ///   - shape: The enclosing shape (e.g., `RoundedRectangle`, `Circle`). Defaults to `RoundedRectangle(cornerRadius: CGFloat.xxs)`.
    public init(
        symbol: SFSymbol,
        foreground: Color? = nil,
        background: Color? = nil,
        size: CGFloat = 40,
        shape: any Shape = RoundedRectangle(cornerRadius: CGFloat.xxs)
    ) {
        self.foreground = foreground
        self.background = background
        self.size = size
        self.icon = Image(systemSymbol: symbol)
        self.shape = shape
    }

    /// The content and behavior of the `FramedIcon`.
    public var body: some View {
        (background ?? theme.background3)
            .opacity(0.5)
            .frame(width: size, height: size)
            .contentShape(AnyShape(shape))
            .clipShape(AnyShape(shape))
            .overlay(
                icon
                    .symbolRenderingMode(.monochrome)
                    .renderingMode(.template)
                    .resizable().scaledToFit()
                    .foregroundStyle(foreground ?? theme.text1)
                    .frame(width: size / 2.0, height: size / 2.0)
            )
    }
}

#endif

#if canImport(SwiftUI)
import SFSafeSymbols
import SnapshotPreviews
import SwiftUI

#if DEBUG
@MainActor enum FramedIconPreviews: PreviewProvider, SnapshotProvider {
    static let defaultLayout: PreviewSnapshotLayout = .device

    static var snapshots: [PreviewSnapshot] {
        PreviewSnapshot("RoundedRectangle") {
            PreviewContent(shape: .roundedRectangle)
        }

        PreviewSnapshot("Circle") {
            PreviewContent(shape: .circle)
        }
    }

    private enum Shape {
        case circle
        case roundedRectangle
    }

    private struct PreviewContent: View {
        @Environment(\.theme) private var theme

        let shape: Shape

        @ViewBuilder var framedIcon: some View {
            switch shape {
                case .circle:
                    FramedIcon(
                        symbol: .eye,
                        foreground: theme.text1,
                        background: theme.background3,
                        size: 40,
                        shape: Circle()
                    )
                case .roundedRectangle:
                    FramedIcon(
                        icon: Image(systemSymbol: .eye),
                        foreground: theme.text1,
                        background: theme.background3,
                        size: 40
                    )
            }
        }

        var body: some View {
            VStack {
                framedIcon
                Spacer()
            }
            .frame(maxWidth: .infinity)
            .background(theme.backgroundGradient)
        }
    }
}
#endif
#endif
