#if canImport(SwiftUI)
    @testable import CalderTheme
    import Foundation
    import SwiftUI
    import Testing

    @MainActor struct AdaptiveStackTests {
        /// Records the state token each child body observes.
        final class Recorder {
            var tokens: [UUID] = []
        }

        /// A child whose state token is created once per view identity.
        struct StatefulChild: View {
            let recorder: Recorder
            @State private var token = UUID()

            var body: some View {
                recorder.tokens.append(token)
                return Color.clear.frame(width: 10, height: 10)
            }
        }

        private static func content(sizeClass: UserInterfaceSizeClass, recorder: Recorder) -> AnyView {
            AnyView(
                AdaptiveStack { _ in
                    StatefulChild(recorder: recorder)
                }
                .environment(\.horizontalSizeClass, sizeClass)
            )
        }

        @Test func `child state survives a size class change`() {
            let recorder = Recorder()
            let renderer = ImageRenderer(content: Self.content(sizeClass: .compact, recorder: recorder))
            _ = renderer.cgImage

            renderer.content = Self.content(sizeClass: .regular, recorder: recorder)
            _ = renderer.cgImage

            #expect(!recorder.tokens.isEmpty)
            #expect(Set(recorder.tokens).count == 1)
        }

        @available(*, deprecated)
        @Test func `deprecated AdaptativeStack aliases AdaptiveStack`() {
            let stack: AdaptiveStack<Text> = AdaptativeStack(verticalSpacing: 4, horizontalSpacing: 6) { _ in
                Text("Content")
            }

            #expect(stack.verticalSpacing == 4)
            #expect(stack.horizontalSpacing == 6)
        }
    }
#endif
