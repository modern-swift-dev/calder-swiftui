#if canImport(SwiftUI) || canImport(UIKit) || canImport(AppKit)
    #if canImport(SwiftUI)
        @testable import CalderSwiftUI
        import Foundation
        import SwiftUI
        import Testing

        @MainActor struct ViewExtensionsTests {

            private typealias Pixel = RenderedBitmap.Pixel

            private static let red = Pixel(red: 255, green: 0, blue: 0, alpha: 255)

            /// A 10x10 opaque red square.
            private static var swatch: some View {
                Color(red: 1, green: 0, blue: 0).frame(width: 10, height: 10)
            }

            // MARK: - eraseToAnyView

            @Test func `erase to any view renders the wrapped view`() throws {
                let bitmap = try #require(RenderedBitmap(rendering: Self.swatch.eraseToAnyView()))

                #expect(bitmap.width == 10)
                #expect(bitmap.height == 10)
                #expect(bitmap.pixel(x: 5, y: 5).isClose(to: Self.red))
            }

            @Test func `erase to any view keeps the wrapped view's layout`() throws {
                let view = VStack(spacing: 0) {
                    Self.swatch
                    Self.swatch
                }
                let bitmap = try #require(RenderedBitmap(rendering: view.eraseToAnyView()))

                #expect(bitmap.width == 10)
                #expect(bitmap.height == 20)
            }

            // MARK: - modify

            @Test func `modify applies modification`() throws {
                let view = Color.clear.frame(width: 10, height: 10)
                    .modify { $0.background(Color(red: 1, green: 0, blue: 0)) }

                let bitmap = try #require(RenderedBitmap(rendering: view))

                #expect(bitmap.pixel(x: 5, y: 5).isClose(to: Self.red))
            }

            @Test(arguments: [true, false])
            func `modify with conditional logic`(widen: Bool) throws {
                let view = Self.swatch.modify { content in
                    if widen {
                        content.padding(.horizontal, 10)
                    } else {
                        content
                    }
                }

                let bitmap = try #require(RenderedBitmap(rendering: view))

                #expect(bitmap.width == (widen ? 30 : 10))
            }

            @Test func `modify chained applies modifications in order`() throws {
                let view = Self.swatch
                    .modify { $0.padding(5) }
                    .modify { $0.background(Color(red: 0, green: 0, blue: 1)) }

                let bitmap = try #require(RenderedBitmap(rendering: view))

                #expect(bitmap.width == 20)
                #expect(bitmap.pixel(x: 0, y: 0).isClose(to: Pixel(red: 0, green: 0, blue: 255, alpha: 255)))
                #expect(bitmap.pixel(x: 10, y: 10).isClose(to: Self.red))
            }

            // MARK: - padding extensions

            @Test func `padding vertical pads the top and bottom only`() throws {
                let bitmap = try #require(RenderedBitmap(rendering: Self.swatch.padding(vertical: 10)))

                #expect(bitmap.width == 10)
                #expect(bitmap.height == 30)
                #expect(bitmap.pixel(x: 5, y: 5) == .clear)
                #expect(bitmap.pixel(x: 5, y: 15).isClose(to: Self.red))
                #expect(bitmap.pixel(x: 5, y: 25) == .clear)
            }

            @Test func `padding horizontal pads the leading and trailing edges only`() throws {
                let bitmap = try #require(RenderedBitmap(rendering: Self.swatch.padding(horizontal: 20)))

                #expect(bitmap.width == 50)
                #expect(bitmap.height == 10)
                #expect(bitmap.pixel(x: 10, y: 5) == .clear)
                #expect(bitmap.pixel(x: 25, y: 5).isClose(to: Self.red))
                #expect(bitmap.pixel(x: 40, y: 5) == .clear)
            }

            @Test func `padding vertical and horizontal pads each axis`() throws {
                let bitmap = try #require(RenderedBitmap(rendering: Self.swatch.padding(vertical: 10, horizontal: 20)))

                #expect(bitmap.width == 50)
                #expect(bitmap.height == 30)
                #expect(bitmap.pixel(x: 25, y: 15).isClose(to: Self.red))
            }

            @Test func `zero padding keeps the view size`() throws {
                let vertical = try #require(RenderedBitmap(rendering: Self.swatch.padding(vertical: 0)))
                let horizontal = try #require(RenderedBitmap(rendering: Self.swatch.padding(horizontal: 0)))

                #expect(vertical.width == 10)
                #expect(vertical.height == 10)
                #expect(horizontal.width == 10)
                #expect(horizontal.height == 10)
            }

            @Test func `padding chained accumulates`() throws {
                let view = Self.swatch
                    .padding(vertical: 5)
                    .padding(horizontal: 10)

                let bitmap = try #require(RenderedBitmap(rendering: view))

                #expect(bitmap.width == 30)
                #expect(bitmap.height == 20)
            }

            // MARK: - ToolbarContent modify

            @Test func `toolbar content modify passes the content to the modifier once`() {
                let recorder = ToolbarContentRecorder()
                let item = ToolbarItem(placement: .automatic) {
                    Button("Action") {}
                }

                _ = item.modify { recorder.record($0) }

                #expect(recorder.invocations == 1)
            }

            /// Counts the toolbar content passed through it.
            private final class ToolbarContentRecorder {
                private(set) var invocations = 0

                func record<Content: ToolbarContent>(_ content: Content) -> Content {
                    invocations += 1
                    return content
                }
            }
        }
    #endif

#endif
