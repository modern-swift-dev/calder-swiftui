# Changelog

## Unreleased

### Behaviour changes

- Hex colour initialisers return `nil` for invalid input. `Color(rgb:)` is now failable, and `Color(rgba:)`, `UIColor`/`NSColor` `init(rgb:alpha:)`, `init(rgba:)`, `init(hsv:alpha:)`, and `init(hsva:)` return `nil` for non-hexadecimal digits or the wrong number of digits, instead of black or white. Accepted strings have an optional `#`, `0x`, or `0X` prefix and no whitespace. To adapt, unwrap the result, for example `Color(rgb: hex) ?? .white`. `ThemeColor`'s hex initialisers keep their signatures and use white for invalid input.

- `InputPassword` now hides its text by default: `isSecuredEntry` defaults to `true` instead of `false`. To keep the previous behaviour and start with the password revealed, pass `isSecuredEntry: false`.
