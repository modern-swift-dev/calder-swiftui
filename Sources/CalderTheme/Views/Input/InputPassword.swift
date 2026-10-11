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

        private let placeholderText: LocalizableText

        /// The placeholder text to display when the input field is empty.
        ///
        /// A placeholder created from a `LocalizedStringResource` is resolved for the current locale.
        public var placeholder: String {
            placeholderText.resolved
        }

        /// An optional `Image` to display as a leading accessory in the text field.
        public let leftAccessory: Image?

        /// A boolean indicating if the current input is considered invalid.
        public var invalid: Bool

        private var invalidMessageText: LocalizableText?

        /// An optional message to display when the input is invalid.
        ///
        /// VoiceOver reads the message as the text field's hint. A message created from a
        /// `LocalizedStringResource` is resolved for the current locale. Assigning a string
        /// replaces it with a message displayed unchanged.
        public var invalidMessage: String? {
            get { invalidMessageText?.resolved }
            set { invalidMessageText = newValue.map(LocalizableText.verbatim) }
        }

        /// A boolean indicating whether to display a border around the text view.
        let displayTextViewBorder: Bool

        /// The state of the secure field, either secured (hidden) or unsecured (visible).
        @State public var isSecuredEntry: Bool

        /// Focus state for the text field, allowing programmatic control of focus.
        @FocusState public var focused: Bool

        /// The horizontal size class of the environment.
        @Environment(\.horizontalSizeClass) private var horizontalSizeClass

        /// Initializes an `InputPassword` view.
        ///
        /// The field hides its text by default. Pass `false` for `isSecuredEntry` to start with the
        /// text revealed. Users can toggle visibility with the reveal button either way.
        /// - Parameters:
        ///   - text: A binding to the `String` value of the password.
        ///   - placeholder: The placeholder text. Defaults to an empty string.
        ///   - leftAccessory: An optional leading image. Defaults to `nil`.
        ///   - invalid: A boolean indicating if the input is invalid. Defaults to `false`. An invalid input draws
        ///     an error border even when `displayTextViewBorder` is `false`.
        ///   - invalidMessage: An optional error message, also read by VoiceOver as the field's hint. Defaults to `nil`.
        ///   - isSecuredEntry: Whether the field initially hides its text. Defaults to `true`.
        ///   - displayTextViewBorder: A boolean indicating whether to show a border around the text field. Defaults to `true`.
        public init(
            text: Binding<String>,
            placeholder: String = "",
            leftAccessory: Image? = nil,
            invalid: Bool = false,
            invalidMessage: String? = nil,
            isSecuredEntry: Bool = true,
            displayTextViewBorder: Bool = true
        ) {
            self.init(
                text: text,
                placeholderText: .verbatim(placeholder),
                leftAccessory: leftAccessory,
                invalid: invalid,
                invalidMessageText: invalidMessage.map(LocalizableText.verbatim),
                isSecuredEntry: isSecuredEntry,
                displayTextViewBorder: displayTextViewBorder
            )
        }

        /// Initializes an `InputPassword` view with a localized placeholder and invalid message.
        ///
        /// SwiftUI looks up each resource in its bundle and table using the environment's locale.
        /// The field hides its text by default. Pass `false` for `isSecuredEntry` to start with the
        /// text revealed. Users can toggle visibility with the reveal button either way.
        /// - Parameters:
        ///   - text: A binding to the `String` value of the password.
        ///   - placeholder: The localized placeholder text.
        ///   - leftAccessory: An optional leading image. Defaults to `nil`.
        ///   - invalid: A boolean indicating if the input is invalid. Defaults to `false`. An invalid input draws
        ///     an error border even when `displayTextViewBorder` is `false`.
        ///   - invalidMessage: An optional localized error message, also read by VoiceOver as the field's hint. Defaults to `nil`.
        ///   - isSecuredEntry: Whether the field initially hides its text. Defaults to `true`.
        ///   - displayTextViewBorder: A boolean indicating whether to show a border around the text field. Defaults to `true`.
        public init(
            text: Binding<String>,
            placeholder: LocalizedStringResource,
            leftAccessory: Image? = nil,
            invalid: Bool = false,
            invalidMessage: LocalizedStringResource? = nil,
            isSecuredEntry: Bool = true,
            displayTextViewBorder: Bool = true
        ) {
            self.init(
                text: text,
                placeholderText: .localized(placeholder),
                leftAccessory: leftAccessory,
                invalid: invalid,
                invalidMessageText: invalidMessage.map(LocalizableText.localized),
                isSecuredEntry: isSecuredEntry,
                displayTextViewBorder: displayTextViewBorder
            )
        }

        private init(
            text: Binding<String>,
            placeholderText: LocalizableText,
            leftAccessory: Image?,
            invalid: Bool,
            invalidMessageText: LocalizableText?,
            isSecuredEntry: Bool,
            displayTextViewBorder: Bool
        ) {
            _text = text
            self.placeholderText = placeholderText
            self.leftAccessory = leftAccessory
            self.invalid = invalid
            self.invalidMessageText = invalidMessageText
            self.displayTextViewBorder = displayTextViewBorder
            _isSecuredEntry = .init(initialValue: isSecuredEntry)
        }

        /// The content and behavior of the view.
        public var body: some View {
            VStack(alignment: .leading, spacing: .xxs) {
                HStack(spacing: .spacingSmall) {
                    if let leftAccessory {
                        leftAccessory
                            .renderingMode(.template).scaledToFit()
                            .imageScale(.medium)
                            .frame(width: 24, height: 24)
                            .foregroundColor(iconColor)
                    }

                    Group {
                        if isSecuredEntry {
                            SecureField(text: $text) {
                                placeholderText.text
                            }
                        } else {
                            // Keep revealed passwords out of autocorrection and the keyboard's learned words.
                            TextField(text: $text) {
                                placeholderText.text
                            }
                            .textContentType(.password)
                            .autocorrectionDisabled()
                            #if !os(macOS)
                                .textInputAutocapitalization(.never)
                            #endif
                        }
                    }
                    .font(.body)
                    .foregroundStyle(fgColor)
                    .textFieldStyle(.plain)
                    .focused($focused)
                    .accessibilityHint(invalidMessageText?.text ?? Text(verbatim: ""))

                    Button(action: {
                        isSecuredEntry.toggle()
                    }, label: {
                        Image(systemSymbol: isSecuredEntry ? .eye : .eyeSlash)
                            .renderingMode(.template).scaledToFit()
                            .imageScale(.medium)
                            .frame(width: 24, height: 24)
                            .foregroundColor(iconColor)
                    })
                    .accessibilityLabel(Text(revealButtonAccessibilityLabel))
                }
                .padding(.vertical, .spacingSmall)
                .padding(.horizontal, .xs)
                .background(Material.regular)
                .clipShape(RoundedRectangle(cornerRadius: .xxs))
                .contentShape(RoundedRectangle(cornerRadius: .xxs))
                .overlay(
                    RoundedRectangle(cornerRadius: .xxs)
                        .stroke(
                            borderColor,
                            lineWidth: borderLineWidth
                        )
                )

                if let invalidMessageText {
                    HStack(spacing: .spacingSmall) {
                        Spacer()

                        invalidMessageText.text
                            .font(.caption)
                            .foregroundStyle(fgColor)
                            .lineLimit(3)
                            .padding(.horizontal, .xxs)
                            // VoiceOver reads the message as the field's hint.
                            .accessibilityHidden(true)
                    }
                }
            }
        }

        /// The VoiceOver label of the reveal button, describing the action it performs.
        var revealButtonAccessibilityLabel: LocalizedStringResource {
            isSecuredEntry
                ? LocalizedStringResource("inputPassword.showPassword", bundle: .module)
                : LocalizedStringResource("inputPassword.hidePassword", bundle: .module)
        }

        /// The border width, drawn whenever the border is displayed or the input is invalid.
        var borderLineWidth: CGFloat {
            displayTextViewBorder || invalid ? 2 : 0
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
