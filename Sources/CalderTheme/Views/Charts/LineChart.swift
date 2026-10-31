#if canImport(SwiftUI)
    import Accessibility
    import CalderStdLib
    import CalderUIKit
    import Charts
    import Foundation
    import SwiftUI

    /// A SwiftUI view representing a line chart.
    public struct LineChart: View {

        /// The current theme, injected via Environment.
        @Environment(\.theme) var theme

        /// The locale used to describe the chart's values to Audio Graphs.
        @Environment(\.locale) private var locale

        /// Represents a data point for the line chart.
        public struct DataPoint {
            /// The date for the data point (X-axis).
            var date: Date
            /// The value associated with the date (Y-axis).
            var value: Int

            /// Initializes a `DataPoint` with a date and value.
            /// - Parameters:
            ///   - date: The date.
            ///   - value: The numerical value.
            public init(date: Date, value: Int) {
                self.date = date
                self.value = value
            }
        }

        /// The desired number of marks on the Y-axis. Swift Charts picks evenly spaced, rounded
        /// values close to this count. Values below one request a single mark.
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

        /// The data points to be displayed in the chart.
        private var dataPoints: [DataPoint]

        /// The state shown instead of the chart when there are no data points, or `nil` for the default.
        private let emptyState: GenericState?

        /// The binding to the selected date, or `nil` when people can't select from the chart.
        let selection: Binding<Date?>?

        /// The selected date, or `nil` when nothing is selected or the chart has no selection binding.
        var selectedDate: Date? {
            selection?.wrappedValue
        }

        /// A data point paired with its position, so points sharing a date keep distinct identities.
        struct PlottedPoint: Identifiable {
            /// The position of the point in the input data.
            let id: Int
            /// The date for the data point (X-axis).
            let date: Date
            /// The value associated with the date (Y-axis).
            let value: Int
        }

        /// The data points in input order, identified by position rather than by date.
        var plottedPoints: [PlottedPoint] {
            dataPoints.enumerated().map { PlottedPoint(id: $0.offset, date: $0.element.date, value: $0.element.value) }
        }

        /// The desired Y-axis mark count derived from `nbMarks`, never less than one.
        var yAxisMarkCount: Int {
            max(1, nbMarks)
        }

        /// Initializes the line chart with given data points.
        ///
        /// The chart provides an Audio Graphs descriptor with its title, axes, and values.
        /// - Parameters:
        ///   - title: The title of the chart, displayed unchanged.
        ///   - nbMarks: The desired number of marks on the Y-axis. Defaults to 5.
        ///   - xAxisLabel: The label for the X-axis, displayed unchanged.
        ///   - leftYAxisTitle: The label for the Y-axis, displayed unchanged.
        ///   - points: An array of `DataPoint` to display. Several points may share a date.
        ///   - selection: A binding to the selected date, or `nil` (the default) for a chart that people
        ///     can't select from. The chart writes the date people select along the X-axis and draws a rule
        ///     at the selected date.
        ///   - emptyState: The state shown instead of the chart when there are no data points. Defaults to
        ///     `nil`, which shows `GenericState.empty` with a localized "No data" message.
        public init(
            title: String,
            nbMarks: Int = 5,
            xAxisLabel: String,
            leftYAxisTitle: String,
            points: [DataPoint],
            selection: Binding<Date?>? = nil,
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

        /// Initializes the line chart with localized labels.
        ///
        /// SwiftUI looks up each label in its bundle and table using the environment's locale.
        /// The chart provides an Audio Graphs descriptor with its title, axes, and values.
        /// - Parameters:
        ///   - title: The localized title of the chart.
        ///   - nbMarks: The desired number of marks on the Y-axis. Defaults to 5.
        ///   - xAxisLabel: The localized label for the X-axis.
        ///   - leftYAxisTitle: The localized label for the Y-axis.
        ///   - points: An array of `DataPoint` to display. Several points may share a date.
        ///   - selection: A binding to the selected date, or `nil` (the default) for a chart that people
        ///     can't select from. The chart writes the date people select along the X-axis and draws a rule
        ///     at the selected date.
        ///   - emptyState: The state shown instead of the chart when there are no data points. Defaults to
        ///     `nil`, which shows `GenericState.empty` with a localized "No data" message.
        public init(
            title: LocalizedStringResource,
            nbMarks: Int = 5,
            xAxisLabel: LocalizedStringResource,
            leftYAxisTitle: LocalizedStringResource,
            points: [DataPoint],
            selection: Binding<Date?>? = nil,
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
            points: [DataPoint],
            selection: Binding<Date?>?,
            emptyState: GenericState?
        ) {
            self.selection = selection
            self.emptyState = emptyState
            self.titleText = titleText
            self.nbMarks = nbMarks
            self.xAxisLabelText = xAxisLabelText
            self.yAxisTitleText = yAxisTitleText
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

                    // Line Chart for Cumulative Percentage
                    ForEach(plottedPoints) { data in
                        LineMark(
                            x: .value(xAxisLabelText.text, data.date),
                            y: .value(yAxisTitleText.text, data.value)
                        )
                        .lineStyle(StrokeStyle(lineWidth: 2))
                        .foregroundStyle(theme.error)
                        .interpolationMethod(.linear)
                    }

                    // Circle Markers on Line Chart
                    ForEach(plottedPoints) { data in
                        PointMark(
                            x: .value(xAxisLabelText.text, data.date),
                            y: .value(yAxisTitleText.text, data.value)
                        )
                        .foregroundStyle(theme.error)
                        .symbol {
                            Rectangle()
                                .fill(theme.error)
                                .frame(width: 10, height: 10)
                        }
                    }

                    // Rule at the selected date
                    if let selectedDate {
                        RuleMark(x: .value(xAxisLabelText.text, selectedDate))
                            .lineStyle(StrokeStyle(lineWidth: 1))
                            .foregroundStyle(theme.text3)
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
                    AxisMarks(
                        position: .automatic,
                        values: .automatic
                    )
                }
                .chartYAxis {
                    AxisMarks(
                        position: .leading,
                        values: .automatic(desiredCount: yAxisMarkCount)
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
            .padding(.spacingLarge)
        }

        /// The Audio Graphs description of the chart: one continuous series of the data points, in
        /// input order, with dates on the X-axis described as abbreviated dates.
        /// - Parameter locale: The locale used to resolve localized labels and format values and dates.
        /// - Returns: The chart's descriptor.
        func chartDescriptor(locale: Locale) -> ChartDescriptor {
            let title = ChartDescriptor.string(titleText, locale: locale)
            let xAxisTitle = ChartDescriptor.string(xAxisLabelText, locale: locale)
            let yAxisTitle = ChartDescriptor.string(yAxisTitleText, locale: locale)
            let points = plottedPoints.map { (date: $0.date.timeIntervalSince1970, value: Double($0.value)) }
            let dates = points.map(\.date)
            let dateRange = (dates.min() ?? 0) ... (dates.max() ?? 0)
            let dateStyle = Date.FormatStyle(date: .abbreviated, time: .omitted, locale: locale)
            return ChartDescriptor {
                AXChartDescriptor(
                    title: title,
                    xAxis: AXNumericDataAxisDescriptor(title: xAxisTitle, range: dateRange, gridlinePositions: []) { value in
                        Date(timeIntervalSince1970: value).formatted(dateStyle)
                    },
                    yAxis: AXNumericDataAxisDescriptor(
                        title: yAxisTitle,
                        range: ChartDescriptor.zeroBasedRange(points.map(\.value)),
                        gridlinePositions: [],
                        valueDescriptionProvider: ChartDescriptor.numberDescription(locale: locale)
                    ),
                    series: [
                        AXDataSeriesDescriptor(
                            name: yAxisTitle,
                            isContinuous: true,
                            dataPoints: points.map { AXDataPoint(x: $0.date, y: $0.value) }
                        )
                    ]
                )
            }
        }

    }

#endif

#if canImport(SwiftUI)
    import CalderStdLib
    import Foundation
    import SwiftUI

    #if DEBUG
        import SnapshotPreviews

        @MainActor enum LineChartPreviews: PreviewProvider, SnapshotProvider {
            static let defaultLayout: PreviewSnapshotLayout = .device
            private static let date = Date(timeIntervalSince1970: 1_746_378_919)

            static var snapshots: [PreviewSnapshot] {
                PreviewSnapshot("default") {
                    LineChart(
                        title: "",
                        nbMarks: 4,
                        xAxisLabel: "Category",
                        leftYAxisTitle: "Occurrences",
                        points: [
                            LineChart.DataPoint(date: date, value: 0),
                            LineChart.DataPoint(date: date.plusDay(1), value: 330),
                            LineChart.DataPoint(date: date.plusDay(2), value: 213),
                            LineChart.DataPoint(date: date.plusDay(3), value: 122),
                            LineChart.DataPoint(date: date.plusDay(4), value: 30),
                            LineChart.DataPoint(date: date.plusDay(5), value: 21),
                            LineChart.DataPoint(date: date.plusDay(6), value: 10),
                            LineChart.DataPoint(date: date.plusDay(7), value: 50)
                        ]
                    )
                }
            }
        }
    #endif
#endif
