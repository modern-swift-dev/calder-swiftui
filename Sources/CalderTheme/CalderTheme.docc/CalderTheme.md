# ``CalderTheme``

Reusable themed controls, layouts, forms, charts, and state views for SwiftUI applications.

Start with ``Theme`` and ``ThemeDefinition`` to define colors and component behavior. Create a
default definition with ``ThemeDefinition/init()`` or customize its colors before injecting it
into the SwiftUI environment. ``Theme`` exposes its definition, color scheme, and contrast so
components can make decisions that depend on the active appearance.

Create Pareto chart categories with ``ParetoChart/RawDataPoint/init(name:value:)`` and pass
them to the chart initializer.

Vertical bar and Pareto charts support empty and all-zero data with a zero axis mark.
Tick counts below one use one interval, and tick spacing is always positive. Pareto
percentages remain finite when all category values are zero.

Calling `BarcodeScannerView.suspend()` suppresses both new scan results and queued delegate
callbacks until `resume()` is called.

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
