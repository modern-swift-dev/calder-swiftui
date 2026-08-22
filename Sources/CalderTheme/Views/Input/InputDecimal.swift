#if canImport(SwiftUI)
import CalderStdLib
import CalderSwiftUI
import Combine
import RegexBuilder
import SwiftUI

/// A SwiftUI view for inputting decimal numbers with optional formatting and validation.
///
/// This view provides a numeric input field that can handle decimal values,
/// enforcing a maximum number of fraction digits and offering validation feedback.
public struct InputDecimal: View {

    @Environment(\.theme) var theme
    /// A binding to the optional `Double` value that the input field represents.
    @Binding public var value: Double?
    /// The internal `String` representation of the input value, used for text field display.
    @State var textValue: String

    /// The placeholder text displayed when the input field is empty.
    let placeholder: String
    /// A boolean indicating whether to display a border around the text view.
    let displayTextViewBorder: Bool
    /// The maximum number of fraction digits allowed for the decimal input.
    let maxFractionDigits: Int
    /// A `NumberFormatter` configured to use a dot (`.`) as the decimal separator.
    let dotDecimalFormatter: NumberFormatter
    /// A `NumberFormatter` configured to use a comma (`,`) as the decimal separator.
    let commaDecimalFormatter: NumberFormatter
    /// A boolean indicating if the current input is considered invalid.
    let invalid: Bool
    /// An optional message to display when the input is invalid.
    let invalidMessage: String?

    /// Initializes an `InputDecimal` view.
    /// - Parameters:
    ///   - value: A binding to an optional `Double` value that will be displayed and updated by the input.
    ///   - placeholder: The placeholder text to display when the field is empty. Defaults to an empty string.
    ///   - maxFractionDigits: The maximum number of digits allowed after the decimal point. Defaults to 15.
    ///   - displayTextViewBorder: A boolean indicating whether to show a border around the text field. Defaults to `true`.
    ///   - invalid: A boolean indicating if the input is currently in an invalid state, which affects styling. Defaults to `false`.
    ///   - invalidMessage: An optional string message to display when the input is invalid. Defaults to `nil`.
    public init(
        value: Binding<Double?>,
        placeholder: String = "",
        maxFractionDigits: Int = 15,
        displayTextViewBorder: Bool = true,
        invalid: Bool = false,
        invalidMessage: String? = nil
    ) {
        self._value = value
        self.placeholder = placeholder
        self.maxFractionDigits = maxFractionDigits
        self.displayTextViewBorder = displayTextViewBorder
        self.invalid = invalid
        self.invalidMessage = invalidMessage

        let formatter = InputDecimal.dotDecimalFormatter(maxFractionDigits: maxFractionDigits)
        dotDecimalFormatter = formatter
        commaDecimalFormatter = InputDecimal.commaDecimalFormatter(maxFractionDigits: maxFractionDigits)

        if let double = value.wrappedValue,
           let text = formatter.string(from: NSNumber(value: double)) {
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

    /// Parses the input text into an optional `Double` value.
    /// It handles both dot and comma decimal separators and strips trailing separators.
    /// - Parameter input: The string to parse.
    /// - Returns: An optional `Double` value if the input can be parsed, otherwise `nil`.
    func parseInput(_ input: String) -> Double? {
        // step 1: if the string ends with a decimal separator, we must strip it, so we keep only the integer part
        var input = input
        if input.hasSuffix(".") || input.hasSuffix(",") {
            input.removeLast()
        }

        // step 2: empty
        if input.isEmpty {
            return nil
        }

        // step 3: if the input has a comma, we're using the comma decimal formatter
        if input.contains(",") {
            return commaDecimalFormatter.number(from: input)?.doubleValue
        }

        // step 4: we fallback to the dot formatter
        return dotDecimalFormatter.number(from: input)?.doubleValue
    }

    /// Validates if the input text is in a valid format for a decimal or integer.
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
            OneOrMore {
                .digit
            }
            Optionally {
                ChoiceOf {
                    "."
                    ","
                }
            }
            Repeat(0 ... maxFractionDigits) {
                .digit
            }
            Anchor.endOfLine
        }
        let matches = text.matches(of: regex)
        return !matches.isEmpty
    }

    /// Creates and returns a `NumberFormatter` configured for decimal input with a dot (`.`) separator.
    /// - Parameter maxFractionDigits: The maximum number of fraction digits for the formatter.
    /// - Returns: A configured `NumberFormatter` instance.
    static func dotDecimalFormatter(maxFractionDigits: Int) -> NumberFormatter {
        let formatter = NumberFormatter()
        formatter.locale = .posix
        formatter.numberStyle = .decimal
        formatter.decimalSeparator = "."
        formatter.groupingSeparator = ""
        formatter.usesGroupingSeparator = false
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = maxFractionDigits
        formatter.minimumIntegerDigits = 1
        return formatter
    }

    /// Creates and returns a `NumberFormatter` configured for decimal input with a comma (`,`) separator.
    /// - Parameter maxFractionDigits: The maximum number of fraction digits for the formatter.
    /// - Returns: A configured `NumberFormatter` instance.
    static func commaDecimalFormatter(maxFractionDigits: Int) -> NumberFormatter {
        let formatter = NumberFormatter()
        formatter.locale = .posix
        formatter.numberStyle = .decimal
        formatter.decimalSeparator = ","
        formatter.groupingSeparator = ""
        formatter.usesGroupingSeparator = false
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = maxFractionDigits
        formatter.minimumIntegerDigits = 1
        return formatter
    }
}

#endif

#if DEBUG
#if canImport(SwiftUI)
import SnapshotPreviews
import SwiftUI

@MainActor enum InputDecimalPreviews: PreviewProvider, SnapshotProvider {
    static let defaultLayout: PreviewSnapshotLayout = .device

    @SnapshotBuilder static var snapshots: [PreviewSnapshot] {
        PreviewSnapshot("default") {
            InputDecimalPreviewHost()
        }
    }

    private struct InputDecimalPreviewHost: View {
        @Environment(\.theme) private var theme
        @State private var value: Double? = 13.25

        var body: some View {
            VStack {
                InputDecimal(value: $value, displayTextViewBorder: true)
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
