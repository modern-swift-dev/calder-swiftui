# Changelog

## Unreleased

### Behaviour changes

- Hex colour initialisers return `nil` for invalid input. `Color(rgb:)` is now failable, and `Color(rgba:)`, `UIColor`/`NSColor` `init(rgb:alpha:)`, `init(rgba:)`, `init(hsv:alpha:)`, and `init(hsva:)` return `nil` for non-hexadecimal digits or the wrong number of digits, instead of black or white. Accepted strings have an optional `#`, `0x`, or `0X` prefix and no whitespace. To adapt, unwrap the result, for example `Color(rgb: hex) ?? .white`. `ThemeColor`'s hex initialisers keep their signatures and use white for invalid input.

- `InputPassword` now hides its text by default: `isSecuredEntry` defaults to `true` instead of `false`. To keep the previous behaviour and start with the password revealed, pass `isSecuredEntry: false`.

- `MessageBox` looks up the severity VoiceOver announces ("Success", "Information", "Warning", "Error") in CalderTheme's string catalog instead of the app's main bundle. An app that translated these words in its own catalog no longer overrides them.

### Additions

- CalderTheme bundles a string catalog with English text for its built-in strings.
- `MessageBox`, `ListRowBody`, the card-style `ListRow` initializer, `StatusPill`, `Tile`, `ToolbarTitle`, `ToolbarButton`, `ToolbarMenu`, and the items of `SegmentedControl`, `CheckboxGroup`, and `RadioButtonGroup` accept a `LocalizedStringResource` wherever they accept display text. The `String` initializers, including calls with string literals, still display their text unchanged. Properties that returned the stored `String` now resolve localized text for the current locale.
