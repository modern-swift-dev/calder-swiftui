# Formatted number input component

Calder does not provide an `InputFormattedNumber` component built on `FormatStyle` (currency, percent, clamping to a range, or a stepper).

## Why this is out of scope

`InputNumber` and `InputDecimal` already cover numeric entry in Calder forms: locale-aware parsing and display, digit limits, negative values, and clamped configurations. A second numeric component built on `FormatStyle` would duplicate that surface with a different formatting system, and the open design questions it raised (which styles to support, clamping versus blocking input, steppers on tvOS and watchOS) have no current use case behind them.

Apps that need currency or percent entry can format the bound value themselves around `InputDecimal`, or use SwiftUI's `TextField(value:format:)` directly.

## Prior requests

- #172: "Numeric inputs accept a FormatStyle with clamping and stepper"
