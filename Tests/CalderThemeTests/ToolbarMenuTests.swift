#if canImport(SwiftUI) || canImport(UIKit) || canImport(AppKit)
    #if !os(watchOS)
        @testable import CalderTheme
        import SFSafeSymbols
        import SwiftUI
        import Testing

        @Suite(.serialized)
        @MainActor struct ToolbarMenuTests {

            @Test func `custom label menu constructs body`() {
                let menu = ToolbarMenu(placement: .primaryAction, enabled: true, variant: .regular, content: {
                    Text("Action")
                }, label: {
                    Label("Menu", systemImage: "ellipsis")
                })

                _ = menu.body
            }

            @Test func `text menu constructs body`() {
                let menu = ToolbarMenu(placement: .primaryAction, enabled: false, variant: .title, content: {
                    Text("Action")
                }, text: "Menu")

                _ = menu.body
            }

            @Test func `image menu constructs body`() {
                let menu = ToolbarMenu(placement: .primaryAction, enabled: true, variant: .regular, content: {
                    Text("Action")
                }, icon: Image(systemName: "ellipsis"))

                _ = menu.body
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

            @Test func `symbol menu constructs body`() {
                let menu = ToolbarMenu(placement: .primaryAction, enabled: true, variant: .regular, content: {
                    Text("Action")
                }, symbol: .ellipsisCircle)

                _ = menu.body
            }
        }
    #endif

#endif
