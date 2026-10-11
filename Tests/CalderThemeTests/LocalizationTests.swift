#if canImport(SwiftUI)
    @testable import CalderTheme
    import Foundation
    import SwiftUI
    import Testing

    @Suite(.serialized)
    @MainActor struct LocalizationTests {
        @Test func `built-in strings resolve from the package string catalog`() {
            #expect(Bundle.module.localizedString(forKey: "messageBox.severity.warning", value: nil, table: nil) == "Warning")
        }

        @Test func `message box severities resolve from the package bundle`() {
            #expect(MessageBox.Variant.success.accessibilitySeverity.map { String(localized: $0) } == "Success")
            #expect(MessageBox.Variant.info.accessibilitySeverity.map { String(localized: $0) } == "Information")
            #expect(MessageBox.Variant.warn.accessibilitySeverity.map { String(localized: $0) } == "Warning")
            #expect(MessageBox.Variant.error.accessibilitySeverity.map { String(localized: $0) } == "Error")
        }

        @Test func `string message box text is kept verbatim`() {
            let box = MessageBox(variant: .info, title: "messageBox.severity.warning", message: "messageBox.severity.error")

            #expect(box.title == "messageBox.severity.warning")
            #expect(box.message == "messageBox.severity.error")
        }

        @Test func `localized message box text is looked up`() {
            let box = MessageBox(
                variant: .info,
                title: LocalizedStringResource("messageBox.severity.warning", bundle: .module),
                message: LocalizedStringResource("messageBox.severity.error", bundle: .module)
            )

            #expect(box.title == "Warning")
            #expect(box.message == "Error")
        }

        /// A catalog entry whose English value differs from its key, so a lookup is observable.
        private static let warning = LocalizedStringResource("messageBox.severity.warning", bundle: .module)

        @Test func `list row body offers localized text`() {
            let verbatim = ListRowBody(title: "messageBox.severity.warning", subtitle: "a", caption: "b")
            let localized = ListRowBody(title: Self.warning, subtitle: Self.warning, caption: Self.warning)

            #expect(verbatim.title == "messageBox.severity.warning")
            #expect(localized.title == "Warning")
            #expect(localized.subtitle == "Warning")
            #expect(localized.caption == "Warning")
            #expect(ListRowBody(title: Self.warning).subtitle == nil)
        }

        @Test func `card list row offers localized text`() {
            let row = ListRow(title: Self.warning, subtitle: Self.warning, caption: Self.warning, detail: Self.warning)
            let body = row.content()

            #expect(body.title == "Warning")
            #expect(body.subtitle == "Warning")
            #expect(body.caption == "Warning")
            #expect(ListRow(title: "messageBox.severity.warning").content().title == "messageBox.severity.warning")
        }

        @Test func `status pill offers localized text`() {
            #expect(StatusPill(text: "messageBox.severity.warning", variant: .warn).text == "messageBox.severity.warning")
            #expect(StatusPill(text: Self.warning, variant: .warn).text == "Warning")
            #expect(StatusPill(text: Self.warning, background: .red, foreground: .white).text == "Warning")
        }

        #if !os(watchOS)
            @Test func `toolbar title offers a localized title`() {
                #expect(ToolbarTitle(title: "messageBox.severity.warning").title == "messageBox.severity.warning")
                #expect(ToolbarTitle(title: Self.warning).title == "Warning")
            }

            @Test func `toolbar button and menu offer localized text`() {
                _ = ToolbarButton(placement: .primaryAction, text: Self.warning) {}.body
                _ = ToolbarMenu(placement: .primaryAction, content: { EmptyView() }, text: Self.warning).body
                _ = ToolbarMenu(placement: .primaryAction, enabled: true, variant: .regular, content: { EmptyView() }, text: Self.warning).body
            }
        #endif

        @Test func `selection items offer localized titles`() {
            #expect(SegmentedControl<Int>.Item(id: 1, title: "messageBox.severity.warning").title == "messageBox.severity.warning")
            #expect(SegmentedControl<Int>.Item(id: 1, title: Self.warning).title == "Warning")
            #expect(SegmentedControl<Int>.Item(id: 1, title: Self.warning) == SegmentedControl<Int>.Item(id: 1, title: Self.warning))
            #expect(CheckboxGroup.Item(id: 1, text: Self.warning).text == "Warning")
            #expect(RadioButtonGroup.Item(id: 1, text: Self.warning).text == "Warning")
        }

        @Test func `assigning a string to a selection item keeps it verbatim`() {
            var checkbox = CheckboxGroup.Item(id: 1, text: Self.warning)
            checkbox.text = "messageBox.severity.error"
            var radio = RadioButtonGroup.Item(id: 1, text: Self.warning)
            radio.text = "messageBox.severity.error"

            #expect(checkbox.text == "messageBox.severity.error")
            #expect(radio.text == "messageBox.severity.error")
        }

        #if os(iOS)
            @Test func `tile is announced with its localized label`() {
                let tile = Tile(icon: Image(systemName: "star"), label: Self.warning, text: "3", variant: .info) {}

                let labels = AccessibilityTree.elements(of: tile).compactMap(\.label)
                #expect(labels.contains { $0.contains("Warning") })
                #expect(!labels.contains { $0.contains("messageBox.severity.warning") })
            }

            @Test func `localized message box is announced with its looked-up text`() throws {
                let box = MessageBox(
                    variant: .warn,
                    title: LocalizedStringResource("messageBox.severity.success", bundle: .module),
                    message: LocalizedStringResource("messageBox.severity.error", bundle: .module)
                )

                let element = try #require(AccessibilityTree.elements(of: box).first)
                #expect(element.label == "Warning, Success, Error")
            }

            @Test func `string message box is announced verbatim`() throws {
                let box = MessageBox(variant: .warn, title: "messageBox.severity.success", message: "messageBox.severity.error")

                let element = try #require(AccessibilityTree.elements(of: box).first)
                #expect(element.label == "Warning, messageBox.severity.success, messageBox.severity.error")
            }
        #endif
    }
#endif
