#if canImport(SwiftUI)
    import CalderUIKit
    import Charts
    import Foundation
    import SwiftUI

    /// A SwiftUI view representing a vertical bar chart.
    public struct VerticalBarChart: View {

        /// The current theme, injected via Environment.
        @Environment(\.theme) var theme

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

        /// The label for the Y-axis (value count).
        ///
        /// A label created from a `LocalizedStringResource` is resolved for the current locale.
        /// Assigning a string replaces it with a label displayed unchanged.
        public var yAxisTitle: String {
            get { yAxisTitleText.resolved }
            set { yAxisTitleText = .verbatim(newValue) }
        }

        /// The maximum value for scaling the Y-axis.
        public var maxValue: Int

        /// The data points to be displayed in the chart.
        private var dataPoints: [DataPoint]

        /// Initializes the vertical bar chart with given data points.
        ///
        /// Each bar is annotated with its value, formatted for the environment's locale.
        /// - Parameters:
        ///   - title: The title of the chart, displayed unchanged.
        ///   - nbMarks: The number of marks on the Y-axis. Defaults to 5.
        ///   - xAxisLabel: The label for the X-axis, displayed unchanged.
        ///   - leftYAxisTitle: The label for the Y-axis, displayed unchanged.
        ///   - points: An array of `VerticalBarChart.DataPoint` to display.
        public init(
            title: String,
            nbMarks: Int = 5,
            xAxisLabel: String,
            leftYAxisTitle: String,
            points: [VerticalBarChart.DataPoint]
        ) {
            self.init(
                titleText: .verbatim(title),
                nbMarks: nbMarks,
                xAxisLabelText: .verbatim(xAxisLabel),
                yAxisTitleText: .verbatim(leftYAxisTitle),
                points: points
            )
        }

        /// Initializes the vertical bar chart with localized labels.
        ///
        /// SwiftUI looks up each label in its bundle and table using the environment's locale.
        /// Each bar is annotated with its value, formatted for the environment's locale.
        /// - Parameters:
        ///   - title: The localized title of the chart.
        ///   - nbMarks: The number of marks on the Y-axis. Defaults to 5.
        ///   - xAxisLabel: The localized label for the X-axis.
        ///   - leftYAxisTitle: The localized label for the Y-axis.
        ///   - points: An array of `VerticalBarChart.DataPoint` to display.
        public init(
            title: LocalizedStringResource,
            nbMarks: Int = 5,
            xAxisLabel: LocalizedStringResource,
            leftYAxisTitle: LocalizedStringResource,
            points: [VerticalBarChart.DataPoint]
        ) {
            self.init(
                titleText: .localized(title),
                nbMarks: nbMarks,
                xAxisLabelText: .localized(xAxisLabel),
                yAxisTitleText: .localized(leftYAxisTitle),
                points: points
            )
        }

        private init(
            titleText: LocalizableText,
            nbMarks: Int,
            xAxisLabelText: LocalizableText,
            yAxisTitleText: LocalizableText,
            points: [VerticalBarChart.DataPoint]
        ) {
            self.titleText = titleText
            self.nbMarks = nbMarks
            self.xAxisLabelText = xAxisLabelText
            self.yAxisTitleText = yAxisTitleText
            maxValue = points.maxValue
            dataPoints = points
        }

        /// The content and behavior of the view.
        public var body: some View {
            VStack(alignment: .leading, spacing: .medium) {
                Chart {
                    // Bar Chart for Absolute Values
                    ForEach(dataPoints, id: \.name) { data in
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
                    }
                }
                .chartYAxisLabel(position: .leading) {
                    yAxisTitleText.text
                        .font(.caption)
                        .foregroundStyle(theme.text3)
                }
                .chartXAxisLabel(position: .top, alignment: .center, spacing: .large) {
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
            }
            .chartYScale(domain: 0 ... max(1, maxValue))
            .chartLegend(.visible)
            .chartLegend(position: .bottom, alignment: .center, spacing: .small)
            .padding(.large)
        }

        /// Computes evenly spaced Y-axis values.
        /// - Returns: An array of `Int` values for axis marks.
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

    }

    extension [VerticalBarChart.DataPoint] {
        /// Calculates the maximum value for Y-axis scaling, rounded up proportionally to the data.
        var maxValue: Int {
            ChartAxis.niceMaximum(for: map(\.value).max() ?? 0)
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
