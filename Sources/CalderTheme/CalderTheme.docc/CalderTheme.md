# ``CalderTheme``

Reusable themed controls, layouts, forms, charts, and state views for SwiftUI applications.

Start with ``Theme`` and ``ThemeDefinition`` to define colors and component behavior. Create a
default definition with ``ThemeDefinition/init()`` or customize its colors before injecting it
into the SwiftUI environment. ``Theme`` exposes its definition, color scheme, and contrast so
components can make decisions that depend on the active appearance.

Create Pareto chart categories with ``ParetoChart/RawDataPoint/init(name:value:)`` and pass
them to the chart initializer. The chart plots categories in descending order of value, keeping
the input order for ties, and clamps negative values to zero.

Vertical bar and Pareto charts support empty and all-zero data with a zero axis mark. Their
value axis maximum rounds the largest value up to the next multiple of its own order of
magnitude, so `7` stays `7`, `15` becomes `20`, and `330` becomes `400`.
Tick counts below one use one interval, and tick spacing is always positive. Pareto
percentages remain finite when all category values are zero.

Calling `BarcodeScannerView.suspend()` suppresses both new scan results and queued delegate
callbacks until `resume()` is called.

`BarcodeGeneratorView` generates its image off the main thread and keeps it across parent view
updates; it regenerates only when the code or barcode type changes. `BarcodeGeneratorView.Model`
is main-actor isolated. When the payload cannot be encoded, the view shows an error instead of a
progress indicator.

`BarcodeScannerView` configures, starts, and stops its capture session on one serial session
queue, so `start()` and `stop()` return without blocking the main thread and a stop always runs
after an earlier start. `BarcodeScannerViewDelegate` is main-actor isolated and `Sendable`; its
`supportedObjectTypes(_:)` requirement is `nonisolated` because the scanner calls it on the
session queue while configuring the session.

The scanner's metadata output delivers to a background metadata queue: the nonisolated
`metadataOutput(_:didOutput:from:)` hands each detected code to the main actor, which reports it
to `onCodeScanned(_:type:rect:path:)`. CalderTheme no longer declares retroactive `Sendable`
conformances on `AVCaptureSession` or `AVCaptureVideoPreviewLayer`.

`BarcodeScanner` applies changes to its `state` after creation: `.suspended` pauses detection,
`.scanning` resumes it (restarting the camera after `.finished`), and `.finished` stops the
camera. The scanner pauses after it writes a result; set the `result` binding back to `nil` to
scan the next code without recreating the view.

Optional numeric inputs update their displayed text when the bound value changes, including
clearing it when the value becomes `nil`. Display formatting does not round or truncate the
source binding.

Numeric inputs accept a minus sign as an intermediate editing state, allowing negative
numbers to be typed from an empty field. The sign alone represents an absent numeric value.

A failed next page in `PaginatedList.DataSource` keeps the loaded items and the current page.
Reaching the end of the list again never reloads the first page. The failure is exposed as
`nextPageError`, and the continuous and grouped lists show a row that retries the failed page.
The grouped list requests the next page when its end is reached, whichever sections the page fills.

Cancelling a first-page load or reload keeps the loaded items and restores the page and state
from before loading, so pagination continues and the load can be retried.

`PaginatedList.DataSource.replaceAll` discards results from requests started before it. Replacing
with a `Results` page makes it the current page; replacing with values ends pagination.

`PaginatedList.DataSource.append(item:after:)` moves and updates an item that is already
loaded instead of inserting a duplicate ID.

`PaginatedList.Results` encodes `hasNext`. Decoding uses an explicit `hasNext` value when present
and otherwise derives it from `next` and `results`.

`PaginatedList.DataSource.count` is the total reported by the server. Every loaded page that
includes a count updates it, while local edits leave it unchanged. A data source created with no
items starts in the empty state.

`PaginatedList.Selection.Mode.multi(max:)` expresses no limit only with `nil`. A maximum of `0`
permits no new selections, while selected items can still be deselected.

Selected `PaginatedList.Selection` rows carry the `isSelected` accessibility trait.

The `Double` binding variant of `InputNumber` parses input with the decimal separator of the
environment's locale, so "12,5" in French and "12.5" in English both store `12.5`. The field
rejects text that isn't a number in that locale instead of storing `0`. The field
displays the bound value, including `0`, in the same locale without grouping separators or
exponent notation.

Out-of-range configurations are clamped instead of trapping: `InputNumber` limits integer digits
to `1...18` so accepted numbers always fit in `Int64`, `InputDecimal` treats a negative fraction
digit limit as `0`, and `FormDatePicker` allows only its minimum date when the maximum is earlier.

`InputPassword` hides its text by default. Pass `isSecuredEntry: false` to start with the
password revealed.

Invalid `InputText` and `InputPassword` fields draw their error border even when
`displayTextViewBorder` is `false`, and VoiceOver reads the invalid message as the field's hint.

`FormSwitch` and `FormDatePicker` use their row name as the control's hidden label, so VoiceOver
announces the name with the control.
