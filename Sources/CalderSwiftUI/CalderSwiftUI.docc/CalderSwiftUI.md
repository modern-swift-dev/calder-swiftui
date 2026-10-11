# ``CalderSwiftUI``

SwiftUI values, views, environment support, and extensions.

The module includes async-value rendering, color conversion, gradients, image conversion, and view helpers.

On platforms that support keyboard observation, `KeyboardObserver` and the `keyboardObserver` environment value are main-actor isolated. Create observers and access their state from `@MainActor` code. The environment retains a shared default observer; supplying a custom observer through `.environment(\.keyboardObserver, observer)` overrides it for that environment. Each observer maintains its notification subscriptions for its lifetime.

## Behavior and migration notes

`KeyboardObserver` now uses the Observation framework instead of `@Published` properties. Views that read the observer through `@Environment(\.keyboardObserver)` now update when keyboard state changes. Prefer `@State` to own an observer and `@Environment` or a plain property to read one. The observer still conforms to `ObservableObject` and sends `objectWillChange` before each state change, so existing `@StateObject` and `@ObservedObject` call sites keep compiling and updating. Code that subscribed to the removed `$visible`, `$isHardwardKeyboard`, or `$keyboardSize` publishers must observe `objectWillChange` or use Observation instead.

`KeyboardObserver.isHardwardKeyboard` is deprecated. Use `isHardwareKeyboard` instead; the deprecated property returns the same value.

`KeyboardObserver` no longer debounces keyboard notifications by 150 milliseconds. It applies show, frame-change, and hide notifications on the main actor one at a time, in the order they are posted.

`KeyboardObserver` ignores frame-change notifications from non-local keyboards and frame changes received while the keyboard is hidden, so `keyboardSize` stays zero while `visible` is false.

## Migrating to the new names

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
