#if os(iOS)
    @testable import CalderTheme
    import CalderUIKit
    import SFSafeSymbols
    import SwiftUI
    import Testing

    @Suite(.serialized)
    @MainActor struct ImageAccessibilityTests {
        private static let warning = LocalizedStringResource("messageBox.severity.warning", bundle: .module)

        /// The distinct labels of the buttons VoiceOver finds, which it may report more than once.
        private func toolbarLabels(@ToolbarContentBuilder _ content: () -> some ToolbarContent) -> Set<String> {
            let view = NavigationStack {
                Text("Body").toolbar { content() }
            }
            return Set(AccessibilityTree.elements(of: view).filter { $0.traits.contains(.button) }.compactMap(\.label))
        }

        @Test func `toolbar button with an icon takes an accessibility label`() {
            let labels = toolbarLabels {
                ToolbarButton(placement: .primaryAction, icon: Image(systemSymbol: .plus), accessibilityLabel: "Add item") {}
            }

            #expect(labels == ["Add item"])
        }

        @Test func `toolbar button with a symbol takes an accessibility label`() {
            let labels = toolbarLabels {
                ToolbarButton(placement: .primaryAction, symbol: .plus, accessibilityLabel: "Add item") {}
            }

            #expect(labels == ["Add item"])
        }

        @Test func `toolbar button takes a localized accessibility label`() {
            let icon = toolbarLabels {
                ToolbarButton(placement: .primaryAction, icon: Image(systemSymbol: .plus), accessibilityLabel: Self.warning) {}
            }
            let symbol = toolbarLabels {
                ToolbarButton(placement: .primaryAction, symbol: .plus, accessibilityLabel: Self.warning) {}
            }

            #expect(icon == ["Warning"])
            #expect(symbol == ["Warning"])
        }

        @Test func `toolbar button without an accessibility label keeps its own label`() {
            let labels = toolbarLabels {
                ToolbarButton(placement: .primaryAction, text: "Save") {}
            }

            #expect(labels == ["Save"])
        }

        @Test func `state icons are hidden from VoiceOver`() {
            for state in [GenericState.pristine("Nothing yet"), .empty("Nothing yet"), .error("Nothing yet")] {
                let labels = AccessibilityTree.elements(of: GenericStateView(state: state) { Text("Displaying") }).compactMap(\.label)

                #expect(labels == ["Nothing yet"])
            }
        }

        @Test func `input accessories are hidden from VoiceOver`() {
            let text = AccessibilityTree.elements(of: InputText(text: .constant(""), placeholder: "Name", leftAccessory: Image(systemSymbol: .lock)))
            let password = AccessibilityTree.elements(of: InputPassword(text: .constant(""), placeholder: "Password", leftAccessory: Image(systemSymbol: .lock)))

            #expect(text.isEmpty)
            #expect(password.compactMap(\.label).allSatisfy { $0 != "Lock" })
        }

        @Test func `generated barcode image is labelled`() async throws {
            let model = BarcodeGeneratorView.Model(code: "calder", generator: .qr)
            await model.generate()

            let elements = AccessibilityTree.elements(of: BarcodeGeneratorView(model: model))

            let image = try #require(elements.first { $0.traits.contains(.image) })
            #expect(image.label == "Barcode")
        }
    }
#endif
