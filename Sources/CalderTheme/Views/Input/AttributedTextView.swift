#if canImport(SwiftUI)
#if !os(watchOS) && !os(tvOS)
import CalderStdLib
import CalderUIKit
import Foundation
import SwiftUI

/// A SwiftUI view for a multi-line text input area, similar to `UITextView`, that supports `AttributedString`.
///
/// This view provides features such as placeholder text, character limit, and visual feedback for invalid input.
@available(iOS 26, macOS 26, *) public struct AttributedTextView: View {

    @Environment(\.theme) var theme

    /// A binding to the `AttributedString` value of the text area.
    @Binding public var text: AttributedString

    /// Focus state for the text area, allowing programmatic control of focus.
    @FocusState var isFocused

    /// A boolean indicating if the current input is considered invalid.
    let invalid: Bool
    /// An optional message to display when the input is invalid.
    let invalidMessage: String?
    /// The placeholder text displayed when the text area is empty.
    let placeholder: String?
    /// A boolean indicating whether to display a border around the text area.
    let displayTextViewBorder: Bool
    /// The maximum length of text allowed in the text area.
    let maxLength: Int?

    /// Initializes an `AttributedTextView` view.
    /// - Parameters:
    ///   - text: A binding to the `AttributedString` value of the text area.
    ///   - invalid: A boolean indicating if the input is invalid. Defaults to `false`.
    ///   - invalidMessage: An optional error message. Defaults to `nil`.
    ///   - placeholder: The placeholder text. Defaults to `nil`.
    ///   - displayTextViewBorder: A boolean indicating whether to show a border around the text area. Defaults to `true`.
    ///   - maxLength: The maximum length of text allowed. Defaults to `nil`.
    public init(
        text: Binding<AttributedString>,
        invalid: Bool = false,
        invalidMessage: String? = nil,
        placeholder: String? = nil,
        displayTextViewBorder: Bool = true,
        maxLength: Int? = nil
    ) {
        _text = text
        self.invalid = invalid
        self.placeholder = placeholder
        self.maxLength = maxLength
        self.displayTextViewBorder = displayTextViewBorder
        self.invalidMessage = invalidMessage
    }

    /// The content and behavior of the view.
    public var body: some View {
        VStack(alignment: .leading, spacing: .xs) {
            // this hstack is just to simulate the lineFragmentPadding that we would normally
            // adapt with the UITextView. It is unfortunately not supported in SwiftUI
            HStack(alignment: .center, spacing: 0) {
                ZStack(alignment: .topLeading) {
                    TextEditor(text: $text)
                        .font(.body)
                        .foregroundStyle(theme.text1)
                        .scrollContentBackground(.hidden)
                        .focused($isFocused)
                        .onChange(of: text, initial: false) {
                            if let maxLength, text.characters.count > maxLength {
                                let start = text.characters.index(text.startIndex, offsetBy: maxLength)
                                text.removeSubrange(start ..< text.endIndex)
                            }
                        }

                    if !isFocused, let placeholder, text.characters.isEmpty {
                        Text(verbatim: placeholder)
                            .font(.body)
                            .foregroundStyle(theme.textFieldPlaceholder)
                            .offset(x: .xxs, y: .xs)
                    }
                }
            }
            .padding(.vertical, .xxs)
            .padding(.horizontal, .xs)
            .background(Material.regular)
            .contentShape(RoundedRectangle(cornerRadius: .xxs))
            .clipShape(RoundedRectangle(cornerRadius: .xxs))
            .overlay(
                RoundedRectangle(cornerRadius: .xxs)
                    .stroke(
                        borderColor,
                        lineWidth: displayTextViewBorder ? 2 : 0
                    )
            )

            if let invalidMessage {
                HStack(spacing: .small) {
                    Spacer()

                    Text(verbatim: invalidMessage)
                        .font(.caption)
                        .foregroundStyle(theme.text1)
                        .lineLimit(3)
                        .padding(.horizontal, .xxs)
                }
            }
        }
    }

    /// The border color of the text area, changing based on focus and invalid state.
    private var borderColor: Color {
        if invalid {
            return theme.error.opacity(0.5)
        }

        if isFocused {
            return theme.primary.opacity(0.5)
        }

        return theme.transparent
    }

}

#endif

#endif

#if DEBUG
#if canImport(SwiftUI)
#if !os(watchOS) && !os(tvOS)
import CalderStdLib
import CalderUIKit
import Foundation
import SnapshotPreviews
import SwiftUI

@available(iOS 26, macOS 26, *)
@MainActor enum AttributedTextViewPreviews: PreviewProvider, SnapshotProvider {
    static let defaultLayout: PreviewSnapshotLayout = .device

    @SnapshotBuilder static var snapshots: [PreviewSnapshot] {
        PreviewSnapshot("empty") {
            AttributedTextViewPreviewHost(initialText: AttributedString(""))
        }

        PreviewSnapshot("filled") {
            AttributedTextViewPreviewHost(initialText: AttributedString(String.loremIpsum))
        }

        PreviewSnapshot("invalid") {
            AttributedTextViewPreviewHost(
                initialText: AttributedString(String.loremIpsum),
                invalid: true,
                invalidMessage: "Error Message!"
            )
        }

        PreviewSnapshot("placeholder") {
            AttributedTextViewPreviewHost(
                initialText: AttributedString(""),
                placeholder: "Placeholder"
            )
        }
    }

    private struct AttributedTextViewPreviewHost: View {
        @Environment(\.theme) private var theme
        @State private var text: AttributedString

        private let invalid: Bool
        private let invalidMessage: String?
        private let placeholder: String?

        init(
            initialText: AttributedString,
            invalid: Bool = false,
            invalidMessage: String? = nil,
            placeholder: String? = nil
        ) {
            _text = State(initialValue: initialText)
            self.invalid = invalid
            self.invalidMessage = invalidMessage
            self.placeholder = placeholder
        }

        var body: some View {
            VStack {
                AttributedTextView(
                    text: $text,
                    invalid: invalid,
                    invalidMessage: invalidMessage,
                    placeholder: placeholder,
                    maxLength: 3000
                )
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: 300)
                .padding()
                Spacer()
            }
            .background(theme.backgroundGradient)
        }
    }
}
#endif
#endif
#endif
