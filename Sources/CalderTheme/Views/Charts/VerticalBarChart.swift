#if canImport(SwiftUI)
    import Accessibility
    import CalderUIKit
    import Charts
    import Foundation
    import SwiftUI

    /// A SwiftUI view representing a vertical bar chart.
    public struct VerticalBarChart: View {

        /// The current theme, injected via Environment.
        @Environment(\.theme) var theme

        /// The locale used to describe the chart's values to Audio Graphs.
        @Environment(\.locale) private var locale

        /// Represents a data point for the vertical bar chart.
        public struct DataPoint {
            /// The category name for the bar (X-axis).
            let name: String
            /// The value associated with the category (Y-axis).
            let value: Int

            /// Initializes a `DataPoint` with a name and value.
            /// - Parameters:
            ///   - name: The category name.
            ///   - value: The numerical value.
            public init(name: String, value: Int) {
                self.name = name
                self.value = value
            }
        }

        /// The requested number of intervals on the Y-axis. Values below one use one interval.
        public var nbMarks: Int

        private var titleText: LocalizableText
        private var xAxisLabelText: LocalizableText
        private var yAxisTitleText: LocalizableText

        /// The title of the chart.
        ///
        /// A title created from a `LocalizedStringResource` is resolved for the current locale.
        /// Assigning a string replaces it with a title displayed unchanged.
        ///
        /// - Note: Deprecated because it resolves a `LocalizedStringResource` with the process locale, which can
        ///   differ from the locale the view renders in. Use ``titleResource``.
        @available(
            *,
            deprecated,
            message: "Resolves with the process locale, which can differ from the rendered text. Use titleResource: set its locale to the one you need and resolve it with String(localized:)."
        )
        public var title: String {
            get { titleText.resolved }
            set { titleText = .verbatim(newValue) }
        }

        /// The title as a localized string resource.
        ///
        /// Set its `locale` to the locale you need and resolve it with `String(localized:)`. A title created
        /// from a `String` resolves to that string unchanged in every locale. Assigning a resource replaces it.
        public var titleResource: LocalizedStringResource {
            get { titleText.resource }
            set { titleText = .localized(newValue) }
        }

        /// The label for the X-axis.
        ///
        /// A label created from a `LocalizedStringResource` is resolved for the current locale.
        /// Assigning a string replaces it with a label displayed unchanged.
        ///
        /// - Note: Deprecated because it resolves a `LocalizedStringResource` with the process locale, which can
        ///   differ from the locale the view renders in. Use ``xAxisLabelResource``.
        @available(
            *,
            deprecated,
            message: "Resolves with the process locale, which can differ from the rendered text. Use xAxisLabelResource: set its locale to the one you need and resolve it with String(localized:)."
        )
        public var xAxisLabel: String {
            get { xAxisLabelText.resolved }
            set { xAxisLabelText = .verbatim(newValue) }
        }

        /// The label as a localized string resource.
        ///
        /// Set its `locale` to the locale you need and resolve it with `String(localized:)`. A label created
        /// from a `String` resolves to that string unchanged in every locale. Assigning a resource replaces it.
        public var xAxisLabelResource: LocalizedStringResource {
            get { xAxisLabelText.resource }
            set { xAxisLabelText = .localized(newValue) }
        }

        /// The label for the Y-axis (value count).
        ///
        /// A label created from a `LocalizedStringResource` is resolved for the current locale.
        /// Assigning a string replaces it with a label displayed unchanged.
        ///
        /// - Note: Deprecated because it resolves a `LocalizedStringResource` with the process locale, which can
        ///   differ from the locale the view renders in. Use ``yAxisTitleResource``.
        @available(
            *,
            deprecated,
            message: "Resolves with the process locale, which can differ from the rendered text. Use yAxisTitleResource: set its locale to the one you need and resolve it with String(localized:)."
        )
        public var yAxisTitle: String {
            get { yAxisTitleText.resolved }
            set { yAxisTitleText = .verbatim(newValue) }
        }

        /// The title as a localized string resource.
        ///
        /// Set its `locale` to the locale you need and resolve it with `String(localized:)`. A title created
        /// from a `String` resolves to that string unchanged in every locale. Assigning a resource replaces it.
        public var yAxisTitleResource: LocalizedStringResource {
            get { yAxisTitleText.resource }
            set { yAxisTitleText = .localized(newValue) }
        }

        /// The maximum value for scaling the Y-axis.
        public var maxValue: Int

        /// The minimum value for scaling the Y-axis: `0`, or the most negative value rounded down
        /// to the next multiple of its own order of magnitude.
        let minValue: Int

        /// The Y-axis domain, from ``minValue`` to ``maxValue``, which always includes zero and is never empty.
        var yDomain: ClosedRange<Int> {
            minValue ... max(minValue == 0 ? 1 : 0, maxValue)
        }

        /// The data points to be displayed in the chart.
        private var dataPoints: [DataPoint]

        /// The state shown instead of the chart when there are no data points, or `nil` for the default.
        private let emptyState: GenericState?

        /// The binding to the selected category, or `nil` when people can't select from the chart.
        let selection: Binding<String?>?

        /// A data point paired with its position, so points sharing a name keep distinct identities.
        struct PlottedPoint: Identifiable {
            /// The position of the point in the input data.
            let id: Int
            /// The category name for the bar.
            let name: String
            /// The value associated with the category.
            let value: Int
        }

        /// The data points in input order, identified by position rather than by name.
        var plottedPoints: [PlottedPoint] {
            dataPoints.enumerated().map { PlottedPoint(id: $0.offset, name: $0.element.name, value: $0.element.value) }
        }

        /// Initializes the vertical bar chart with given data points.
        ///
        /// Each bar is annotated with its value, formatted for the environment's locale.
        /// The chart provides an Audio Graphs descriptor with its title, axes, and values.
        /// - Parameters:
        ///   - title: The title of the chart, displayed unchanged.
        ///   - nbMarks: The number of marks on the Y-axis. Defaults to 5.
        ///   - xAxisLabel: The label for the X-axis, displayed unchanged.
        ///   - leftYAxisTitle: The label for the Y-axis, displayed unchanged.
        ///   - points: An array of `VerticalBarChart.DataPoint` to display.
        ///   - selection: A binding to the selected category, or `nil` (the default) for a chart that people
        ///     can't select from. The chart writes the category people select along the X-axis and dims the other bars
        ///     while a category is selected.
        ///   - emptyState: The state shown instead of the chart when there are no data points. Defaults to
        ///     `nil`, which shows `GenericState.empty` with a localized "No data" message.
        public init(
            title: String,
            nbMarks: Int = 5,
            xAxisLabel: String,
            leftYAxisTitle: String,
            points: [VerticalBarChart.DataPoint],
            selection: Binding<String?>? = nil,
            emptyState: GenericState? = nil
        ) {
            self.init(
                titleText: .verbatim(title),
                nbMarks: nbMarks,
                xAxisLabelText: .verbatim(xAxisLabel),
                yAxisTitleText: .verbatim(leftYAxisTitle),
                points: points,
                selection: selection,
                emptyState: emptyState
            )
        }

        /// Initializes the vertical bar chart with localized labels.
        ///
        /// SwiftUI looks up each label in its bundle and table using the environment's locale.
        /// Each bar is annotated with its value, formatted for the environment's locale.
        /// The chart provides an Audio Graphs descriptor with its title, axes, and values.
        /// - Parameters:
        ///   - title: The localized title of the chart.
        ///   - nbMarks: The number of marks on the Y-axis. Defaults to 5.
        ///   - xAxisLabel: The localized label for the X-axis.
        ///   - leftYAxisTitle: The localized label for the Y-axis.
        ///   - points: An array of `VerticalBarChart.DataPoint` to display.
        ///   - selection: A binding to the selected category, or `nil` (the default) for a chart that people
        ///     can't select from. The chart writes the category people select along the X-axis and dims the other bars
        ///     while a category is selected.
        ///   - emptyState: The state shown instead of the chart when there are no data points. Defaults to
        ///     `nil`, which shows `GenericState.empty` with a localized "No data" message.
        public init(
            title: LocalizedStringResource,
            nbMarks: Int = 5,
            xAxisLabel: LocalizedStringResource,
            leftYAxisTitle: LocalizedStringResource,
            points: [VerticalBarChart.DataPoint],
            selection: Binding<String?>? = nil,
            emptyState: GenericState? = nil
        ) {
            self.init(
                titleText: .localized(title),
                nbMarks: nbMarks,
                xAxisLabelText: .localized(xAxisLabel),
                yAxisTitleText: .localized(leftYAxisTitle),
                points: points,
                selection: selection,
                emptyState: emptyState
            )
        }

        private init(
            titleText: LocalizableText,
            nbMarks: Int,
            xAxisLabelText: LocalizableText,
            yAxisTitleText: LocalizableText,
            points: [VerticalBarChart.DataPoint],
            selection: Binding<String?>?,
            emptyState: GenericState?
        ) {
            self.selection = selection
            self.emptyState = emptyState
            self.titleText = titleText
            self.nbMarks = nbMarks
            self.xAxisLabelText = xAxisLabelText
            self.yAxisTitleText = yAxisTitleText
            maxValue = points.maxValue
            minValue = points.minValue
            dataPoints = points
        }

        /// The content and behavior of the view: the chart, or the empty state when there are no data points.
        public var body: some View {
            GenericStateView(state: displayedState(locale: locale)) {
                chartContent
            }
        }

        /// The state the view displays: `.displaying` when there are data points, and otherwise the
        /// custom empty state or an `.empty` state with a localized "No data" message.
        /// - Parameter locale: The locale used to look up the default message.
        /// - Returns: The state passed to `GenericStateView`.
        func displayedState(locale: Locale) -> GenericState {
            ChartEmptyState.state(emptyState, isEmpty: dataPoints.isEmpty, locale: locale)
        }

        /// The chart drawn when there are data points.
        private var chartContent: some View {
            VStack(alignment: .leading, spacing: .spacingMedium) {
                Chart {
                    // Bar Chart for Absolute Values
                    ForEach(plottedPoints) { data in
                        BarMark(
                            x: .value(xAxisLabelText.text, data.name),
                            y: .value(yAxisTitleText.text, data.value)
                        )
                        .annotation(position: .top) {
                            Text(data.value, format: .number)
                                .font(.caption)
                                .foregroundStyle(theme.text3)
                        }
                        .foregroundStyle(by: .value(xAxisLabelText.text, data.name))
                        .opacity(opacity(forCategory: data.name))
                    }
                }
                .chartXSelection(optional: selection)
                .chartYAxisLabel(position: .leading) {
                    yAxisTitleText.text
                        .font(.caption)
                        .foregroundStyle(theme.text3)
                }
                .chartXAxisLabel(position: .top, alignment: .center, spacing: .spacingLarge) {
                    titleText.text
                        .font(.subheadline)
                        .foregroundStyle(theme.text3)
                }
                .chartXAxis {
                    AxisMarks { value in
                        AxisValueLabel {
                            if let category = value.as(String.self) {
                                Text(category)
                                    .font(.caption)
                                    .foregroundStyle(theme.text3)
                                    .lineLimit(1)
                                    .truncationMode(.tail)
                                    .frame(width: 40, alignment: .leading)
                            }
                        }
                    }
                }
                .chartYAxis {

                    // Left Y-Axis Markings
                    AxisMarks(
                        position: .leading,
                        values: markValues()
                    ) {
                        AxisValueLabel()
                            .font(.caption)
                            .foregroundStyle(theme.text3)
                        AxisTick()
                            .foregroundStyle(theme.background3.opacity(0.25))
                        AxisGridLine(stroke: StrokeStyle(lineWidth: 1))
                            .foregroundStyle(theme.background3.opacity(0.25))
                    }
                }
                .accessibilityChartDescriptor(chartDescriptor(locale: locale))
            }
            .chartYScale(domain: yDomain)
            .chartLegend(.visible)
            .chartLegend(position: .bottom, alignment: .center, spacing: .spacingSmall)
            .padding(.spacingLarge)
        }

        /// The opacity of a category's bar: dimmed while another category is selected.
        /// - Parameter category: The category of the bar.
        /// - Returns: The bar's opacity.
        func opacity(forCategory category: String) -> Double {
            ChartSelection.opacity(forCategory: category, selected: selection?.wrappedValue)
        }

        /// The Audio Graphs description of the chart: one bar per data point, in input order, on a
        /// category axis, with the value axis from ``minValue`` to ``maxValue``.
        /// - Parameter locale: The locale used to resolve localized labels and format values.
        /// - Returns: The chart's descriptor.
        func chartDescriptor(locale: Locale) -> ChartDescriptor {
            let title = ChartDescriptor.string(titleText, locale: locale)
            let xAxisTitle = ChartDescriptor.string(xAxisLabelText, locale: locale)
            let yAxisTitle = ChartDescriptor.string(yAxisTitleText, locale: locale)
            let points = plottedPoints.map { (name: $0.name, value: Double($0.value)) }
            let range = Double(yDomain.lowerBound) ... Double(yDomain.upperBound)
            let gridlines = markValues().map(Double.init)
            return ChartDescriptor {
                AXChartDescriptor(
                    title: title,
                    xAxis: AXCategoricalDataAxisDescriptor(title: xAxisTitle, categoryOrder: ChartDescriptor.categories(points.map(\.name))),
                    yAxis: AXNumericDataAxisDescriptor(
                        title: yAxisTitle,
                        range: range,
                        gridlinePositions: gridlines,
                        valueDescriptionProvider: ChartDescriptor.numberDescription(locale: locale)
                    ),
                    series: [
                        AXDataSeriesDescriptor(
                            name: yAxisTitle,
                            isContinuous: false,
                            dataPoints: points.map { AXDataPoint(x: $0.name, y: $0.value) }
                        )
                    ]
                )
            }
        }

        /// Computes evenly spaced Y-axis values from zero to ``maxValue``, preceded by ``minValue``
        /// when the data has negative values.
        /// - Returns: An array of `Int` values for axis marks.
        func markValues() -> [Int] {
            let negativeMarks = minValue < 0 ? [minValue] : []
            guard maxValue > 0 else {
                return negativeMarks + [0]
            }
            let step = max(1, maxValue / max(1, nbMarks))
            var values = negativeMarks
            for x in stride(from: 0, to: maxValue, by: step) {
                values.append(x)
            }
            values.append(maxValue)
            return values
        }

    }

    extension [VerticalBarChart.DataPoint] {
        /// Calculates the maximum value for Y-axis scaling, rounded up proportionally to the data.
        var maxValue: Int {
            ChartAxis.niceMaximum(for: map(\.value).max() ?? 0)
        }

        /// Calculates the minimum value for Y-axis scaling: `0`, or the most negative value
        /// rounded down proportionally to the data.
        var minValue: Int {
            -ChartAxis.niceMaximum(for: -Swift.max(map(\.value).min() ?? 0, -Int.max))
        }
    }

#endif

#if canImport(SwiftUI)
    import SwiftUI

    #if DEBUG
        import SnapshotPreviews

        @MainActor enum VerticalBarChartPreviews: PreviewProvider, SnapshotProvider {
            static let defaultLayout: PreviewSnapshotLayout = .device

            static var snapshots: [PreviewSnapshot] {
                PreviewSnapshot("default") {
                    VerticalBarChart(
                        title: "Downtime Reason Analysis",
                        nbMarks: 4,
                        xAxisLabel: "Category",
                        leftYAxisTitle: "Occurrences",
                        points: [
                            VerticalBarChart.DataPoint(name: "Equipment", value: 330),
                            VerticalBarChart.DataPoint(name: "Ingredient Shortage", value: 213),
                            VerticalBarChart.DataPoint(name: "Maintenance", value: 122),
                            VerticalBarChart.DataPoint(name: "Changeover", value: 30),
                            VerticalBarChart.DataPoint(name: "Quality Control", value: 21),
                            VerticalBarChart.DataPoint(name: "Other", value: 10)
                        ]
                    )
                }
            }
        }
    #endif
#endif
