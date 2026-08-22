#if canImport(SwiftUI)
import CalderStdLib
import CalderSwiftUI
import CalderUIKit
import MarkdownUI
import SwiftUI

/// A SwiftUI view that renders Markdown text with custom styling based on the application's theme.
///
/// This view leverages the `MarkdownUI` library to parse and display Markdown content,
/// applying custom fonts, colors, and block styles for headings, lists, code blocks, and blockquotes.
public struct MarkdownView: View {

    @Environment(\.theme) var theme
    /// The Markdown string to be rendered by the view.
    public let text: String

    /// Initializes a `MarkdownView` with the given Markdown text.
    /// - Parameter text: The Markdown formatted string to display.
    public init(text: String) {
        self.text = text
    }

    public var body: some View {
        MarkdownUI.MarkdownView(text)
            .markdownTextStyle(textStyle: {
                FontFamilyVariant(.normal)
                FontSize(14)
                FontWeight(.regular)
                ForegroundColor(theme.text1)
                BackgroundColor(Color.clear)
            })
            .markdownBlockStyle(\.heading1) { configuration in
                configuration.label
                    .markdownMargin(top: .xs, bottom: .xxs)
                    .markdownTextStyle {
                        FontSize(28)
                        FontWeight(.bold)
                    }
            }
            .markdownBlockStyle(\.heading2) { configuration in
                configuration.label
                    .markdownMargin(top: .xs, bottom: .xxs)
                    .markdownTextStyle {
                        FontSize(24)
                        FontWeight(.bold)
                    }
            }
            .markdownBlockStyle(\.heading3) { configuration in
                configuration.label
                    .markdownMargin(top: .xs, bottom: .xxs)
                    .markdownTextStyle {
                        FontSize(20)
                        FontWeight(.bold)
                    }
            }
            .markdownBlockStyle(\.heading4) { configuration in
                configuration.label
                    .markdownMargin(top: .xs, bottom: .xxs)
                    .markdownTextStyle {
                        FontSize(18)
                        FontWeight(.semibold)
                    }
            }
            .markdownBlockStyle(\.heading5) { configuration in
                configuration.label
                    .markdownMargin(top: .xs, bottom: .xxs)
                    .markdownTextStyle {
                        FontSize(16)
                        FontWeight(.semibold)
                    }
            }
            .markdownBlockStyle(\.heading6) { configuration in
                configuration.label
                    .markdownMargin(top: .xs, bottom: .xxs)
                    .markdownTextStyle {
                        FontSize(14)
                        FontWeight(.semibold)
                    }
            }
            .markdownTextStyle(\.link) {
                FontFamilyVariant(.monospaced)
                ForegroundColor(theme.primary)
                BackgroundColor(theme.primary.opacity(0.15))
                UnderlineStyle(.single)
            }
            .markdownTextStyle(\.code) {
                FontFamilyVariant(.monospaced)
                FontSize(14)
            }
            .markdownBlockStyle(\.listItem, body: { configuration in
                configuration.label
                    .markdownMargin(top: .xxs, bottom: .xxs)
            })
            .markdownBlockStyle(\.list, body: { configuration in
                configuration.label
                    .markdownMargin(top: .xxs, bottom: .small)
            })
            .markdownBlockStyle(\.codeBlock) { configuration in
                configuration.label
                    .padding(.small)
                    .markdownTextStyle {
                        FontFamilyVariant(.monospaced)
                        FontSize(14)
                    }
                    .background(theme.text1.opacity(0.1))
                    .markdownMargin(top: .xs, bottom: .small)
                    .clipShape(RoundedRectangle(cornerRadius: .xxs))
            }
            .markdownBlockStyle(\.blockquote) { configuration in
                configuration.label
                    .markdownTextStyle {
                        FontFamilyVariant(.normal)
                        FontSize(14)
                        FontWeight(.regular)
                        ForegroundColor(theme.text1)
                        BackgroundColor(Color.clear)
                    }
                    .padding(.small)
                    .overlay(alignment: .leading) {
                        Rectangle()
                            .fill(theme.primary)
                            .frame(width: 4)
                    }
                    .background(theme.primary.opacity(0.15))
                    .markdownMargin(top: .xs, bottom: .small)
                    .clipShape(RoundedRectangle(cornerRadius: .xxs))
            }
            .markdownSoftBreakMode(.lineBreak)
            .markdownTableBorderStyle(
                .init(
                    color: theme.text3,
                    strokeStyle: StrokeStyle(
                        lineWidth: 1,
                        lineCap: .round,
                        lineJoin: .round
                    )
                )
            )
    }
}

#endif

#if canImport(SwiftUI)
import CalderStdLib
import CalderUIKit
import SnapshotPreviews
import SwiftUI

#if DEBUG
@MainActor enum MarkdownViewPreviews: PreviewProvider, SnapshotProvider {
    static let defaultLayout: PreviewSnapshotLayout = .device

    static var snapshots: [PreviewSnapshot] {
        PreviewSnapshot("Headers") {
            PreviewContent(text: """

            # header 1
            content

            ## header 2
            content

            ### header 3
            content

            #### header 4
            content

            ##### header 5
            content

            ###### header 6
            content

            """)
        }

        PreviewSnapshot("bold") {
            PreviewContent(text: """
            # Bold!

            **bold** vs not bold
            """)
        }

        PreviewSnapshot("italic") {
            PreviewContent(text: """
            # Italic!

            *italic* vs not italic
            """)
        }

        PreviewSnapshot("strikehtrough") {
            PreviewContent(text: """
            # Strikethrough!

            ~strikehtrough~ vs not strikehtrough
            """)
        }

        PreviewSnapshot("all 3") {
            PreviewContent(text: """
            # Bold, Italic, strikethrough!

            ***~wtf!?~*** vs not strikehtrough
            """)
        }

        PreviewSnapshot("code") {
            PreviewContent(text: """
            # Code

            This is a command: `git status`
            """)
        }

        PreviewSnapshot("code block") {
            PreviewContent(text: """
            # Code Block

            ```
            This is a code sample
            on
            multiple
            ```
            """)
        }

        PreviewSnapshot("list") {
            PreviewContent(text: """
            # List

            ### Unordered List

            * List Item 1
            * List Item 2
            * List Item 3

            ### Ordered List

            * List Item 1
            * List Item 2
            * List Item 3


            ### Multi-Level List

            * List Item 1
              * List Item 1.1
              * List Item 1.1
            * List Item 2
              * List Item 2.1
                * List Item 2.1.1
            * List Item 3


            ### Mixed List

            * List Item 1
              1. List Item 1.1
              1. List Item 1.1
            * List Item 2
              1. List Item 2.1
                 1. List Item 2.1.1
            * List Item 3


            """)
        }

        PreviewSnapshot("quote") {
            PreviewContent(text: """
            # Quote

            > All those who come to power are afraid to loose it. Even the jedi

            – Emperor Palpatine
            """)
        }

        PreviewSnapshot("paragraph") {
            PreviewContent(text: """
            # Paragraph

            Line 1
            Line 2

            Line 3


            Line 4
            """)
        }

        PreviewSnapshot("table") {
            PreviewContent(text: """
            # Table

            | Col 1 | Col 2 |
            | --- | --- |
            | Val 1 | \(String.lorem(300)) |
            | Val 1 | Val 2 |
            | Val 1 | Val 2 |
            | Val 1 | Val 2 |
            """)
        }
    }

    private struct PreviewContent: View {
        @Environment(\.theme) private var theme

        let text: String

        var body: some View {
            ScrollView {
                MarkdownView(text: text)
                    .padding(.medium)
                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
            }
            .background(theme.backgroundGradient)
        }
    }
}
#endif
#endif
