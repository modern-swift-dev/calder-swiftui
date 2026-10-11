#if os(macOS)
    import AppKit
    @testable import CalderTheme
    import CalderUIKit
    import Observation
    import SwiftUI
    import Testing

    @Suite(.serialized)
    @MainActor struct BarcodeGeneratorViewHostedTests {
        @Observable fileprivate final class Parent {
            var counter = 0
            var code = "calder"
            @ObservationIgnored var createdModels: [BarcodeGeneratorView.Model] = []
        }

        private struct Content: View {
            let parent: Parent

            var body: some View {
                let model = BarcodeGeneratorView.Model(code: parent.code, generator: .qr)
                parent.createdModels.append(model)

                return VStack {
                    Text(verbatim: "\(parent.counter)")
                    BarcodeGeneratorView(model: model)
                }
            }
        }

        @Test func `generated image survives unrelated parent updates`() async throws {
            let parent = Parent()
            let window = makeWindow(parent: parent)
            defer { window.close() }
            let content = try #require(window.contentView)
            let original = try #require(parent.createdModels.first)
            try #require(await settles(content) { original.image != nil })

            parent.counter += 1
            try #require(await settles(content) { parent.createdModels.count > 1 })
            await drainUpdates(content)

            #expect(original.image != nil)
            #expect(parent.createdModels.dropFirst().allSatisfy { $0.image == nil })
        }

        @Test func `changing the code generates a new image`() async throws {
            let parent = Parent()
            let window = makeWindow(parent: parent)
            defer { window.close() }
            let content = try #require(window.contentView)
            let original = try #require(parent.createdModels.first)
            try #require(await settles(content) { original.image != nil })

            parent.code = "swiftui"

            #expect(await settles(content) { parent.createdModels.last?.code == "swiftui" && parent.createdModels.last?.image != nil })
        }

        private func makeWindow(parent: Parent) -> NSWindow {
            _ = NSApplication.shared
            let window = NSWindow(contentRect: CGRect(x: 0, y: 0, width: 320, height: 320), styleMask: .borderless, backing: .buffered, defer: false)
            window.isReleasedWhenClosed = false
            window.contentView = NSHostingView(rootView: Content(parent: parent))
            window.contentView?.layoutSubtreeIfNeeded()
            return window
        }

        private func settles(_ content: NSView, until condition: () -> Bool) async -> Bool {
            for _ in 0 ..< 100 {
                content.layoutSubtreeIfNeeded()
                if condition() {
                    return true
                }
                try? await Task.sleep(for: .milliseconds(10))
            }
            return condition()
        }

        private func drainUpdates(_ content: NSView) async {
            for _ in 0 ..< 10 {
                content.layoutSubtreeIfNeeded()
                try? await Task.sleep(for: .milliseconds(10))
            }
        }
    }
#endif
