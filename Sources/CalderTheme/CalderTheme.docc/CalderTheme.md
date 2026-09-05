# ``CalderTheme``

Reusable themed controls, layouts, forms, charts, and state views for SwiftUI applications.

Start with ``Theme`` and ``ThemeDefinition`` to define colors and component behavior. Create a
default definition with ``ThemeDefinition/init()`` or customize its colors before injecting it
into the SwiftUI environment. ``Theme`` exposes its definition, color scheme, and contrast so
components can make decisions that depend on the active appearance.

Create Pareto chart categories with ``ParetoChart/RawDataPoint/init(name:value:)`` and pass
them to the chart initializer.
