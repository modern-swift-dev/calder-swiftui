#if canImport(SwiftUI)
    @testable import CalderTheme
    import Foundation
    import SwiftUI
    import Testing

    @Suite(.serialized)
    @MainActor struct FormInputLocalizationTests {
        /// A catalog entry whose English value differs from its key, so a lookup is observable.
        private static let warning = LocalizedStringResource("messageBox.severity.warning", bundle: .module)
        private static let error = LocalizedStringResource("messageBox.severity.error", bundle: .module)

        @Test func `form components offer localized labels`() {
            #expect(FormHeader(title: Self.warning).title == "Warning")
            #expect(FormField(name: Self.warning) { EmptyView() }.name == "Warning")
            #expect(FormFieldResponsive(name: Self.warning) { _ in EmptyView() }.name == "Warning")
            #expect(FormFieldResponsive(name: Self.warning).name == "Warning")
            #expect(FormSwitch(name: Self.warning, value: .constant(true)).name == "Warning")
            #expect(FormButton(text: Self.warning) {}.text == "Warning")
            #if !os(tvOS)
                #expect(FormDatePicker(name: Self.warning, value: .constant(Date())).name == "Warning")
            #endif
        }

        @Test func `form components keep string labels verbatim`() {
            #expect(FormHeader(title: "messageBox.severity.warning").title == "messageBox.severity.warning")
            #expect(FormSwitch(name: "messageBox.severity.warning", value: .constant(true)).name == "messageBox.severity.warning")
            #expect(FormButton(text: "messageBox.severity.warning") {}.text == "messageBox.severity.warning")
        }

        @Test func `text inputs offer a localized placeholder and invalid message`() {
            let text = InputText(text: .constant(""), placeholder: Self.warning, invalid: true, invalidMessage: Self.error)
            let password = InputPassword(text: .constant(""), placeholder: Self.warning, invalid: true, invalidMessage: Self.error)

            #expect(text.placeholder == "Warning")
            #expect(text.invalidMessage == "Error")
            #expect(password.placeholder == "Warning")
            #expect(password.invalidMessage == "Error")
            #expect(InputText(text: .constant(""), placeholder: Self.warning).invalidMessage == nil)
        }

        @Test func `standard text fields offer a localized placeholder`() {
            #expect(InputText(text: .constant(""), placeholder: Self.warning, axis: .vertical).placeholder == "Warning")
            #expect(InputText(Self.warning, text: .constant("")).placeholder == "Warning")
            #if canImport(UIKit) && !os(watchOS)
                _ = InputNumber(Self.warning, value: .constant(1.5)).body
                _ = InputNumber(value: .constant(1.5), placeholder: Self.warning).body
            #endif
        }

        @Test func `assigning a string invalid message keeps it verbatim`() {
            var text = InputText(text: .constant(""), placeholder: Self.warning, invalidMessage: Self.error)
            text.invalidMessage = "messageBox.severity.error"

            #expect(text.invalidMessage == "messageBox.severity.error")
        }

        @Test func `numeric and multiline inputs accept localized text`() {
            _ = InputNumber(value: .constant(nil), placeholder: Self.warning, invalidMessage: Self.error).body
            _ = InputDecimal(value: .constant(nil), placeholder: Self.warning, invalidMessage: Self.error).body
            #if !os(watchOS) && !os(tvOS)
                _ = TextView(text: .constant(""), invalidMessage: Self.error, placeholder: Self.warning).body
                if #available(iOS 26, macOS 26, visionOS 26, *) {
                    let view = AttributedTextView(text: .constant(AttributedString()), invalidMessage: Self.error, placeholder: Self.warning)
                    #expect(view.placeholder?.resolved == "Warning")
                    #expect(view.invalidMessage?.resolved == "Error")
                }
            #endif
        }

        #if os(macOS)
            @Test func `localized placeholder is shown by the hosted text field`() {
                let hosting = NSHostingView(rootView: InputText(text: .constant(""), placeholder: Self.warning))
                let window = NSWindow(contentRect: CGRect(x: 0, y: 0, width: 320, height: 160), styleMask: .borderless, backing: .buffered, defer: false)
                window.isReleasedWhenClosed = false
                window.contentView = hosting
                hosting.layoutSubtreeIfNeeded()
                defer { window.close() }

                #expect(Self.placeholders(in: hosting).contains("Warning"))
            }

            private static func placeholders(in view: NSView) -> [String] {
                let own = (view as? NSTextField)?.placeholderString.map { [$0] } ?? []
                return own + view.subviews.flatMap(placeholders(in:))
            }
        #endif

        #if os(iOS)
            @Test func `password reveal button is announced from the catalog`() {
                let labels = AccessibilityTree.elements(of: InputPassword(text: .constant("secret"))).compactMap(\.label)

                #expect(labels.contains("Show password"))
            }
        #endif

        #if !os(watchOS) && !os(tvOS)
            @Test(arguments: [
                ("en_US", 12, 100, "12 / 100 characters"),
                ("en_US", 1200, 5000, "1,200 / 5,000 characters"),
                ("fr_FR", 1200, 5000, "1\u{202F}200 / 5\u{202F}000 characters")
            ])
            func `character counter formats its numbers for the locale`(locale: String, count: Int, maxLength: Int, expected: String) {
                let counter = TextView.characterCount(count, maxLength: maxLength, locale: Locale(identifier: locale))

                #expect(String(localized: counter) == expected)
            }
        #endif
    }
#endif
