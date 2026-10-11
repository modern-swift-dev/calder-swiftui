#if os(macOS)
    import AppKit
    import CalderTheme
    import SwiftUI
    import Testing

    @Suite(.serialized)
    @MainActor struct InputPasswordHostedTests {
        @Test func `password input hides text by default`() throws {
            let window = makeWindow(InputPassword(text: .constant("secret"), placeholder: "Password"))
            defer { window.close() }
            let content = try #require(window.contentView)

            #expect(textField(in: content) is NSSecureTextField)
        }

        @Test func `password input can opt into revealed entry`() throws {
            let window = makeWindow(InputPassword(text: .constant("secret"), placeholder: "Password", isSecuredEntry: false))
            defer { window.close() }
            let content = try #require(window.contentView)
            let field = try #require(textField(in: content))

            #expect(!(field is NSSecureTextField))
            #expect(field.stringValue == "secret")
        }

        private func makeWindow(_ view: some View) -> NSWindow {
            _ = NSApplication.shared
            let window = NSWindow(contentRect: CGRect(x: 0, y: 0, width: 320, height: 160), styleMask: .borderless, backing: .buffered, defer: false)
            window.isReleasedWhenClosed = false
            window.contentView = NSHostingView(rootView: view)
            window.contentView?.layoutSubtreeIfNeeded()
            return window
        }

        private func textField(in view: NSView) -> NSTextField? {
            if let field = view as? NSTextField, field.placeholderString == "Password" {
                return field
            }
            for subview in view.subviews {
                if let field = textField(in: subview) {
                    return field
                }
            }
            return nil
        }
    }
#endif
