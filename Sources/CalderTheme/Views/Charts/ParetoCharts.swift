#if canImport(SwiftUI)
    import Accessibility
    import CalderUIKit
    import Charts
    import Foundation
    import SwiftUI

    /// A SwiftUI view representing a Pareto chart,
    /// which consists of a bar chart for absolute values and a line chart for cumulative percentages.
    public struct ParetoChart: View {

        /// The current theme, injected via Environment.
        @Environment(\.theme) var theme

        /// Represents a raw data point before processing for the Pareto chart.
        public struct RawDataPoint {
            /// The category name (X-axis).
            var name: String
            /// The absolute value associated with the category (left Y-axis), never negative.
            var value: Int

            /// Creates a category and its absolute value for a Pareto chart.
            ///
            /// A Pareto chart plots shares of a total, so negative values are clamped to zero.
            /// Each point keeps its own identity, but points that share a name share a category
            /// on the X-axis, so give each category a unique name.
            /// - Parameters:
            ///   - name: The category label.
            ///   - value: The absolute value for the category. Negative values are treated as zero.
            public init(name: String, value: Int) {
                self.name = name
                self.value = max(0, value)
            }
        }

        /// Represents a processed data point with cumulative percentage for the Pareto chart.
        struct DataPoint: Identifiable {
            /// The position of the point in the sorted data, unique even when names repeat.
            var id: Int
            /// The category name (X-axis).
            var name: String
            /// The absolute value associated with the category (left Y-axis).
            var value: Int
            /// The cumulative share of the total, from `0` to `1`, described as a percentage.
            var share: Double
            /// The cumulative percentage value, scaled to the maximum value (right Y-axis).
            var cumulated: Double
        }

        /// The requested number of intervals on the Y-axis. Values below one use one interval.
        public var nbMarks: Int

        private var titleText: LocalizableText
        private var xAxisLabelText: LocalizableText
        private var leftYAxisTitleText: LocalizableText
        private var rightYAxisTitleText: LocalizableText

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

        /// The label for the left Y-axis (value count).
        ///
        /// A label created from a `LocalizedStringResource` is resolved for the current locale.
        /// Assigning a string replaces it with a label displayed unchanged.
        ///
        /// - Note: Deprecated because it resolves a `LocalizedStringResource` with the process locale, which can
        ///   differ from the locale the view renders in. Use ``leftYAxisTitleResource``.
        @available(
            *,
            deprecated,
            message: "Resolves with the process locale, which can differ from the rendered text. Use leftYAxisTitleResource: set its locale to the one you need and resolve it with String(localized:)."
        )
        public var leftYAxisTitle: String {
            get { leftYAxisTitleText.resolved }
            set { leftYAxisTitleText = .verbatim(newValue) }
        }

        /// The title as a localized string resource.
        ///
        /// Set its `locale` to the locale you need and resolve it with `String(localized:)`. A title created
        /// from a `String` resolves to that string unchanged in every locale. Assigning a resource replaces it.
        public var leftYAxisTitleResource: LocalizedStringResource {
            get { leftYAxisTitleText.resource }
            set { leftYAxisTitleText = .localized(newValue) }
        }

        /// The label for the right Y-axis (cumulative percentage).
        ///
        /// A label created from a `LocalizedStringResource` is resolved for the current locale.
        /// Assigning a string replaces it with a label displayed unchanged.
        ///
        /// - Note: Deprecated because it resolves a `LocalizedStringResource` with the process locale, which can
        ///   differ from the locale the view renders in. Use ``rightYAxisTitleResource``.
        @available(
            *,
            deprecated,
            message: "Resolves with the process locale, which can differ from the rendered text. Use rightYAxisTitleResource: set its locale to the one you need and resolve it with String(localized:)."
        )
        public var rightYAxisTitle: String {
            get { rightYAxisTitleText.resolved }
            set { rightYAxisTitleText = .verbatim(newValue) }
        }

        /// The title as a localized string resource.
        ///
        /// Set its `locale` to the locale you need and resolve it with `String(localized:)`. A title created
        /// from a `String` resolves to that string unchanged in every locale. Assigning a resource replaces it.
        public var rightYAxisTitleResource: LocalizedStringResource {
            get { rightYAxisTitleText.resource }
            set { rightYAxisTitleText = .localized(newValue) }
        }

        /// The locale used to format bar values and the percentage axis.
        @Environment(\.locale) private var locale

        /// The maximum value for scaling the left Y-axis.
        public var maxValue: Int

        /// The processed data points, including cumulative percentages.
        private var dataPoints: [DataPoint]

        /// The state shown instead of the chart when there are no data points, or `nil` for the default.
        private let emptyState: GenericState?

        /// Initializes the Pareto chart with given raw data points.
        ///
        /// The points are plotted in descending order of value, as a Pareto chart requires.
        /// Points with equal values keep their input order, and points may share a name.
        /// Bar values and the percentage axis are formatted for the environment's locale.
        /// The chart provides an Audio Graphs descriptor, and VoiceOver reads the cumulative line
        /// as percentages.
        /// - Parameters:
        ///   - title: The title of the chart, displayed unchanged.
        ///   - nbMarks: The number of marks on the Y-axis. Defaults to 5.
        ///   - xAxisLabel: The label for the X-axis, displayed unchanged.
        ///   - leftYAxisTitle: The label for the left Y-axis, displayed unchanged.
        ///   - rightYAxisTitle: The label for the right Y-axis, displayed unchanged.
        ///   - points: An array of `RawDataPoint` to process and display, in any order.
        ///   - emptyState: The state shown instead of the chart when there are no data points. Defaults to
        ///     `nil`, which shows `GenericState.empty` with a localized "No data" message.
        public init(
            title: String,
            nbMarks: Int = 5,
            xAxisLabel: String,
            leftYAxisTitle: String,
            rightYAxisTitle: String,
            points: [RawDataPoint],
            emptyState: GenericState? = nil
        ) {
            self.init(
                titleText: .verbatim(title),
                nbMarks: nbMarks,
                xAxisLabelText: .verbatim(xAxisLabel),
                leftYAxisTitleText: .verbatim(leftYAxisTitle),
                rightYAxisTitleText: .verbatim(rightYAxisTitle),
                points: points,
                emptyState: emptyState
            )
        }

        /// Initializes the Pareto chart with localized labels.
        ///
        /// SwiftUI looks up each label in its bundle and table using the environment's locale.
        /// The points are plotted in descending order of value, as a Pareto chart requires.
        /// Points with equal values keep their input order, and points may share a name.
        /// Bar values and the percentage axis are formatted for the environment's locale.
        /// The chart provides an Audio Graphs descriptor, and VoiceOver reads the cumulative line
        /// as percentages.
        /// - Parameters:
        ///   - title: The localized title of the chart.
        ///   - nbMarks: The number of marks on the Y-axis. Defaults to 5.
        ///   - xAxisLabel: The localized label for the X-axis.
        ///   - leftYAxisTitle: The localized label for the left Y-axis.
        ///   - rightYAxisTitle: The localized label for the right Y-axis.
        ///   - points: An array of `RawDataPoint` to process and display, in any order.
        ///   - emptyState: The state shown instead of the chart when there are no data points. Defaults to
        ///     `nil`, which shows `GenericState.empty` with a localized "No data" message.
        public init(
            title: LocalizedStringResource,
            nbMarks: Int = 5,
            xAxisLabel: LocalizedStringResource,
            leftYAxisTitle: LocalizedStringResource,
            rightYAxisTitle: LocalizedStringResource,
            points: [RawDataPoint],
            emptyState: GenericState? = nil
        ) {
            self.init(
                titleText: .localized(title),
                nbMarks: nbMarks,
                xAxisLabelText: .localized(xAxisLabel),
                leftYAxisTitleText: .localized(leftYAxisTitle),
                rightYAxisTitleText: .localized(rightYAxisTitle),
                points: points,
                emptyState: emptyState
            )
        }

        private init(
            titleText: LocalizableText,
            nbMarks: Int,
            xAxisLabelText: LocalizableText,
            leftYAxisTitleText: LocalizableText,
            rightYAxisTitleText: LocalizableText,
            points: [RawDataPoint],
            emptyState: GenericState?
        ) {
            self.emptyState = emptyState
            self.titleText = titleText
            self.nbMarks = nbMarks
            self.xAxisLabelText = xAxisLabelText
            self.leftYAxisTitleText = leftYAxisTitleText
            self.rightYAxisTitleText = rightYAxisTitleText
            maxValue = points.maxValue
            dataPoints = points.computedPoints
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
                    ForEach(dataPoints) { data in
                        BarMark(
                            x: .value(xAxisLabelText.text, data.name),
                            y: .value(leftYAxisTitleText.text, data.value)
                        )
                        .annotation(position: .top) {
                            Text(data.value, format: .number)
                                .font(.caption)
                                .foregroundStyle(theme.text3)
                        }
                        .foregroundStyle(by: .value(xAxisLabelText.text, data.name))
                    }

                    // Line Chart for Cumulative Percentage
                    ForEach(dataPoints) { data in
                        LineMark(
                            x: .value(xAxisLabelText.text, data.name),
                            y: .value(rightYAxisTitleText.text, data.cumulated)
                        )
                        .lineStyle(StrokeStyle(lineWidth: 2))
                        .foregroundStyle(theme.error)
                        .interpolationMethod(.linear)
                        .accessibilityValue(Text(data.share, format: .percent.locale(locale)))
                    }

                    // Circle Markers on Line Chart
                    ForEach(dataPoints) { data in
                        PointMark(
                            x: .value(xAxisLabelText.text, data.name),
                            y: .value(rightYAxisTitleText.text, data.cumulated)
                        )
                        .foregroundStyle(theme.error)
                        .symbol {
                            Rectangle()
                                .fill(theme.error)
                                .frame(width: 10, height: 10)
                        }
                        .accessibilityValue(Text(data.share, format: .percent.locale(locale)))
                    }
                }
                .chartYAxisLabel(position: .leading) {
                    leftYAxisTitleText.text
                        .font(.caption)
                        .foregroundStyle(theme.text3)
                }
                .chartYAxisLabel(position: .trailing) {
                    rightYAxisTitleText.text
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

                    // Right Y-Axis Markings (Percentage Scale)
                    AxisMarks(
                        position: .trailing,
                        values: markValues()
                    ) { value in
                        AxisValueLabel(percentValue(for: value.as(Int.self) ?? 0, locale: locale))
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
            .chartYScale(domain: 0 ... max(1, maxValue))
            .chartLegend(.visible)
            .chartLegend(position: .bottom, alignment: .center, spacing: .spacingSmall)
            .padding(.spacingLarge)
        }

        /// Computes evenly spaced Y-axis values for the left axis.
        /// - Returns: An array of `Int` values representing axis marks.
        func markValues() -> [Int] {
            guard maxValue > 0 else {
                return [0]
            }
            let step = max(1, maxValue / max(1, nbMarks))
            var values: [Int] = []
            for x in stride(from: 0, to: maxValue, by: step) {
                values.append(x)
            }
            values.append(maxValue)
            return values
        }

        /// The Audio Graphs description of the chart: one bar per category in plotted order, with the
        /// values on the left Y-axis. Each point's cumulative share is an additional value, described
        /// as a percentage on an axis titled with the right Y-axis title.
        /// - Parameter locale: The locale used to resolve localized labels and format values.
        /// - Returns: The chart's descriptor.
        func chartDescriptor(locale: Locale) -> ChartDescriptor {
            let title = ChartDescriptor.string(titleText, locale: locale)
            let xAxisTitle = ChartDescriptor.string(xAxisLabelText, locale: locale)
            let valueTitle = ChartDescriptor.string(leftYAxisTitleText, locale: locale)
            let shareTitle = ChartDescriptor.string(rightYAxisTitleText, locale: locale)
            let points = dataPoints.map { (name: $0.name, value: Double($0.value), share: $0.share) }
            let range = 0 ... Double(max(1, maxValue))
            let gridlines = markValues().map(Double.init)
            return ChartDescriptor {
                AXChartDescriptor(
                    title: title,
                    xAxis: AXCategoricalDataAxisDescriptor(title: xAxisTitle, categoryOrder: ChartDescriptor.categories(points.map(\.name))),
                    yAxis: AXNumericDataAxisDescriptor(
                        title: valueTitle,
                        range: range,
                        gridlinePositions: gridlines,
                        valueDescriptionProvider: ChartDescriptor.numberDescription(locale: locale)
                    ),
                    additionalAxes: [
                        AXNumericDataAxisDescriptor(title: shareTitle, range: 0 ... 1, gridlinePositions: []) { share in
                            share.formatted(.percent.locale(locale))
                        }
                    ],
                    series: [
                        AXDataSeriesDescriptor(
                            name: valueTitle,
                            isContinuous: false,
                            dataPoints: points.map { AXDataPoint(x: $0.name, y: $0.value, additionalValues: [.number($0.share)]) }
                        )
                    ]
                )
            }
        }

        /// Converts a Y-axis value to a formatted percentage string for the right axis.
        /// - Parameters:
        ///   - value: The value of the axis mark.
        ///   - locale: The locale used to format the percentage.
        /// - Returns: A string representing the percentage.
        func percentValue(for value: Int, locale: Locale) -> String {
            (maxValue > 0 ? Double(value) / Double(maxValue) : 0).formatted(.percent.locale(locale))
        }
    }

    extension [ParetoChart.RawDataPoint] {
        /// Calculates the maximum value for Y-axis scaling, rounded up proportionally to the data.
        var maxValue: Int {
            ChartAxis.niceMaximum(for: map(\.value).max() ?? 0)
        }

        /// Sorts the points by descending value and computes their cumulative percentage.
        /// The `cumulated` value is scaled to `maxValue` for display on the secondary Y-axis.
        var computedPoints: [ParetoChart.DataPoint] {
            let total = map(\.value).reduce(0, +)
            var cumulativeSum = 0
            return sorted { $0.value > $1.value }.enumerated().map { index, point in
                cumulativeSum += point.value
                let share = total == 0 ? 0 : Double(cumulativeSum) / Double(total)
                return .init(
                    id: index,
                    name: point.name,
                    value: point.value,
                    share: share,
                    cumulated: share * Double(maxValue)
                )
            }
        }
    }

#endif

#if canImport(SwiftUI)
    import SwiftUI

    #if DEBUG
        import SnapshotPreviews

        @MainActor enum ParetoChartPreviews: PreviewProvider, SnapshotProvider {
            static let defaultLayout: PreviewSnapshotLayout = .device

            static var snapshots: [PreviewSnapshot] {
                PreviewSnapshot("default") {
                    ParetoChart(
                        title: "Downtime Reason Analysis",
                        nbMarks: 4,
                        xAxisLabel: "Category",
                        leftYAxisTitle: "Occurrences",
                        rightYAxisTitle: "Cumulative (%)",
                        points: [
                            ParetoChart.RawDataPoint(name: "Equipment", value: 330),
                            ParetoChart.RawDataPoint(name: "Ingredient Shortage", value: 213),
                            ParetoChart.RawDataPoint(name: "Maintenance", value: 122),
                            ParetoChart.RawDataPoint(name: "Changeover", value: 30),
                            ParetoChart.RawDataPoint(name: "Quality Control", value: 21),
                            ParetoChart.RawDataPoint(name: "Other", value: 10)
                        ]
                    )
                }
            }
        }
    #endif
#endif
