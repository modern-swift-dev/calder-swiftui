# Behavior changes and migration

Adapt code to changed component behavior, and move to renamed declarations.

## Overview

The [changelog](https://github.com/modern-swift-dev/calder-swiftui/blob/main/CHANGELOG.md) lists
the changes in each release across all Calder modules. <doc:PaginatedLists> and <doc:Barcodes>
describe the current behavior of paginated lists and barcode views, including changes to data
source counts, next-page failures, multi-selection limits, and scanner state.

### Forms and inputs

`InputPassword` hides its text by default. Pass `isSecuredEntry: false` to start with the
password revealed.

Invalid `InputText` and `InputPassword` fields draw their error border even when
`displayTextViewBorder` is `false`, and VoiceOver reads the invalid message as the field's hint.

`FormSwitch` and `FormDatePicker` use their row name as the control's hidden label, so VoiceOver
announces the name with the control.

Optional numeric inputs update their displayed text when the bound value changes, including
clearing it when the value becomes `nil`. Display formatting does not round or truncate the
source binding.

Numeric inputs accept a minus sign as an intermediate editing state, allowing negative
numbers to be typed from an empty field. The sign alone represents an absent numeric value.

The `Double` binding variant of `InputNumber` parses input with the decimal separator of the
environment's locale, so "12,5" in French and "12.5" in English both store `12.5`. The field
rejects text that isn't a number in that locale instead of storing `0`. The field
displays the bound value, including `0`, in the same locale without grouping separators or
exponent notation.
To keep showing the placeholder for a bound `0`, where `0` means no amount has been entered,
pass `zeroDisplay: .placeholder`.

Out-of-range configurations are clamped instead of trapping: `InputNumber` limits integer digits
to `1...18` so accepted numbers always fit in `Int64`, `InputDecimal` treats a negative fraction
digit limit as `0`, and `FormDatePicker` allows only its minimum date when the maximum is earlier.

### Charts

Charts accept localized titles and axis labels in the same way as other components; category
names stay `String` values. Bar annotations, ``PercentBar`` counts, ``PercentageCircle``, and the
Pareto percentage axis are formatted for the environment's locale. ``PercentBar`` combines its
counts and suffix with a catalog string, so translations can reorder them.

Create Pareto chart categories with ``ParetoChart/RawDataPoint/init(name:value:)`` and pass
them to the chart initializer. The chart plots categories in descending order of value, keeping
the input order for ties, and clamps negative values to zero.

Vertical bar and Pareto charts support empty and all-zero data with a zero axis mark. Their
value axis maximum rounds the largest value up to the next multiple of its own order of
magnitude, so `7` stays `7`, `15` becomes `20`, and `330` becomes `400`.
Tick counts below one use one interval, and tick spacing is always positive. Pareto
percentages remain finite when all category values are zero.

### Migrating to the new names

Misspelled names were corrected. The old names remain as deprecated type aliases, so existing
code keeps compiling with a deprecation warning and an Xcode fix-it. The deprecated names will be
removed in the next major version.

| Deprecated name | Replacement |
| --- | --- |
| `AdaptativeStack` | `AdaptiveStack` |
| `BarcodeSelectoViewController` | `BarcodeSelectorViewController` |
| `BarcodeSelectoViewControllerDelegate` | `BarcodeSelectorViewControllerDelegate` |
