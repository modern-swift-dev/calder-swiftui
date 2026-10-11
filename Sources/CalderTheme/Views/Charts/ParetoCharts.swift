#if canImport(SwiftUI)
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
        public var title: String {
            get { titleText.resolved }
            set { titleText = .verbatim(newValue) }
        }

        /// The label for the X-axis.
        ///
        /// A label created from a `LocalizedStringResource` is resolved for the current locale.
        /// Assigning a string replaces it with a label displayed unchanged.
        public var xAxisLabel: String {
            get { xAxisLabelText.resolved }
            set { xAxisLabelText = .verbatim(newValue) }
        }

        /// The label for the left Y-axis (value count).
        ///
        /// A label created from a `LocalizedStringResource` is resolved for the current locale.
        /// Assigning a string replaces it with a label displayed unchanged.
        public var leftYAxisTitle: String {
            get { leftYAxisTitleText.resolved }
            set { leftYAxisTitleText = .verbatim(newValue) }
        }

        /// The label for the right Y-axis (cumulative percentage).
        ///
        /// A label created from a `LocalizedStringResource` is resolved for the current locale.
        /// Assigning a string replaces it with a label displayed unchanged.
        public var rightYAxisTitle: String {
            get { rightYAxisTitleText.resolved }
            set { rightYAxisTitleText = .verbatim(newValue) }
        }

        /// The locale used to format bar values and the percentage axis.
        @Environment(\.locale) private var locale

        /// The maximum value for scaling the left Y-axis.
        public var maxValue: Int

        /// The processed data points, including cumulative percentages.
        private var dataPoints: [DataPoint]

        /// Initializes the Pareto chart with given raw data points.
        ///
        /// The points are plotted in descending order of value, as a Pareto chart requires.
        /// Points with equal values keep their input order, and points may share a name.
        /// Bar values and the percentage axis are formatted for the environment's locale.
        /// - Parameters:
        ///   - title: The title of the chart, displayed unchanged.
        ///   - nbMarks: The number of marks on the Y-axis. Defaults to 5.
        ///   - xAxisLabel: The label for the X-axis, displayed unchanged.
        ///   - leftYAxisTitle: The label for the left Y-axis, displayed unchanged.
        ///   - rightYAxisTitle: The label for the right Y-axis, displayed unchanged.
        ///   - points: An array of `RawDataPoint` to process and display, in any order.
        public init(
            title: String,
            nbMarks: Int = 5,
            xAxisLabel: String,
            leftYAxisTitle: String,
            rightYAxisTitle: String,
            points: [RawDataPoint]
        ) {
            self.init(
                titleText: .verbatim(title),
                nbMarks: nbMarks,
                xAxisLabelText: .verbatim(xAxisLabel),
                leftYAxisTitleText: .verbatim(leftYAxisTitle),
                rightYAxisTitleText: .verbatim(rightYAxisTitle),
                points: points
            )
        }

        /// Initializes the Pareto chart with localized labels.
        ///
        /// SwiftUI looks up each label in its bundle and table using the environment's locale.
        /// The points are plotted in descending order of value, as a Pareto chart requires.
        /// Points with equal values keep their input order, and points may share a name.
        /// Bar values and the percentage axis are formatted for the environment's locale.
        /// - Parameters:
        ///   - title: The localized title of the chart.
        ///   - nbMarks: The number of marks on the Y-axis. Defaults to 5.
        ///   - xAxisLabel: The localized label for the X-axis.
        ///   - leftYAxisTitle: The localized label for the left Y-axis.
        ///   - rightYAxisTitle: The localized label for the right Y-axis.
        ///   - points: An array of `RawDataPoint` to process and display, in any order.
        public init(
            title: LocalizedStringResource,
            nbMarks: Int = 5,
            xAxisLabel: LocalizedStringResource,
            leftYAxisTitle: LocalizedStringResource,
            rightYAxisTitle: LocalizedStringResource,
            points: [RawDataPoint]
        ) {
            self.init(
                titleText: .localized(title),
                nbMarks: nbMarks,
                xAxisLabelText: .localized(xAxisLabel),
                leftYAxisTitleText: .localized(leftYAxisTitle),
                rightYAxisTitleText: .localized(rightYAxisTitle),
                points: points
            )
        }

        private init(
            titleText: LocalizableText,
            nbMarks: Int,
            xAxisLabelText: LocalizableText,
            leftYAxisTitleText: LocalizableText,
            rightYAxisTitleText: LocalizableText,
            points: [RawDataPoint]
        ) {
            self.titleText = titleText
            self.nbMarks = nbMarks
            self.xAxisLabelText = xAxisLabelText
            self.leftYAxisTitleText = leftYAxisTitleText
            self.rightYAxisTitleText = rightYAxisTitleText
            maxValue = points.maxValue
            dataPoints = points.computedPoints
        }

        /// The content and behavior of the view.
        public var body: some View {
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
                return .init(
                    id: index,
                    name: point.name,
                    value: point.value,
                    cumulated: total == 0 ? 0 : Double(cumulativeSum) / Double(total) * Double(maxValue)
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
