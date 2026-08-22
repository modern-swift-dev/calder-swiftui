#if canImport(SwiftUI)
import CalderSwiftUI
import CalderUIKit
import SFSafeSymbols
import SwiftUI

/// A SwiftUI view for secure password input with a toggle to reveal/hide the text.
///
/// This component provides a `SecureField` for password entry and a button to
/// switch between obscured and plain text visibility. It also supports leading accessories
/// and displays validation messages.
public struct InputPassword: View {

    /// The theme of the environment.
    @Environment(\.theme) private var theme

    /// The actual value of the password field, as a `String` binding.
    @Binding public var text: String

    /// The placeholder text to display when the input field is empty.
    public let placeholder: String

    /// An optional `Image` to display as a leading accessory in the text field.
    public let leftAccessory: Image?

    /// A boolean indicating if the current input is considered invalid.
    public var invalid: Bool

    /// An optional message to display when the input is invalid.
    public var invalidMessage: String?

    /// A boolean indicating whether to display a border around the text view.
    let displayTextViewBorder: Bool

    /// The state of the secure field, either secured (hidden) or unsecured (visible).
    @State public var isSecuredEntry: Bool

    /// Focus state for the text field, allowing programmatic control of focus.
    @FocusState public var focused: Bool

    /// The horizontal size class of the environment.
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    /// Initializes an `InputPassword` view.
    /// - Parameters:
    ///   - text: A binding to the `String` value of the password.
    ///   - placeholder: The placeholder text. Defaults to an empty string.
    ///   - leftAccessory: An optional leading image. Defaults to `nil`.
    ///   - invalid: A boolean indicating if the input is invalid. Defaults to `false`.
    ///   - invalidMessage: An optional error message. Defaults to `nil`.
    ///   - isSecuredEntry: The initial state of the secure entry. Defaults to `false`.
    public init(
        text: Binding<String>,
        placeholder: String = "",
        leftAccessory: Image? = nil,
        invalid: Bool = false,
        invalidMessage: String? = nil,
        isSecuredEntry: Bool = false,
        displayTextViewBorder: Bool = true
    ) {
        _text = text
        self.placeholder = placeholder
        self.leftAccessory = leftAccessory
        self.invalid = invalid
        self.invalidMessage = invalidMessage
        self.displayTextViewBorder = displayTextViewBorder
        _isSecuredEntry = .init(initialValue: isSecuredEntry)
    }

    /// The content and behavior of the view.
    public var body: some View {
        VStack(alignment: .leading, spacing: .xxs) {
            HStack(spacing: .small) {
                if let leftAccessory {
                    leftAccessory
                        .renderingMode(.template).scaledToFit()
                        .imageScale(.medium)
                        .frame(width: 24, height: 24)
                        .foregroundColor(iconColor)
                }

                Group {
                    if isSecuredEntry {
                        SecureField(
                            placeholder,
                            text: $text
                        )
                    } else {
                        TextField(
                            placeholder,
                            text: $text
                        )
                    }
                }
                .font(.body)
                .foregroundStyle(fgColor)
                .textFieldStyle(.plain)
                .focused($focused)

                Button(action: {
                    isSecuredEntry.toggle()
                }, label: {
                    Image(systemSymbol: isSecuredEntry ? .eye : .eyeSlash)
                        .renderingMode(.template).scaledToFit()
                        .imageScale(.medium)
                        .frame(width: 24, height: 24)
                        .foregroundColor(iconColor)
                })
            }
            .padding(.vertical, .small)
            .padding(.horizontal, .xs)
            .background(Material.regular)
            .clipShape(RoundedRectangle(cornerRadius: .xxs))
            .contentShape(RoundedRectangle(cornerRadius: .xxs))
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
                        .foregroundStyle(fgColor)
                        .lineLimit(3)
                        .padding(.horizontal, .xxs)
                }
            }
        }
    }

    /// The foreground color of the text input.
    private var fgColor: Color {
        theme.text1
    }

    /// The border color of the text input, changing based on focus and invalid state.
    private var iconColor: Color {
        if invalid {
            return theme.error
        }

        if focused {
            return theme.primary
        }

        return theme.text2
    }

    /// The border color of the text input, changing based on focus and invalid state.
    private var borderColor: Color {
        if invalid {
            return theme.error
        }

        if focused {
            return theme.primary
        }

        return displayTextViewBorder ? theme.text3 : theme.transparent
    }
}

#endif

#if DEBUG
#if canImport(SwiftUI)
import SFSafeSymbols
import SnapshotPreviews
import SwiftUI

@MainActor enum InputPasswordPreviews: PreviewProvider, SnapshotProvider {
    static let defaultLayout: PreviewSnapshotLayout = .device

    @SnapshotBuilder static var snapshots: [PreviewSnapshot] {
        PreviewSnapshot("empty") {
            InputPasswordPreviewHost(initialText: "", isSecuredEntry: true)
        }

        PreviewSnapshot("filled") {
            InputPasswordPreviewHost(initialText: "test123~!", isSecuredEntry: true)
        }

        PreviewSnapshot("invalid") {
            InputPasswordPreviewHost(
                initialText: "test123~!",
                invalid: true,
                invalidMessage: "Invalid password!",
                isSecuredEntry: false
            )
        }

        PreviewSnapshot("unsecured") {
            InputPasswordPreviewHost(initialText: "test123~!", isSecuredEntry: false)
        }
    }

    private struct InputPasswordPreviewHost: View {
        @Environment(\.theme) private var theme
        @State private var text: String

        private let invalid: Bool
        private let invalidMessage: String?
        private let isSecuredEntry: Bool

        init(
            initialText: String,
            invalid: Bool = false,
            invalidMessage: String? = nil,
            isSecuredEntry: Bool
        ) {
            _text = State(initialValue: initialText)
            self.invalid = invalid
            self.invalidMessage = invalidMessage
            self.isSecuredEntry = isSecuredEntry
        }

        var body: some View {
            VStack {
                InputPassword(
                    text: $text,
                    placeholder: "Password",
                    leftAccessory: Image(systemSymbol: .lock),
                    invalid: invalid,
                    invalidMessage: invalidMessage,
                    isSecuredEntry: isSecuredEntry
                )
                Spacer()
            }
            .padding()
            .background(theme.backgroundGradient)
        }
    }
}
#endif
#endif
