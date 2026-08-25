#if canImport(SwiftUI)
#if !os(watchOS) && !os(tvOS)
import CalderStdLib
import CalderUIKit
import Foundation
import SwiftUI

/// A SwiftUI view for a multi-line text input area, similar to `UITextView`.
///
/// This view provides features such as placeholder text, character limit, and visual feedback for invalid input.
public struct TextView: View {

    @Environment(\.theme) var theme

    /// A binding to the `String` value of the text area.
    @Binding public var text: String

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
    /// The fixed height of the text area.
    let height: CGFloat?

    /// Initializes a `TextView` view.
    /// - Parameters:
    ///   - text: A binding to the `String` value of the text area.
    ///   - invalid: A boolean indicating if the input is invalid. Defaults to `false`.
    ///   - invalidMessage: An optional error message. Defaults to `nil`.
    ///   - placeholder: The placeholder text. Defaults to `nil`.
    ///   - displayTextViewBorder: A boolean indicating whether to show a border around the text area. Defaults to `true`.
    ///   - maxLength: The maximum length of text allowed. Defaults to `nil`.
    ///   - height: The fixed height of the text area. Defaults to `nil`.
    public init(
        text: Binding<String>,
        invalid: Bool = false,
        invalidMessage: String? = nil,
        placeholder: String? = nil,
        displayTextViewBorder: Bool = true,
        maxLength: Int? = nil,
        height: CGFloat? = nil
    ) {
        _text = text
        self.invalid = invalid
        self.placeholder = placeholder
        self.maxLength = maxLength
        self.height = height
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
                        .frame(height: height)
                        .focused($isFocused)
                        .onChange(of: text, initial: false) {
                            if let maxLength, text.count > maxLength {
                                text = String(text.prefix(maxLength))
                            }
                        }

                    if !isFocused, let placeholder, text.isEmpty {
                        Text(verbatim: placeholder)
                            .font(.body)
                            .foregroundStyle(theme.textFieldPlaceholder)
                            .offset(x: .xxs, y: .xs)
                    }
                }
            }
            .padding(.horizontal, .xs)
            .padding(.vertical, .xxs)
            .background(Material.regular)
            .contentShape(RoundedRectangle(cornerRadius: .xxs))
            .clipShape(RoundedRectangle(cornerRadius: .xxs))
            .overlay(
                RoundedRectangle(cornerRadius: .xxs)
                    .stroke(
                        borderColor,
                        lineWidth: displayTextViewBorder ? 1 : 0
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

            if let maxLength {
                HStack(spacing: 0) {
                    Spacer()

                    Text(verbatim: "\(text.count) / \(maxLength) characters")
                        .font(.caption)
                        .foregroundStyle(theme.text2)
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

        return displayTextViewBorder ? theme.text3 : theme.transparent
    }

}

#endif

#endif

#if DEBUG
#if canImport(SwiftUI)
#if !os(watchOS) && !os(tvOS)
import CalderStdLib
import CalderUIKit
import SnapshotPreviews
import SwiftUI

@MainActor enum TextViewPreviews: PreviewProvider, SnapshotProvider {
    static let defaultLayout: PreviewSnapshotLayout = .device

    @SnapshotBuilder static var snapshots: [PreviewSnapshot] {
        PreviewSnapshot("empty") {
            TextViewPreviewHost(initialText: "")
        }

        PreviewSnapshot("filled") {
            TextViewPreviewHost(initialText: String.loremIpsum)
        }

        PreviewSnapshot("invalid") {
            TextViewPreviewHost(
                initialText: String.loremIpsum,
                invalid: true,
                invalidMessage: "Error Message!"
            )
        }

        PreviewSnapshot("placeholder") {
            TextViewPreviewHost(initialText: "", placeholder: "Placeholder")
        }

        PreviewSnapshot("fixed height with character counter") {
            TextViewPreviewHost(
                initialText: String.loremIpsum,
                maxLength: 100,
                height: 120
            )
        }
    }

    private struct TextViewPreviewHost: View {
        @Environment(\.theme) private var theme
        @State private var text: String

        private let invalid: Bool
        private let invalidMessage: String?
        private let placeholder: String?
        private let maxLength: Int?
        private let height: CGFloat?

        init(
            initialText: String,
            invalid: Bool = false,
            invalidMessage: String? = nil,
            placeholder: String? = nil,
            maxLength: Int? = nil,
            height: CGFloat? = nil
        ) {
            _text = State(initialValue: initialText)
            self.invalid = invalid
            self.invalidMessage = invalidMessage
            self.placeholder = placeholder
            self.maxLength = maxLength
            self.height = height
        }

        var body: some View {
            VStack {
                TextView(
                    text: $text,
                    invalid: invalid,
                    invalidMessage: invalidMessage,
                    placeholder: placeholder,
                    maxLength: maxLength,
                    height: height
                )
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: 300)
                Spacer()
            }
            .padding()
            .background(theme.backgroundGradient)
        }
    }
}
#endif
#endif
#endif
