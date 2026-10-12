# Theming components

Define your app's colors once and let every CalderTheme component pick them up from the
environment.

## Overview

A ``ThemeDefinition`` holds the color tokens that CalderTheme components use, such as
``ThemeDefinition/primary``, ``ThemeDefinition/background1``, ``ThemeDefinition/text1``, and the
status colors ``ThemeDefinition/success``, ``ThemeDefinition/warning``, ``ThemeDefinition/error``,
and ``ThemeDefinition/info``. Each token is a ``ThemeColor``, which stores a color for light and
dark appearances and, optionally, for increased contrast.

Components read a ``Theme`` from the environment. The theme combines the environment's
``SwiftUICore/EnvironmentValues/themeDefinition`` with the current color scheme and contrast, and
resolves each token to a SwiftUI `Color`.

### Customize the theme

Start from ``ThemeDefinition/init()``, which provides Calder's default colors, change the tokens
you need, and inject the definition near the root of your view hierarchy:

```swift
import CalderTheme
import SwiftUI

extension ThemeDefinition {
    static var brand: ThemeDefinition {
        var definition = ThemeDefinition()
        definition.primary = ThemeColor(lighten: "#0A7F5A", ratio: 0.1)
        definition.textOverPrimary = ThemeColor(light: .white, dark: .black)
        definition.error = ThemeColor(light: .red, dark: .orange, lightContrast: .red, darkContrast: .yellow)
        return definition
    }
}

struct RootView: View {
    var body: some View {
        ContentView()
            .environment(\.themeDefinition, .brand)
    }
}
```

``ThemeColor`` offers several ways to describe a token:

- ``ThemeColor/init(light:dark:lightContrast:darkContrast:)`` takes explicit colors. A missing
  dark color falls back to the light color, and a missing contrast color falls back to the color
  for the same appearance.
- ``ThemeColor/init(lighten:ratio:lightContrastRatio:darkContrastRatio:)-(String,_,_,_)`` and
  ``ThemeColor/init(darken:ratio:lightContrastRatio:darkContrastRatio:)-(String,_,_,_)`` use a hex
  color in light mode and derive the dark color by lightening or darkening it by `ratio`. Overloads
  that take a `Color` work the same way.
- ``ThemeColor/init(rgb:)`` uses one hex color everywhere.

The hex initializers accept the formats of `Color(rgb:)`. Unlike `Color(rgb:)`, which returns
`nil` for an invalid string, they keep their non-optional signatures and use white instead.

### Use theme colors in your views

Read the theme from the environment to color your own views consistently with Calder's
components:

```swift
struct SavedBanner: View {
    @Environment(\.theme) private var theme

    var body: some View {
        Text("Saved")
            .padding()
            .foregroundStyle(theme.textOverSuccess)
            .background(theme.success)
    }
}
```

Pair each background token with its `textOver` token, such as ``Theme/primary`` with
``Theme/textOverPrimary``, so text stays legible in both appearances. Use
``SwiftUICore/EnvironmentValues/lightTheme`` or ``SwiftUICore/EnvironmentValues/darkTheme`` when
a view needs a specific appearance regardless of the current color scheme.

Many components also take a variant that selects a group of tokens, for example
``ThemedButtonStyle``:

```swift
struct DeleteButton: View {
    var body: some View {
        Button("Delete") {}
            .applyThemedStyle(.medium, variant: .primary(destructive: true))
    }
}
```

### Theme UIKit-hosted components

Components hosted in UIKit, such as the barcode scanner and selector, receive the environment's
theme definition through their SwiftUI wrappers. When you present
`BarcodeScannerViewController` or `BarcodeSelectorViewController` directly, set their
`themeDefinition` property.
