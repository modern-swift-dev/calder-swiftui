#if canImport(SwiftUI)
import CalderUIKit
import SFSafeSymbols
import SwiftUI

/// A SwiftUI view for a single-line text input field.
///
/// This component provides a `TextField` for text entry,
/// supporting leading accessories, placeholder text, and validation messages.
public struct InputText: View {
    private enum Style {
        case validated
        case standard
    }

    /// The theme of the environment.
    @Environment(\.theme) private var theme

    /// The actual value of the text field, as a `String` binding.
    @Binding public var text: String

    /// The placeholder text to display when the input field is empty.
    public let placeholder: String

    /// An optional `Image` to display as a leading accessory in the text field.
    public let leftAccessory: Image?

    /// A boolean indicating if the current input is considered invalid.
    public var invalid: Bool

    /// An optional message to display when the input is invalid.
    public var invalidMessage: String?

    /// Focus state for the text field, allowing programmatic control of focus.
    @FocusState public var focused: Bool

    /// A boolean indicating whether to display a border around the text view.
    public var displayTextViewBorder: Bool

    private let axis: Axis
    private let background: AnyShapeStyle
    private let showBorder: Bool
    private let style: Style
    private let verbatimPlaceholder: String?

    @Environment(\.isEnabled) private var isEnabled

    /// The horizontal size class of the environment.
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    /// Initializes an `InputText` view.
    /// - Parameters:
    ///   - text: A binding to the `String` value of the text field.
    ///   - placeholder: The placeholder text. Defaults to an empty string.
    ///   - leftAccessory: An optional leading image. Defaults to `nil`.
    ///   - displayTextViewBorder: A boolean indicating whether to show a border around the text field. Defaults to `true`.
    ///   - invalid: A boolean indicating if the input is invalid. Defaults to `false`.
    ///   - invalidMessage: An optional error message. Defaults to `nil`.
    public init(
        text: Binding<String>,
        placeholder: String = "",
        leftAccessory: Image? = nil,
        displayTextViewBorder: Bool = true,
        invalid: Bool = false,
        invalidMessage: String? = nil
    ) {
        _text = text
        self.placeholder = placeholder
        self.leftAccessory = leftAccessory
        self.displayTextViewBorder = displayTextViewBorder
        self.invalid = invalid
        self.invalidMessage = invalidMessage
        axis = .horizontal
        background = AnyShapeStyle(Material.regular)
        showBorder = displayTextViewBorder
        style = .validated
        verbatimPlaceholder = nil
    }

    /// Initializes a standard themed text field.
    public init(
        text: Binding<String>,
        placeholder: String,
        axis: Axis = .horizontal,
        background: (any ShapeStyle)? = nil,
        showBorder: Bool = false
    ) {
        _text = text
        self.placeholder = placeholder
        leftAccessory = nil
        invalid = false
        invalidMessage = nil
        displayTextViewBorder = showBorder
        self.axis = axis
        let shape: any ShapeStyle = background ?? Material.thick
        self.background = AnyShapeStyle(shape)
        self.showBorder = showBorder
        style = .standard
        verbatimPlaceholder = nil
    }

    /// Initializes a standard themed text field with its placeholder first.
    public init(
        _ placeholder: String,
        text: Binding<String>,
        axis: Axis = .horizontal,
        background: (any ShapeStyle)? = nil,
        showBorder: Bool = false
    ) {
        self.init(text: text, placeholder: placeholder, axis: axis, background: background, showBorder: showBorder)
    }

    /// Initializes a standard themed text field with a nonlocalized placeholder.
    public init(
        verbatimPlaceholder: String,
        text: Binding<String>,
        axis: Axis = .horizontal,
        background: (any ShapeStyle)? = nil,
        showBorder: Bool = false
    ) {
        _text = text
        placeholder = ""
        leftAccessory = nil
        invalid = false
        invalidMessage = nil
        displayTextViewBorder = showBorder
        self.axis = axis
        let shape: any ShapeStyle = background ?? Material.thick
        self.background = AnyShapeStyle(shape)
        self.showBorder = showBorder
        style = .standard
        self.verbatimPlaceholder = verbatimPlaceholder
    }

    /// The content and behavior of the view.
    public var body: some View {
        switch style {
            case .validated:
                validatedBody
            case .standard:
                standardBody
        }
    }

    private var validatedBody: some View {
        VStack(alignment: .leading, spacing: .xxs) {
            HStack(spacing: .small) {
                if let leftAccessory {
                    leftAccessory
                        .renderingMode(.template).scaledToFit()
                        .imageScale(.medium)
                        .frame(width: 24, height: 24)
                        .foregroundColor(iconColor)
                }

                TextField(
                    placeholder,
                    text: $text
                )
                .focused($focused)
                .font(.body)
                .foregroundStyle(fgColor)
                .textFieldStyle(.plain)
            }
            .padding(.vertical, .small)
            .padding(.horizontal, .xs)
            .foregroundStyle(theme.text1)
            .background(Material.regular)
            .clipShape(RoundedRectangle(cornerRadius: .xxs))
            .contentShape(RoundedRectangle(cornerRadius: .xxs))
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
                        .foregroundStyle(fgColor)
                        .lineLimit(3)
                        .padding(.horizontal, .xxs)
                }
            }

        }
    }

    private var standardBody: some View {
        Group {
            if let verbatimPlaceholder {
                TextField(text: $text, prompt: Text(verbatim: verbatimPlaceholder), axis: axis) {
                    EmptyView()
                }
            } else {
                TextField(placeholder, text: $text, axis: axis)
            }
        }
        .textFieldStyle(.plain)
        .foregroundStyle(isEnabled ? theme.text1 : theme.text2)
        .padding(.small)
        .background(background)
        .contentShape(RoundedRectangle(cornerRadius: .small))
        .clipShape(RoundedRectangle(cornerRadius: .small))
        .overlay {
            RoundedRectangle(cornerRadius: .small)
                .stroke(showBorder ? theme.text3 : theme.transparent, lineWidth: 1)
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

@MainActor enum InputTextPreviews: PreviewProvider, SnapshotProvider {
    static let defaultLayout: PreviewSnapshotLayout = .device

    @SnapshotBuilder static var snapshots: [PreviewSnapshot] {
        PreviewSnapshot("empty") {
            InputTextPreviewHost(initialValue: "", placeholder: "", leftAccessory: nil)
        }

        PreviewSnapshot("placeholder") {
            InputTextPreviewHost(
                initialValue: "",
                placeholder: "Username",
                leftAccessory: Image(systemSymbol: .person)
            )
        }

        PreviewSnapshot("invalid") {
            InputTextPreviewHost(
                initialValue: "",
                placeholder: "Username",
                leftAccessory: Image(systemSymbol: .person),
                invalid: true,
                invalidMessage: "Invalid username"
            )
        }

        PreviewSnapshot("filled") {
            InputTextPreviewHost(
                initialValue: "jwick",
                placeholder: "Username",
                leftAccessory: Image(systemSymbol: .person)
            )
        }

        PreviewSnapshot("standard") {
            StandardInputTextPreviewHost()
        }
    }

    private struct InputTextPreviewHost: View {
        @Environment(\.theme) private var theme
        @State private var value: String

        private let placeholder: String
        private let leftAccessory: Image?
        private let invalid: Bool
        private let invalidMessage: String?

        init(
            initialValue: String,
            placeholder: String,
            leftAccessory: Image?,
            invalid: Bool = false,
            invalidMessage: String? = nil
        ) {
            _value = State(initialValue: initialValue)
            self.placeholder = placeholder
            self.leftAccessory = leftAccessory
            self.invalid = invalid
            self.invalidMessage = invalidMessage
        }

        var body: some View {
            VStack {
                InputText(
                    text: $value,
                    placeholder: placeholder,
                    leftAccessory: leftAccessory,
                    invalid: invalid,
                    invalidMessage: invalidMessage
                )
                Spacer()
            }
            .padding()
            .background(theme.backgroundGradient)
        }
    }

    private struct StandardInputTextPreviewHost: View {
        @Environment(\.theme) private var theme
        @State private var enabledValue = "Filled value"
        @State private var disabledValue = "Disabled value"

        var body: some View {
            VStack(spacing: .small) {
                InputText(
                    text: $enabledValue,
                    placeholder: "Standard input",
                    axis: .vertical,
                    background: theme.background2,
                    showBorder: true
                )

                InputText("Disabled input", text: $disabledValue)
                    .disabled(true)

                Spacer()
            }
            .padding()
            .background(theme.backgroundGradient)
        }
    }
}
#endif
#endif
