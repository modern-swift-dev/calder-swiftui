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

    /// The number of marks on the Y-axis.
    public var nbMarks: Int

    /// The title of the chart.
    public var title: String

    /// The label for the X-axis.
    public var xAxisLabel: String

    /// The label for the Y-axis (value count).
    public var yAxisTitle: String

    /// The maximum value for scaling the Y-axis.
    public var maxValue: Int

    /// The data points to be displayed in the chart.
    private var dataPoints: [DataPoint]

    /// Initializes the vertical bar chart with given data points.
    /// - Parameters:
    ///   - title: The title of the chart.
    ///   - nbMarks: The number of marks on the Y-axis. Defaults to 5.
    ///   - xAxisLabel: The label for the X-axis.
    ///   - leftYAxisTitle: The label for the Y-axis.
    ///   - points: An array of `VerticalBarChart.DataPoint` to display.
    public init(
        title: String,
        nbMarks: Int = 5,
        xAxisLabel: String,
        leftYAxisTitle: String,
        points: [VerticalBarChart.DataPoint]
    ) {
        self.title = title
        self.nbMarks = nbMarks
        self.xAxisLabel = xAxisLabel
        self.yAxisTitle = leftYAxisTitle
        self.maxValue = points.maxValue
        self.dataPoints = points
    }

    /// The content and behavior of the view.
    public var body: some View {
        VStack(alignment: .leading, spacing: .medium) {
            Chart {
                // Bar Chart for Absolute Values
                ForEach(dataPoints, id: \.name) { data in
                    BarMark(
                        x: .value(xAxisLabel, data.name),
                        y: .value(yAxisTitle, data.value)
                    )
                    .annotation(position: .top) {
                        Text("\(data.value)")
                            .font(.caption)
                            .foregroundStyle(theme.text3)
                    }
                    .foregroundStyle(by: .value(xAxisLabel, data.name))
                }
            }
            .chartYAxisLabel(position: .leading) {
                Text(yAxisTitle)
                    .font(.caption)
                    .foregroundStyle(theme.text3)
            }
            .chartXAxisLabel(position: .top, alignment: .center, spacing: .large) {
                Text(title)
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
        .chartYScale(domain: 0 ... maxValue)
        .chartLegend(.visible)
        .chartLegend(position: .bottom, alignment: .center, spacing: .small)
        .padding(.large)
    }

    /// Computes evenly spaced Y-axis values.
    /// - Returns: An array of `Int` values for axis marks.
    private func markValues() -> [Int] {
        var values: [Int] = []
        for x in stride(from: 0, to: maxValue, by: maxValue / nbMarks) {
            values.append(x)
        }
        values.append(maxValue)
        return values
    }

}

extension [VerticalBarChart.DataPoint] {
    /// Calculates the maximum value for Y-axis scaling, rounded up to the nearest hundred.
    var maxValue: Int {
        let values: [Int] = map(\.value)
        let max = values.max() ?? 0
        return Int(ceil(Double(max) / 100.0)) * 100
    }
}

#endif

#if canImport(SwiftUI)
import SnapshotPreviews
import SwiftUI

#if DEBUG
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
