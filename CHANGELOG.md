# Changelog

## 1.2.0 (Unreleased)

This release fixes defects across every module and changes several defaults. Read **Behaviour changes** and **Source-breaking changes** before upgrading. Each module's DocC reference has a "Behavior changes and migration" article with more detail.

### Behaviour changes

- **Hex colour initialisers return `nil` for invalid input (#40).** `Color(rgb:)` is now failable, and `Color(rgba:)`, `UIColor`/`NSColor` `init(rgb:alpha:)`, `init(rgba:)`, `init(hsv:alpha:)`, and `init(hsva:)` return `nil` for non-hexadecimal digits or the wrong number of digits. Previously, invalid digits silently became zero channels, and `Color(rgb:)` and `Color(rgba:)` returned white for a string of the wrong length. Accepted strings have an optional `#`, `0x`, or `0X` prefix and no whitespace. To keep a non-optional colour, supply the fallback explicitly, for example `Color(rgb: hex) ?? .white`, which matches the previous `Color` result for strings of the wrong length; strings with invalid digits no longer produce a colour, so correct them at the source. `ThemeColor`'s hex initialisers keep their signatures and use white for invalid input.
- **`InputPassword` hides its text by default (#33).** `isSecuredEntry` defaults to `true` instead of `false`. To keep the previous behaviour and start with the password revealed, pass `isSecuredEntry: false`.
- `KeyboardObserver` no longer debounces notifications by 150 ms; it applies show, frame-change, and hide notifications in the order they're posted (#37). It ignores frame changes from non-local keyboards and while the keyboard is hidden, so `keyboardSize` stays zero while `visible` is `false` (#38).
- The coordinate, location, and annotation `center()` helpers return the spherical mean instead of the bounding-box midpoint. Empty sequences, and sequences without a defined mean, return `kCLLocationCoordinate2DInvalid` instead of `(0, 0)`; check results with `CLLocationCoordinate2DIsValid(_:)` (#52).
- `coordinateRegion(padding:)` sizes the latitude and longitude deltas from their own axes instead of a square region, and empty sequences return `MKCoordinateRegion()` instead of a whole-globe span (#54).
- `CLLocationCoordinate2D.distanceInMeters(from:)` scales longitude by the cosine of the mean latitude, so east-west distances away from the equator are shorter and `isNear(_:thresholdInMeters:)` matches more coordinates (#53).
- The `MKMapView` overlay insertion helpers keep overlays in the order given, and the `above:` variants insert above the last matching overlay (#55).
- The system-spacing anchor helpers default `multiplier` to `1` instead of `0`. Pass `multiplier: 0` to keep zero spacing (#63).
- `UNUserNotificationCenter.settings` reads the settings of the center it's called on instead of `UNUserNotificationCenter.current()` (#66).
- `UIContentSizeCategory.adjust(webView:)` scales web text with the content size category instead of always using `100%` (#51).
- Child view controller transitions and `fadeOut` remove the outgoing child before calling `completion`, and each containment callback fires once (#62).
- `String.substr(start:len:)` returns the in-range part of a range that runs past the end, such as `"o"` for `"Hello".substr(start: 4, len: 2)`, instead of the whole string (#95).
- The last-row and last-item index-path helpers return `nil` for empty or out-of-range sections instead of row or item 0 (#68).
- The `CGRect` corner and `center` helpers account for the rectangle's origin (#47).
- `UIImage.resize(_:_:_:)` scales the whole image when the aspect ratio isn't kept instead of cropping it, respects the image orientation, and renders at the preferred format scale instead of `UIScreen.main.scale` (#59). `ColorRanges` and its `fuzz` use the 0–255 scale of `ColorRange` (#60).
- `UIView.setViewGradient(...)` reuses one gradient subview and no longer sets `masksToBounds` on the view (#64).
- Code 128 barcodes scale by 2 instead of 1.5, so they're wider than before (#23).
- `PercentView` clamps its value to the documented `0...1` range instead of `0...100` (#83).
- `PaginatedList.Selection.Mode.multi(max: 0)` permits no new selections instead of meaning unlimited; use `nil` for no limit (#99).
- `PaginatedList.DataSource.count` is the server-reported total: every loaded page that includes a count updates it, and local edits leave it unchanged. A data source created with no items starts in the empty state instead of displaying (#98).
- A failed next page keeps the loaded items and page, and reaching the end of the list never reloads the first page (#24).
- `ThemeColor(darken:)` darkens its dark-contrast colour as documented, instead of lightening it (#71).
- `VerticalBarChart` and `ParetoChart` round the axis maximum to the next multiple of the data's order of magnitude instead of the next hundred (#75). `ParetoChart` sorts categories by descending value and clamps negative values to zero (#74).
- The `Double` variant of `InputNumber` parses and displays numbers with the environment locale's decimal separator, rejects text that isn't a number instead of storing `0`, and shows a stored `0` as "0" (#31, #32).
- `MessageBox` looks up the severity VoiceOver announces ("Success", "Information", "Warning", "Error") in CalderTheme's string catalog instead of the app's main bundle. An app that translated these words in its own catalog no longer overrides them (#85, #88).
- `TextView`'s character counter and `InputPassword`'s reveal-button labels ("Show password", "Hide password") come from CalderTheme's string catalog. The counter formats both numbers for the environment's locale, so 1200 of 5000 characters reads "1,200 / 5,000 characters" in English instead of "1200 / 5000 characters" (#89).
- The `PaginatedList` row shown after a next page fails ("Couldn't load more results." and "Retry") looks up its text in CalderTheme's string catalog instead of the app's main bundle (#90).
- Charts and widgets format numbers for the environment's locale. Bar annotations in `VerticalBarChart`, `HorizontalBarChart`, and `ParetoChart` use grouping separators, such as "1,200" instead of "1200" in English. `PercentBar` shows "1,200 / 5,000 values" through a catalog string that translations can reorder. `PercentageCircle` and the `ParetoChart` percentage axis use the environment's locale instead of the current locale; `PercentageCircle.text` still uses the current locale (#91).

### Source-breaking changes

- `Color(rgb:)` returns an optional; unwrap the result (#40).
- `KeyboardObserver` uses the Observation framework. The `$visible`, `$isHardwardKeyboard`, and `$keyboardSize` publishers were removed; observe `objectWillChange` or use Observation instead. `@StateObject` and `@ObservedObject` call sites keep working, and views reading the observer through `@Environment` now update (#36).
- `Array.hashMap(predicate:)` rethrows errors from `predicate` instead of dropping the element, so callers passing a throwing closure must use `try` (#78).
- `BarcodeScannerViewDelegate` is `@MainActor` and `Sendable`, and its `supportedObjectTypes(_:)` requirement is `nonisolated` (#9).
- `UIViewController.CompletionHandler` is `@MainActor () -> Void` instead of `@Sendable () -> Void` (#62).
- `SwiftUISceneDelegate.createRootView(_:)` returns `AnyView` so subclasses can override it; wrap your root view in `AnyView` (#58).
- The retroactive `Sendable` conformances on `UNUserNotificationCenter`, `UNNotificationSettings`, `WKWebsiteDataStore`, and `WKHTTPCookieStore` (#66), and on `AVCaptureSession` and `AVCaptureVideoPreviewLayer` (#10), were removed. Keep these values in one isolation domain.
- `CalderSwiftUI` no longer depends on `SnapshotPreviews`; targets that imported it through `CalderSwiftUI` must declare the dependency themselves (#3).

### Deprecations

- Misspelled names and names that collide with Apple APIs or other libraries were renamed (#86). The old names remain deprecated, so existing code keeps compiling with a warning, and they will be removed in the next major version. Renamed declarations offer an Xcode fix-it; `EdgeInsets.zero` names its replacement in the deprecation message instead. Each module's "Behavior changes and migration" DocC article has a "Migrating to the new names" table.
  - CalderTheme: `AdaptativeStack` → `AdaptiveStack`, `BarcodeSelectoViewController` → `BarcodeSelectorViewController`, `BarcodeSelectoViewControllerDelegate` → `BarcodeSelectorViewControllerDelegate`.
  - CalderSwiftUI: `AdaptativeValue` → `AdaptiveValue`, `adaptativeValue(compact:regular:)` → `adaptiveValue(compact:regular:)`, `disableSharedbackground(disable:)` → `disableSharedBackground(_:)` (the argument defaults to `true`), `EdgeInsets.zero` → SwiftUI's `EdgeInsets()`, and the `NSColor.textColor` instance property → `contrastingTextColor()`.
  - CalderUIKit: `UINavigationController.topViewController()` → `lastViewController()`, `CGFloat.small`/`.medium`/`.large` → `.spacingSmall`/`.spacingMedium`/`.spacingLarge`, `NSUIColor`/`NSUIFont` → `CalderPlatformColor`/`CalderPlatformFont`, and `debugDescription` on `CGFloat`, `CGPoint`, `CGSize`, and `CGRect` → `labeledDebugDescription`. The `CGPoint`, `CGSize`, and `CGRect` descriptions now end with the closing parenthesis they were missing.
- `KeyboardObserver.isHardwardKeyboard` → `isHardwareKeyboard` (#39).
- `UIApplication.suspendApplication()` and `exitApplication(_:code:)` are deprecated. `suspendApplication()` no longer sends a private selector and does nothing; `exitApplication(_:code:)` no longer blocks the main thread or suspends the app first (#67).

### Additions

- CalderTheme bundles a string catalog with English text for its built-in strings (#88).
- `MessageBox`, `ListRowBody`, the card-style `ListRow` initializer, `StatusPill`, `Tile`, `ToolbarTitle`, `ToolbarButton`, `ToolbarMenu`, and the items of `SegmentedControl`, `CheckboxGroup`, and `RadioButtonGroup` accept a `LocalizedStringResource` wherever they accept display text. The `String` initializers, including calls with string literals, still display their text unchanged. Properties that returned the stored `String` now resolve localized text for the current locale (#88).
- `FormButton`, `FormDatePicker`, `FormField`, `FormFieldResponsive`, `FormHeader`, and `FormSwitch` accept a `LocalizedStringResource` label. `InputText`, `InputPassword`, `InputNumber`, `InputDecimal`, `TextView`, and `AttributedTextView` accept a `LocalizedStringResource` placeholder with an optional localized invalid message; these overloads require the placeholder (#89).
- `LineChart`, `VerticalBarChart`, `HorizontalBarChart`, and `ParetoChart` accept `LocalizedStringResource` titles and axis labels, and `PercentBar` accepts a `LocalizedStringResource` suffix. Category names stay `String` values (#91).
- `PaginatedList.DataSource.nextPageError` exposes a failed next page, and the continuous and grouped lists show a row that retries it (#25).
- The barcode scanner and selector show a themed message with an Open Settings button when camera access is denied (#13), and an unavailable message on devices that can't scan (#14). `BarcodeScannerViewController.isSupported` is new, `BarcodeSelectorViewController.isSupported` and `isAvailable` are public, and both controllers have a `themeDefinition` property.
- `BarcodeScanner.ScanResult` is `Sendable` (#12). `BarcodeGeneratorView.Model.generationFailed` reports a payload that can't be encoded, and QR codes accept non-ASCII text (#22).
- `CIImage.WriteError.encodingFailed` is thrown by `writePNG(uiImage:)` and `writeJpeg(uiImage:compression:)` when encoding fails (#65).
- `LayoutConstraintBuilder` supports `if` without `else` and `for` loops (#100).
- `opaqueSeparator`, the `systemFill` family, `lightText`, and `darkText` are available on macOS (#44).
- `SegmentedControl` accepts any `Hashable & Sendable` ID, such as `String` or `Int` (#84).
- Accessibility: Calder toggle styles expose toggle semantics (#79); `FormSwitch` and `FormDatePicker` are labelled with the row name (#80); selected `PaginatedList.Selection` rows (#81) and `SegmentedControl` segments (#84) carry the selected trait; invalid `InputText` and `InputPassword` fields always draw their error border and VoiceOver reads the invalid message as the hint (#82); `PercentView` and `PercentageCircle` expose a localized percentage value (#83); `MessageBox` reads its severity and the themed disclosure group hides its chevron (#85); `InputPassword`'s reveal button has a label and the revealed field disables autocorrection (#34).

### Fixes

- PaginatedList: cancelling a first-page load restores the previous page and state (#26); `replaceAll` discards in-flight requests and resets the page cursor (#27); `append(item:after:)` moves an existing item instead of duplicating its ID (#28); the grouped list loads the next page whichever sections it fills (#29); `Results` encodes `hasNext` and decodes an explicit value (#30).
- Barcode scanning: session work runs on one serial queue, so a stop always follows an earlier start (#9); state changes after creation apply to the scanner (#11); resetting the result to `nil` resumes scanning (#12); low-light boost is enabled when supported (#16); unsupported symbologies are filtered instead of crashing (#17); the preview rotates with `AVCaptureDevice.RotationCoordinator` (#18); the scan tint appears and only one code is delivered per scan (#19); `BarcodeSelector` forwards its recognized types (#20); detected code rects have the correct height (#48).
- Barcode generation: `BarcodeGeneratorView` keeps its image across parent updates (#21), shows an error instead of spinning for unencodable payloads (#22), and renders sharply at 2x and 3x (#23).
- Colours: hex output rounds instead of truncating (#41) and clamps wide-gamut channels (#42); macOS grey levels are distinct and follow the appearance (#43); tvOS backgrounds and fills follow the appearance (#45); `brighten` and `dim` preserve alpha (#46).
- Drawing and images: `CGContext.drawText` draws into the receiving context (#49); `drawStar` is centred and `drawSquare` strokes over its fill (#50); colour masking no longer crashes on unordered ranges and works with alpha images (#60); `base64URLJpg()` encodes JPEG and data URLs have no line breaks (#61); `UIImage` write helpers throw instead of returning a URL to a missing file (#65).
- Maps: clustering completions are called exactly once on every path (#56).
- The image picker popover is anchored to the sender (#96).
- Theme components: success `StatusPill` uses the text-over-success colour (#69); `Tile` labels use the variant's text colour (#70); `WrappingHStackLayout` refreshes cached rows (#72) and proposes each child its own size (#73); `LineChart` honours `nbMarks` and duplicate dates (#76); `AdaptiveStack` preserves child state across size classes (#77); disabled `ToolbarMenu` labels are dimmed once (#97).
- Out-of-range `InputNumber`, `InputDecimal`, and `FormDatePicker` configurations are clamped instead of trapping (#35).

### Packaging, tooling, and documentation

- Dependency requirements use semantic-version ranges instead of exact pins (#2), and CalderTheme's preview snapshots are compiled only in debug builds (#4).
- CI builds with Xcode 27 and Swift 6.4 and tests on the 27.0 simulator runtimes; snapshot baselines are recorded on iPhone 17 Pro with iOS 27.0. CI cancels superseded runs (#8), and pushing a version tag attaches the DocC archive to the GitHub release (#93).
- Each DocC catalog organises its symbols into topics and has a "Behavior changes and migration" article; CalderTheme adds articles for theming, paginated lists, and barcodes (#92). The camera usage requirement is documented (#15), and the README installs a tagged release (#5).
