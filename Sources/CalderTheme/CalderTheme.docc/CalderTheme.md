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
