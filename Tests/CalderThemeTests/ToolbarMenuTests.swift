#if canImport(SwiftUI) || canImport(UIKit) || canImport(AppKit)
    #if !os(watchOS)
        @testable import CalderTheme
        import SFSafeSymbols
        import SwiftUI
        import Testing

        @MainActor struct ToolbarMenuTests {

            @Test func `custom label menu styles its label as a bar button`() throws {
                let menu = ToolbarMenu(placement: .primaryAction, enabled: true, variant: .regular, content: {
                    Text("Action")
                }, label: {
                    Label("Menu", systemImage: "ellipsis")
                })
                let expected = Self.barButton(variant: .regular, enabled: true) {
                    Label("Menu", systemImage: "ellipsis")
                }

                #expect(try Self.render(menu.styledLabel) == Self.render(expected))
                #expect(try Self.render(menu.styledLabel) != Self.render(Label("Menu", systemImage: "ellipsis")))
            }

            @Test func `text menu styles its text with the variant and enabled state`() throws {
                let menu = ToolbarMenu(placement: .primaryAction, enabled: false, variant: .title, content: {
                    Text("Action")
                }, text: "Menu")
                let disabled = Self.barButton(variant: .title, enabled: false) { Text(verbatim: "Menu") }
                let enabled = Self.barButton(variant: .title, enabled: true) { Text(verbatim: "Menu") }

                let rendered = try Self.render(menu.styledLabel)

                #expect(try rendered == Self.render(disabled))
                #expect(try rendered != Self.render(enabled))
            }

            @Test func `image menu styles its icon as a bar button`() throws {
                let menu = ToolbarMenu(placement: .primaryAction, enabled: true, variant: .regular, content: {
                    Text("Action")
                }, icon: Image(systemName: "ellipsis"))
                let expected = Self.barButton(variant: .regular, enabled: true) {
                    Image(systemName: "ellipsis")
                }

                #expect(try Self.render(menu.styledLabel) == Self.render(expected))
                #expect(try Self.render(menu.styledLabel) != Self.render(Image(systemName: "ellipsis")))
            }

            /// A button styled the way a toolbar menu should style its label.
            private static func barButton(variant: BarButtonStyle.Variant, enabled: Bool, @ViewBuilder label: @escaping () -> some View) -> some View {
                Button(action: {}, label: label)
                    .buttonStyle(BarButtonStyle(variant: variant))
                    .disabled(!enabled)
            }

            private static func render(_ view: some View) throws -> RenderedBitmap {
                try #require(RenderedBitmap(rendering: view))
            }

            /// Renders a view and returns the alpha of its centre pixel.
            private static func centreAlpha(of view: some View) -> UInt8? {
                guard let image = ImageRenderer(content: view).cgImage else {
                    return nil
                }
                var pixel: [UInt8] = [0, 0, 0, 0]
                let context = CGContext(
                    data: &pixel,
                    width: 1,
                    height: 1,
                    bitsPerComponent: 8,
                    bytesPerRow: 4,
                    space: CGColorSpaceCreateDeviceRGB(),
                    bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
                )
                let width = CGFloat(image.width)
                let height = CGFloat(image.height)
                context?.draw(image, in: CGRect(x: -width / 2, y: -height / 2, width: width, height: height))
                return context == nil ? nil : pixel[3]
            }

            @Test func `disabled menu dims like a disabled bar button`() {
                let swatch = { Color.red.frame(width: 20, height: 20) }
                let menu = ToolbarMenu(placement: .primaryAction, enabled: false, variant: .regular, content: {
                    Text("Action")
                }, label: swatch)
                let disabledButton = Button(action: {}, label: swatch)
                    .buttonStyle(BarButtonStyle(variant: .regular))
                    .disabled(true)

                let menuAlpha = Self.centreAlpha(of: menu.styledLabel)
                let buttonAlpha = Self.centreAlpha(of: disabledButton)

                #expect(buttonAlpha != nil)
                #expect(menuAlpha == buttonAlpha)
            }

            @Test func `symbol menu styles its symbol as a bar button`() throws {
                let menu = ToolbarMenu(placement: .primaryAction, enabled: true, variant: .regular, content: {
                    Text("Action")
                }, symbol: .ellipsisCircle)
                let expected = Self.barButton(variant: .regular, enabled: true) {
                    Image(systemSymbol: .ellipsisCircle)
                }

                #expect(try Self.render(menu.styledLabel) == Self.render(expected))
                #expect(try Self.render(menu.styledLabel) != Self.render(Image(systemSymbol: .ellipsisCircle)))
            }
        }
    #endif

#endif
