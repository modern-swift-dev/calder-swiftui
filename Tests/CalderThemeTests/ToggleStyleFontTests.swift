#if canImport(SwiftUI)
    @testable import CalderTheme
    import SwiftUI
    import Testing

    @MainActor struct ToggleStyleFontTests {
        private final class FontBox {
            var font: Font?
        }

        /// A label that records the font it inherits from the toggle style.
        private struct FontProbe: View {
            @Environment(\.font) private var font
            let box: FontBox

            var body: some View {
                box.font = font
                return Text(verbatim: "Notifications")
            }
        }

        private static let styles: [(style: ThemedButtonStyle.TextStyle, font: Font)] = [
            (.veryProminent, .title3),
            (.prominent, .headline),
            (.large, .subheadline),
            (.medium, .body),
            (.small, .caption)
        ]

        private static func labelFont(of toggleStyle: some ToggleStyle) -> Font? {
            let box = FontBox()
            _ = RenderedBitmap(rendering: Toggle(isOn: .constant(true)) { FontProbe(box: box) }.toggleStyle(toggleStyle))
            return box.font
        }

        @Test func `checkbox style changes the label font`() {
            for (style, font) in Self.styles {
                #expect(Self.labelFont(of: CheckboxToggleButtonStyle(style: style)) == font)
            }
        }

        @Test func `radio style changes the label font`() {
            for (style, font) in Self.styles {
                #expect(Self.labelFont(of: RadioButtonToggleButtonStyle(style: style)) == font)
            }
        }
    }
#endif
