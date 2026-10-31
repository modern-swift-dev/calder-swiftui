# Behavior changes and migration

Adapt code to hex color, keyboard observation, and renamed declaration changes.

## Overview

The [changelog](https://github.com/modern-swift-dev/calder-swiftui/blob/main/CHANGELOG.md) lists
the changes in each release across all Calder modules.

### Hex colors

`Color(rgb:)` is now failable, and both `Color(rgb:)` and `Color(rgba:)` return `nil` for strings with non-hexadecimal digits or the wrong number of digits instead of producing black or white. Accepted strings have an optional `#`, `0x`, or `0X` prefix and no whitespace. To keep a non-optional color, supply the fallback explicitly, for example `Color(rgb: hex) ?? .white`. Hex output from `rgb` and `rgba` rounds each channel instead of truncating it and clamps wide-gamut values to `00`–`FF`.

### Text color contrast

`contrastingTextColor(light:dark:)` on `UIColor`, `NSColor`, and `Color`, and `Color.textColor`, now return whichever candidate has the higher WCAG 2.x contrast ratio against the receiver, instead of comparing the receiver's luma with `0.5`. The two rules agree for most colors, but saturated mid-tones now get dark text: pure red gets black text (contrast ratio 5.25) where it previously got white (4.00). Alpha is ignored and `dark` wins a tie. To measure the ratio yourself, use the new `contrastRatio(with:)`; the `Color` version takes an `in:` environment that resolves both colors, and defaults to a default `EnvironmentValues`.

`Color.contrastingTextColor(light:dark:)` now returns a `Color` instead of a `UIColor` or `NSColor`, so it matches `Color.textColor` and the rest of the `Color` API. It returns the `light` or `dark` argument unchanged and takes an `in:` environment that resolves the colors. Code that needs the platform color wraps the result: `UIColor(color.contrastingTextColor())` or `NSColor(color.contrastingTextColor())`. Code that used the result as a `Color` after `.asSwiftUIColor` or `Color(uiColor:)` can drop the conversion.

### Keyboard observation

`KeyboardObserver` now uses the Observation framework instead of `@Published` properties. Views that read the observer through `@Environment(\.keyboardObserver)` now update when keyboard state changes. Prefer `@State` to own an observer and `@Environment` or a plain property to read one. The observer still conforms to `ObservableObject` and sends `objectWillChange` before each state change, so existing `@StateObject` and `@ObservedObject` call sites keep compiling and updating. Code that subscribed to the removed `$visible`, `$isHardwardKeyboard`, or `$keyboardSize` publishers must observe `objectWillChange` or use Observation instead.

The misspelled `KeyboardObserver.isHardwardKeyboard` property was removed. Use `isHardwareKeyboard` instead.

`KeyboardObserver` no longer debounces keyboard notifications by 150 milliseconds. It applies show, frame-change, and hide notifications on the main actor one at a time, in the order they are posted.

`KeyboardObserver` ignores frame-change notifications from non-local keyboards and frame changes received while the keyboard is hidden, so `keyboardSize` stays zero while `visible` is false.

`KeyboardObserver` also ignores hide notifications from non-local keyboards, such as a keyboard shown by another app in Split View. Only a hide notification from the local keyboard resets `visible`, `isHardwareKeyboard`, and `keyboardSize`.

### Migrating to the new names

Misspelled names, and names that collide with Apple APIs, were replaced. The old names remain
deprecated, so existing code keeps compiling with a deprecation warning. Renamed declarations
also offer an Xcode fix-it. The deprecated names will be removed in the next major version.

| Deprecated name | Replacement |
| --- | --- |
| `AdaptativeValue` | `AdaptiveValue` |
| `UserInterfaceSizeClass?.adaptativeValue(compact:regular:)` | `adaptiveValue(compact:regular:)` |
| `ToolbarContent.disableSharedbackground(disable:)` | `disableSharedBackground(_:)`, whose argument defaults to `true` |
| `EdgeInsets.zero` | SwiftUI's `EdgeInsets()`, which also creates zero insets. There's no fix-it; replace `.zero` with `EdgeInsets()` where the type is `EdgeInsets`. |
| `NSColor.textColor` (instance property) | `contrastingTextColor()`. The instance property shared its name with AppKit's `NSColor.textColor` system color. |
| `UIColor.textColor` (instance property) | `contrastingTextColor()`, as on `NSColor`. |
| `CGFloat.asEdgeInsets` | CalderUIKit's `CGFloat.edgeInset`, which returns the same `EdgeInsets` and sits next to `uiEdgeInset` and `directionalEdgeInset`. |
