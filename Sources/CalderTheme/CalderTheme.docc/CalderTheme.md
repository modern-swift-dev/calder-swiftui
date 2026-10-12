# ``CalderTheme``

Reusable themed controls, layouts, forms, charts, and state views for SwiftUI applications.

## Overview

Start with ``Theme`` and ``ThemeDefinition`` to define colors and component behavior. Create a
default definition with ``ThemeDefinition/init()`` or customize its colors before injecting it
into the SwiftUI environment. ``Theme`` exposes its definition, color scheme, and contrast so
components can make decisions that depend on the active appearance. <doc:Theming> shows how.

### Localized text

Components that display caller-provided text, such as ``MessageBox``, ``ListRowBody``, and
``StatusPill``, accept either a `String` or a `LocalizedStringResource`. A `String`, including a
string literal, is displayed unchanged. A `LocalizedStringResource` is looked up in its own bundle
and table using the environment's locale, for example
`MessageBox(variant: .warn, title: LocalizedStringResource("upload.failed"), message: LocalizedStringResource("upload.retry"))`.
Properties that return a component's text as a `String` resolve localized text for the current
locale. Built-in text, such as the severity VoiceOver announces for a message box, comes from the
string catalog bundled with CalderTheme, which provides English.

Form and input components follow the same rule for their labels, placeholders, and invalid
messages. Their `LocalizedStringResource` initializers require a placeholder. `TextView` formats
its character counter for the environment's locale, for example "1,200 / 5,000 characters" in
English.

## Topics

### Essentials

- <doc:Theming>
- <doc:MigrationNotes>

### Theming

- ``Theme``
- ``ThemeDefinition``
- ``ThemeColor``
- ``SwiftUICore/EnvironmentValues``
- ``SwiftUICore/ColorScheme``

### Forms

- ``FormField``
- ``FormFieldResponsive``
- ``FormHeader``
- ``FormButton``
- ``FormSwitch``
- ``FormDatePicker``

### Text and number inputs

- ``InputText``
- ``InputPassword``
- ``InputNumber``
- ``InputDecimal``
- ``TextView``
- ``AttributedTextView``

### Buttons and toggles

- ``ThemedButtonStyle``
- ``SwiftUI/Button``
- ``SwiftUI/NavigationLink``
- ``ThemedToggleButtonStyle``
- ``CheckboxToggleButtonStyle``
- ``RadioButtonToggleButtonStyle``
- ``SwiftUI/Toggle``

### Selection controls

- ``SegmentedControl``
- ``CheckboxGroup``
- ``RadioButtonGroup``

### Toolbars

- ``ToolbarTitle``
- ``ToolbarButton``
- ``ToolbarMenu``
- ``BarButtonStyle``

### Paginated lists

- <doc:PaginatedLists>
- ``PaginatedList``

### Lists and containers

- ``ListRow``
- ``ListRowBody``
- ``ThemedListCell``
- ``Cardify``
- ``ThemedDisclosureGroupStyle``
- ``Header``
- ``Tile``
- ``Tiles``
- ``SwiftUICore/View``

### Layout

- ``AdaptiveStack``
- ``WrappingHStackLayout``

### Status and content

- ``MessageBox``
- ``StatusPill``
- ``GenericState``
- ``GenericStateView``
- ``Icon``
- ``FramedIcon``
- ``MarkdownView``

### Charts

- ``LineChart``
- ``VerticalBarChart``
- ``HorizontalBarChart``
- ``ParetoChart``
- ``PercentBar``
- ``PercentView``
- ``PercentageCircle``

### Barcodes

- <doc:Barcodes>
- ``BarcodeGeneratorView``

### Deprecated

- ``AdaptativeStack``
