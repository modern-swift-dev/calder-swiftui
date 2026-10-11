# Changelog

## Unreleased

### Behaviour changes

- Hex colour initialisers return `nil` for invalid input. `Color(rgb:)` is now failable, and `Color(rgba:)`, `UIColor`/`NSColor` `init(rgb:alpha:)`, `init(rgba:)`, `init(hsv:alpha:)`, and `init(hsva:)` return `nil` for non-hexadecimal digits or the wrong number of digits, instead of black or white. Accepted strings have an optional `#`, `0x`, or `0X` prefix and no whitespace. To adapt, unwrap the result, for example `Color(rgb: hex) ?? .white`. `ThemeColor`'s hex initialisers keep their signatures and use white for invalid input.

- `InputPassword` now hides its text by default: `isSecuredEntry` defaults to `true` instead of `false`. To keep the previous behaviour and start with the password revealed, pass `isSecuredEntry: false`.

- `MessageBox` looks up the severity VoiceOver announces ("Success", "Information", "Warning", "Error") in CalderTheme's string catalog instead of the app's main bundle. An app that translated these words in its own catalog no longer overrides them.

- `TextView`'s character counter and `InputPassword`'s reveal-button labels ("Show password", "Hide password") come from CalderTheme's string catalog. The counter formats both numbers for the environment's locale, so 1200 of 5000 characters reads "1,200 / 5,000 characters" in English instead of "1200 / 5000 characters".

- The `PaginatedList` row shown after a next page fails ("Couldn't load more results." and "Retry") looks up its text in CalderTheme's string catalog instead of the app's main bundle.

- Charts and widgets format numbers for the environment's locale. Bar annotations in `VerticalBarChart`, `HorizontalBarChart`, and `ParetoChart` use grouping separators, such as "1,200" instead of "1200" in English. `PercentBar` shows "1,200 / 5,000 values" through a catalog string that translations can reorder. `PercentageCircle` and the `ParetoChart` percentage axis use the environment's locale instead of the current locale; `PercentageCircle.text` still uses the current locale.

### Additions

- CalderTheme bundles a string catalog with English text for its built-in strings.
- `MessageBox`, `ListRowBody`, the card-style `ListRow` initializer, `StatusPill`, `Tile`, `ToolbarTitle`, `ToolbarButton`, `ToolbarMenu`, and the items of `SegmentedControl`, `CheckboxGroup`, and `RadioButtonGroup` accept a `LocalizedStringResource` wherever they accept display text. The `String` initializers, including calls with string literals, still display their text unchanged. Properties that returned the stored `String` now resolve localized text for the current locale.
- `FormButton`, `FormDatePicker`, `FormField`, `FormFieldResponsive`, `FormHeader`, and `FormSwitch` accept a `LocalizedStringResource` label. `InputText`, `InputPassword`, `InputNumber`, `InputDecimal`, `TextView`, and `AttributedTextView` accept a `LocalizedStringResource` placeholder with an optional localized invalid message; these overloads require the placeholder.
- `LineChart`, `VerticalBarChart`, `HorizontalBarChart`, and `ParetoChart` accept `LocalizedStringResource` titles and axis labels, and `PercentBar` accepts a `LocalizedStringResource` suffix. Category names stay `String` values.
