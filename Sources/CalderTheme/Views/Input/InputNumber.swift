#if canImport(SwiftUI)
import CalderStdLib
import CalderSwiftUI
import Combine
import RegexBuilder
import SwiftUI

/// A SwiftUI view for inputting integer numbers with optional formatting and validation.
///
/// This view provides a numeric input field that can handle integer values,
/// enforcing a maximum number of integer digits and offering validation feedback.
public struct InputNumber: View {

    @Environment(\.theme) var theme
    /// A binding to the optional `Int64` value that the input field represents.
    @Binding public var value: Int64?
    /// The internal `String` representation of the input value, used for text field display.
    @State var textValue: String

    /// The placeholder text displayed when the input field is empty.
    let placeholder: String
    /// A boolean indicating whether to display a border around the text view.
    let displayTextViewBorder: Bool
    /// The maximum number of integer digits allowed for the number input.
    let maxIntegerDigits: Int
    /// A `NumberFormatter` configured for integer input.
    let numberFormatter: NumberFormatter
    /// A boolean indicating if the current input is considered invalid.
    let invalid: Bool
    /// An optional message to display when the input is invalid.
    let invalidMessage: String?

    /// Initializes an `InputNumber` view.
    /// - Parameters:
    ///   - value: A binding to an optional `Int64` value that will be displayed and updated by the input.
    ///   - placeholder: The placeholder text to display when the field is empty. Defaults to an empty string.
    ///   - maxIntegerDigits: The maximum number of integer digits allowed. Defaults to 15.
    ///   - displayTextViewBorder: A boolean indicating whether to show a border around the text field. Defaults to `true`.
    ///   - invalid: A boolean indicating if the input is currently in an invalid state, which affects styling. Defaults to `false`.
    ///   - invalidMessage: An optional string message to display when the input is invalid. Defaults to `nil`.
    public init(
        value: Binding<Int64?>,
        placeholder: String = "",
        maxIntegerDigits: Int = 15,
        displayTextViewBorder: Bool = true,
        invalid: Bool = false,
        invalidMessage: String? = nil
    ) {
        self._value = value
        self.placeholder = placeholder
        self.maxIntegerDigits = maxIntegerDigits
        self.displayTextViewBorder = displayTextViewBorder
        self.invalid = invalid
        self.invalidMessage = invalidMessage

        let formatter = InputNumber.numberFormatter(maxIntegerDigits: maxIntegerDigits)
        numberFormatter = formatter

        if let intValue = value.wrappedValue,
           let text = formatter.string(from: NSNumber(value: intValue)) {
            textValue = text
        } else {
            textValue = ""
        }
    }

    /// The content and behavior of the view.
    public var body: some View {
        InputText(
            text: $textValue,
            placeholder: placeholder,
            displayTextViewBorder: displayTextViewBorder,
            invalid: invalid,
            invalidMessage: invalidMessage
        )
        #if !os(macOS) && !os(watchOS)
        .keyboardType(.numbersAndPunctuation)
        #endif
        .onChange(of: textValue, initial: false) { oldValue, newValue in
            if oldValue != newValue {
                if !isValidInput(text: newValue) {
                    textValue = oldValue
                    return
                }

                let newDoubleValue = parseInput(newValue)
                if value != newDoubleValue {
                    value = newDoubleValue
                }
            }
        }
    }

    /// Parses the input text into an optional `Int64` value.
    /// - Parameter input: The string to parse.
    /// - Returns: An optional `Int64` value if the input can be parsed, otherwise `nil`.
    func parseInput(_ input: String) -> Int64? {
        // step 1: empty
        if input.isEmpty {
            return nil
        }

        // step 2: we fallback to the dot formatter
        return numberFormatter.number(from: input)?.int64Value
    }

    /// Validates if the input text is in a valid format for an integer.
    /// - Parameter text: The string to validate.
    /// - Returns: `true` if the input is valid, `false` otherwise.
    func isValidInput(text: String) -> Bool {
        if text.isEmpty {
            return true
        }

        let regex = Regex {
            Anchor.startOfLine
            Optionally {
                "-"
            }
            Repeat(1 ... maxIntegerDigits) {
                .digit
            }
            Anchor.endOfLine
        }
        let matches = text.matches(of: regex)
        return !matches.isEmpty
    }

    /// Creates and returns a `NumberFormatter` configured for integer input.
    /// - Parameter maxIntegerDigits: The maximum number of integer digits for the formatter.
    /// - Returns: A configured `NumberFormatter` instance.
    static func numberFormatter(maxIntegerDigits: Int) -> NumberFormatter {
        let formatter = NumberFormatter()
        formatter.locale = .posix
        formatter.numberStyle = .decimal
        formatter.decimalSeparator = "."
        formatter.groupingSeparator = ""
        formatter.usesGroupingSeparator = false
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 0
        formatter.minimumIntegerDigits = 1
        formatter.maximumIntegerDigits = maxIntegerDigits
        return formatter
    }

}

#endif

#if DEBUG
#if canImport(SwiftUI)
import SnapshotPreviews
import SwiftUI

@MainActor enum InputNumberPreviews: PreviewProvider, SnapshotProvider {
    static let defaultLayout: PreviewSnapshotLayout = .device

    @SnapshotBuilder static var snapshots: [PreviewSnapshot] {
        PreviewSnapshot("default") {
            InputNumberPreviewHost()
        }
    }

    private struct InputNumberPreviewHost: View {
        @Environment(\.theme) private var theme
        @State private var value: Int64? = 13

        var body: some View {
            VStack {
                InputNumber(value: $value, displayTextViewBorder: true)
                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: 60)
                Spacer()
            }
            .padding()
            .background(theme.backgroundGradient)
        }
    }
}
#endif
#endif
