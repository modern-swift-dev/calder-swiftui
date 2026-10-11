#if canImport(SwiftUI)
    import CalderUIKit
    import Charts
    import Foundation
    import SwiftUI

    /// A SwiftUI view representing a horizontal bar chart.
    public struct HorizontalBarChart: View {

        /// The current theme, injected via Environment.
        @Environment(\.theme) var theme

        /// Represents a data point for the horizontal bar chart.
        public struct DataPoint {
            /// The category name for the bar.
            let name: String
            /// The value associated with the category, determining the length of the bar.
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

        private var xAxisLabelText: LocalizableText
        private var yAxisTitleText: LocalizableText

        /// The label for the Y-axis (category axis).
        ///
        /// A label created from a `LocalizedStringResource` is resolved for the current locale.
        /// Assigning a string replaces it with a label displayed unchanged.
        public var xAxisLabel: String {
            get { xAxisLabelText.resolved }
            set { xAxisLabelText = .verbatim(newValue) }
        }

        /// The label for the X-axis (value count).
        ///
        /// A label created from a `LocalizedStringResource` is resolved for the current locale.
        /// Assigning a string replaces it with a label displayed unchanged.
        public var yAxisTitle: String {
            get { yAxisTitleText.resolved }
            set { yAxisTitleText = .verbatim(newValue) }
        }

        /// The processed data points to be displayed in the chart.
        private var dataPoints: [DataPoint]

        /// Initializes the horizontal bar chart with given data points.
        ///
        /// Each bar is annotated with its value, formatted for the environment's locale.
        /// - Parameters:
        ///   - xAxisLabel: The label for the category axis, displayed unchanged.
        ///   - leftYAxisTitle: The label for the value axis, displayed unchanged.
        ///   - points: An array of `HorizontalBarChart.DataPoint` to display.
        public init(
            xAxisLabel: String,
            leftYAxisTitle: String,
            points: [HorizontalBarChart.DataPoint]
        ) {
            self.init(xAxisLabelText: .verbatim(xAxisLabel), yAxisTitleText: .verbatim(leftYAxisTitle), points: points)
        }

        /// Initializes the horizontal bar chart with localized axis labels.
        ///
        /// SwiftUI looks up each label in its bundle and table using the environment's locale.
        /// Each bar is annotated with its value, formatted for the environment's locale.
        /// - Parameters:
        ///   - xAxisLabel: The localized label for the category axis.
        ///   - leftYAxisTitle: The localized label for the value axis.
        ///   - points: An array of `HorizontalBarChart.DataPoint` to display.
        public init(
            xAxisLabel: LocalizedStringResource,
            leftYAxisTitle: LocalizedStringResource,
            points: [HorizontalBarChart.DataPoint]
        ) {
            self.init(xAxisLabelText: .localized(xAxisLabel), yAxisTitleText: .localized(leftYAxisTitle), points: points)
        }

        private init(xAxisLabelText: LocalizableText, yAxisTitleText: LocalizableText, points: [HorizontalBarChart.DataPoint]) {
            self.xAxisLabelText = xAxisLabelText
            self.yAxisTitleText = yAxisTitleText
            dataPoints = points
        }

        /// The content and behavior of the view.
        public var body: some View {
            VStack(alignment: .leading, spacing: .medium) {
                Chart {
                    // Bar Chart for Absolute Values
                    ForEach(dataPoints, id: \.name) { data in
                        BarMark(
                            x: .value(yAxisTitleText.text, data.value),
                            y: .value(xAxisLabelText.text, data.name)
                        )
                        .annotation(position: .trailing) {
                            Text(data.value, format: .number)
                                .font(.caption)
                                .foregroundStyle(theme.text3)
                        }
                        .foregroundStyle(by: .value(xAxisLabelText.text, data.name))
                    }
                }
                .chartLegend(.hidden)

            }
            .padding(.large)
        }
    }

#endif

#if canImport(SwiftUI)
    import SnapshotPreviews
    import SwiftUI

    #if DEBUG
        @MainActor enum HorizontalBarChartPreviews: PreviewProvider, SnapshotProvider {
            static let defaultLayout: PreviewSnapshotLayout = .device

            static var snapshots: [PreviewSnapshot] {
                PreviewSnapshot("default") {
                    HorizontalBarChart(
                        xAxisLabel: "Category",
                        leftYAxisTitle: "Occurrences",
                        points: [
                            HorizontalBarChart.DataPoint(name: "Equipment", value: 330),
                            HorizontalBarChart.DataPoint(name: "Ingredient Shortage", value: 213),
                            HorizontalBarChart.DataPoint(name: "Maintenance", value: 122),
                            HorizontalBarChart.DataPoint(name: "Changeover", value: 30),
                            HorizontalBarChart.DataPoint(name: "Quality Control", value: 21),
                            HorizontalBarChart.DataPoint(name: "Other", value: 10)
                        ]
                    )
                }
            }
        }
    #endif
#endif
