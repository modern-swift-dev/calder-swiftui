#if os(iOS)
    @testable import CalderTheme
    import SwiftUI
    import Testing
    import UIKit

    @Suite(.serialized)
    @MainActor struct MarkdownViewDynamicTypeTests {
        private func height(of markdown: String, size: DynamicTypeSize) -> CGFloat {
            let view = MarkdownView(text: markdown).environment(\.dynamicTypeSize, size)
            let controller = UIHostingController(rootView: view)
            return controller.sizeThatFits(in: CGSize(width: 320, height: CGFloat.greatestFiniteMagnitude)).height
        }

        @Test(arguments: [
            "plain paragraph",
            "# Heading 1",
            "## Heading 2",
            "### Heading 3",
            "#### Heading 4",
            "##### Heading 5",
            "###### Heading 6",
            "`inline code`",
            "```\ncode block\n```",
            "> quoted text"
        ])
        func `markdown text grows with Dynamic Type`(markdown: String) {
            let regular = height(of: markdown, size: .large)
            let larger = height(of: markdown, size: .accessibility3)

            #expect(larger > regular)
        }

        @Test func `markdown keeps its default sizes at the default Dynamic Type size`() {
            let paragraph = height(of: "plain paragraph", size: .large)
            let heading = height(of: "# Heading 1", size: .large)

            #expect(heading > paragraph)
        }
    }
#endif
