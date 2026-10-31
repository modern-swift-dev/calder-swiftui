#if os(iOS)
    @testable import CalderTheme
    import SwiftUI
    import Testing
    import UIKit

    @Suite(.serialized)
    @MainActor struct TextViewMaxLengthTests {
        private final class Box {
            var text = ""
            var attributed = AttributedString()
        }

        private struct PlainHost: View {
            @State var text: String
            let maxLength: Int
            let box: Box

            var body: some View {
                TextView(text: $text, maxLength: maxLength)
                    .onChange(of: text, initial: true) { box.text = text }
            }
        }

        @available(iOS 26, *)
        private struct AttributedHost: View {
            @State var text: AttributedString
            let maxLength: Int
            let box: Box

            var body: some View {
                AttributedTextView(text: $text, maxLength: maxLength)
                    .onChange(of: text, initial: true) { box.attributed = text }
            }
        }

        @Test(arguments: [(150, 100, 100), (5, 100, 5), (5, -1, 0), (5, 0, 0)])
        func `text view cuts over limit text when it appears`(length: Int, maxLength: Int, expected: Int) async {
            let box = Box()
            let window = host(PlainHost(text: String(repeating: "a", count: length), maxLength: maxLength, box: box))
            defer { window.isHidden = true }

            #expect(await settles { box.text.count == expected })
        }

        @available(iOS 26, *)
        @Test(arguments: [(150, 100, 100), (5, 100, 5), (5, -1, 0), (5, 0, 0)])
        func `attributed text view cuts over limit text when it appears`(length: Int, maxLength: Int, expected: Int) async {
            let box = Box()
            let text = AttributedString(String(repeating: "a", count: length))
            let window = host(AttributedHost(text: text, maxLength: maxLength, box: box))
            defer { window.isHidden = true }

            #expect(await settles { box.attributed.characters.count == expected })
        }

        @Test func `text view treats a negative limit as zero`() {
            let view = TextView(text: .constant(""), maxLength: -3)

            #expect(view.maxLength == 0)
        }

        @available(iOS 26, *)
        @Test func `attributed text view treats a negative limit as zero`() {
            let view = AttributedTextView(text: .constant(AttributedString()), maxLength: -3)

            #expect(view.maxLength == 0)
        }

        private func host(_ view: some View) -> UIWindow {
            let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 320, height: 300))
            window.rootViewController = UIHostingController(rootView: view)
            window.isHidden = false
            window.layoutIfNeeded()
            return window
        }

        private func settles(_ condition: () -> Bool) async -> Bool {
            for _ in 0 ..< 50 {
                if condition() {
                    return true
                }
                try? await Task.sleep(for: .milliseconds(20))
            }
            return condition()
        }
    }
#endif
