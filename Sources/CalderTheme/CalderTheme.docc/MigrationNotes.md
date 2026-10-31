# Behavior changes and migration

Adapt code to changed component behavior, and move to renamed declarations.

## Overview

The [changelog](https://github.com/modern-swift-dev/calder-swiftui/blob/main/CHANGELOG.md) lists
the changes in each release across all Calder modules. <doc:PaginatedLists> and <doc:Barcodes>
describe the current behavior of paginated lists and barcode views, including changes to data
source counts, next-page failures, multi-selection limits, and scanner state.

### Paginated lists

`PaginatedList.DataSource` keeps loaded items visible while it reloads, so its `state` stays
`.displaying` during a refresh instead of becoming `.loading`. A failed refresh keeps the items,
count, and page and sets `refreshError` instead of clearing the list; show that error yourself,
for example in an alert. A failed first load with no loaded items sets `state` to `.error` with
the error's `localizedDescription`, so ``GenericStateView`` shows the message.

The data source's state is `.empty` only when no items are loaded and no next page remains. When
the loaded items are empty but the server has more pages, the state is `.displaying`, so the list
shows its loading row and requests the next page.

`PaginatedList.Selection` writes to its selection binding when the data source's items change:
selected items removed from the data source, or missing after a reload, are deselected, and the
remaining selected items take their newly loaded values.

``PaginatedList`` is a caseless enum rather than a class. Code that created a `PaginatedList()`
instance or subclassed it no longer compiles; refer to the nested types, such as
`PaginatedList.DataSource`, directly.

The synchronous `reload()` of `PaginatedList.DataSource` returns the `Task` that performs the
reload. Await `reload().value` to wait for it, or call `cancel()` on it to cancel the reload.

A data source created with `init(items:)` keeps its items when it reloads: `reload()` and `load()`
do nothing until you call `configureAndLoad(firstPageLoader:nextPageLoader:)`. Previously a reload
brought back the items passed to the initializer, undoing later edits such as `replaceAll(values:)`.
To reset an in-memory source, call `replaceAll(values:)` with the items you want.

Paginated list items no longer need to be `Codable`: the data source and lists require only
`Identifiable` and `Sendable`. `PaginatedList.Results` is `Codable` when its items are, so existing
decoding code is unchanged.

`PaginatedList.Grouped` sorts its sections with `localizedStandardCompare(_:)`, as the Finder sorts
file names, instead of comparing the grouping keys code point by code point. Lowercase and accented
keys sort with their letters, and numbers in keys sort by value. To choose another order, pass a
`sectionOrder` comparator, such as
`String.StandardComparator(.localizedStandard, order: .reverse)`.

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

`InputNumber`'s `maxIntegerDigits` limits typing only. A bound value with more digits is displayed in
full and round-trips unchanged; typing a longer number is still rejected.

`TextView` and `AttributedTextView` treat a negative `maxLength` as 0 instead of trapping. They cut text
that is already longer than `maxLength` when the view appears, so the character counter never reads
more than the limit.

`CheckboxToggleButtonStyle` and `RadioButtonToggleButtonStyle` apply their `style` to the label, which
previously always used the medium (body) font. The `applyCheckboxToggleStyle` and
`applyRadioButtonToggleStyle` modifiers now default to `.medium` instead of `.large`, so default labels,
including those in ``CheckboxGroup`` and ``RadioButtonGroup``, keep their previous size. The checkbox and
radio icons always followed `style`, so with the new default they are one text size larger. Code that passes
`style: .large` or `.small` explicitly now gets that size for the label too, instead of the body font.

Numeric inputs accept a minus sign as an intermediate editing state, allowing negative
numbers to be typed from an empty field. The sign alone represents an absent numeric value.

The `Double` binding variant of `InputNumber` parses input with the decimal separator of the
environment's locale, so "12,5" in French and "12.5" in English both store `12.5`. The field
rejects text that isn't a number in that locale instead of storing `0`. The field
displays the bound value, including `0`, in the same locale without grouping separators or
exponent notation.
To keep showing the placeholder for a bound `0`, where `0` means no amount has been entered,
pass `zeroDisplay: .placeholder`.

The `Double` variant of `InputNumber` shows the `.numbersAndPunctuation` keyboard by default, because
`.decimalPad` has no minus key and the field accepts negative numbers. Pass `keyboardType: .decimalPad`
to keep the previous keyboard. The field accepts the decimal separator shown by the device's keyboard
in addition to the environment locale's, so typed input isn't rejected when the two differ, and it
accepts the Unicode minus sign (U+2212) used by locales such as Swedish.

Out-of-range configurations are clamped instead of trapping: `InputNumber` limits integer digits
to `1...18` so accepted numbers always fit in `Int64`, `InputDecimal` treats a negative fraction
digit limit as `0`, and `FormDatePicker` allows only its minimum date when the maximum is earlier.

### Charts

Charts accept localized titles and axis labels in the same way as other components; category
names stay `String` values. Bar annotations, ``PercentBar`` counts, ``PercentageCircle``, and the
Pareto percentage axis are formatted for the environment's locale. ``PercentBar`` combines its
counts and suffix with a catalog string, so translations can reorder them.

Charts support Audio Graphs. ``VerticalBarChart``, ``HorizontalBarChart``, ``LineChart``, and
``ParetoChart`` describe their axes and values to VoiceOver with localized titles and
locale-formatted values. The Pareto cumulative line is read as percentages, such as "100%", instead
of the bar-axis value it is plotted at.

Create Pareto chart categories with ``ParetoChart/RawDataPoint/init(name:value:)`` and pass
them to the chart initializer. The chart plots categories in descending order of value, keeping
the input order for ties, and clamps negative values to zero.

Vertical bar and Pareto charts support empty and all-zero data with a zero axis mark. Their
value axis maximum rounds the largest value up to the next multiple of its own order of
magnitude, so `7` stays `7`, `15` becomes `20`, and `330` becomes `400`.
``VerticalBarChart`` plots negative values below zero: its axis starts at the most negative value
rounded down in the same way, such as `-50` for `-42`, and has a mark at that minimum.
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
