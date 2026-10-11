#if os(iOS)
    import CalderTheme
    import SwiftUI
    import Testing
    import UIKit

    @Suite(.serialized)
    @MainActor struct InputPasswordUIKitHostedTests {
        @Test func `revealed password field opts out of autocorrection and learned words`() throws {
            let window = makeWindow(InputPassword(text: .constant("secret"), isSecuredEntry: false))
            defer { window.isHidden = true }
            let field = try #require(textField(in: window))

            #expect(!field.isSecureTextEntry)
            #expect(field.textContentType == .password)
            #expect(field.autocorrectionType == .no)
            #expect(field.autocapitalizationType == .none)
        }

        private func makeWindow(_ view: some View) -> UIWindow {
            let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 320, height: 160))
            window.rootViewController = UIHostingController(rootView: view)
            window.isHidden = false
            window.layoutIfNeeded()
            return window
        }

        private func textField(in view: UIView) -> UITextField? {
            if let field = view as? UITextField {
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
