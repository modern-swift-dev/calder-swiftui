#if canImport(SwiftUI) || canImport(UIKit) || canImport(AppKit)
import CalderStdLib
@testable import CalderTheme
import SwiftUI
import Testing

@Suite(.serialized)
@MainActor struct InputNumericTests {

    @Test func `input decimal initializes text value from binding`() {
        var value: Double? = 12.34
        let input = InputDecimal(
            value: Binding(get: { value }, set: { value = $0 }),
            placeholder: "Amount",
            maxFractionDigits: 2,
            displayTextViewBorder: false,
            invalid: true,
            invalidMessage: "Invalid"
        )

        #expect(input.textValue == "12.34")
        #expect(input.placeholder == "Amount")
        #expect(input.maxFractionDigits == 2)
        #expect(!input.displayTextViewBorder)
        #expect(input.invalid)
        #expect(input.invalidMessage == "Invalid")
        _ = input.body
    }

    @Test func `input decimal parses dot comma trailing separator and empty values`() {
        var value: Double?
        let input = InputDecimal(value: Binding(get: { value }, set: { value = $0 }), maxFractionDigits: 3)

        #expect(input.parseInput("12.5") == 12.5)
        #expect(input.parseInput("12,5") == 12.5)
        #expect(input.parseInput("12.") == 12)
        #expect(input.parseInput("12,") == 12)
        #expect(input.parseInput("") == nil)
    }

    @Test func `input decimal validates maximum fraction digits and sign`() {
        var value: Double?
        let input = InputDecimal(value: Binding(get: { value }, set: { value = $0 }), maxFractionDigits: 2)

        #expect(input.isValidInput(text: ""))
        #expect(input.isValidInput(text: "12"))
        #expect(input.isValidInput(text: "-12"))
        #expect(input.isValidInput(text: "12.34"))
        #expect(input.isValidInput(text: "12,34"))
        #expect(!input.isValidInput(text: "12.345"))
        #expect(!input.isValidInput(text: "abc"))
        #expect(!input.isValidInput(text: "12.3.4"))
    }

    @Test func `decimal formatters use posix separators and fraction limits`() {
        let dot = InputDecimal.dotDecimalFormatter(maxFractionDigits: 2)
        let comma = InputDecimal.commaDecimalFormatter(maxFractionDigits: 2)

        #expect(dot.locale == .posix)
        #expect(dot.decimalSeparator == ".")
        #expect(dot.maximumFractionDigits == 2)
        #expect(comma.locale == .posix)
        #expect(comma.decimalSeparator == ",")
        #expect(comma.maximumFractionDigits == 2)
    }

    @Test func `input number initializes text value from binding`() {
        var value: Int64? = 123
        let input = InputNumber(
            value: Binding(get: { value }, set: { value = $0 }),
            placeholder: "Count",
            maxIntegerDigits: 4,
            displayTextViewBorder: false,
            invalid: true,
            invalidMessage: "Invalid"
        )

        #expect(input.textValue == "123")
        #expect(input.placeholder == "Count")
        #expect(input.maxIntegerDigits == 4)
        #expect(!input.displayTextViewBorder)
        #expect(input.invalid)
        #expect(input.invalidMessage == "Invalid")
        _ = input.body
    }

    @Test func `input number parses integer and empty values`() {
        var value: Int64?
        let input = InputNumber(value: Binding(get: { value }, set: { value = $0 }), maxIntegerDigits: 3)

        #expect(input.parseInput("123") == 123)
        #expect(input.parseInput("-123") == -123)
        #expect(input.parseInput("") == nil)
    }

    @Test func `input number validates maximum integer digits and sign`() {
        var value: Int64?
        let input = InputNumber(value: Binding(get: { value }, set: { value = $0 }), maxIntegerDigits: 3)

        #expect(input.isValidInput(text: ""))
        #expect(input.isValidInput(text: "123"))
        #expect(input.isValidInput(text: "-123"))
        #expect(!input.isValidInput(text: "1234"))
        #expect(!input.isValidInput(text: "12.3"))
        #expect(!input.isValidInput(text: "abc"))
    }

    @Test func `optional numeric binding updates format replacements and clear absent values`() {
        let integer = InputNumber(value: .constant(12))
        #expect(integer.formattedText(for: 34) == "34")
        #expect(integer.formattedText(for: nil) == "")

        let decimal = InputDecimal(value: .constant(12.5), maxFractionDigits: 2)
        #expect(decimal.formattedText(for: 34.25) == "34.25")
        #expect(decimal.formattedText(for: nil) == "")
    }

    @Test func `numeric inputs accept each step when typing a negative number`() {
        let integer = InputNumber(value: .constant(nil))
        let decimal = InputDecimal(value: .constant(nil))

        for text in ["", "-", "-1", "-12"] {
            #expect(integer.isValidInput(text: text))
            #expect(decimal.isValidInput(text: text))
        }
        #expect(integer.parseInput("-") == nil)
        #expect(decimal.parseInput("-") == nil)
        #expect(integer.parseInput("-12") == -12)
        #expect(decimal.parseInput("-12.5") == -12.5)
    }

    @Test func `number formatter uses posix separator and integer limit`() {
        let formatter = InputNumber.numberFormatter(maxIntegerDigits: 3)

        #expect(formatter.locale == .posix)
        #expect(formatter.decimalSeparator == ".")
        #expect(formatter.maximumIntegerDigits == 3)
        #expect(formatter.maximumFractionDigits == 0)
    }
}

#endif
