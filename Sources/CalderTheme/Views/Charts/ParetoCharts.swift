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
        /// The absolute value associated with the category (left Y-axis).
        var value: Int

        /// Creates a category and its absolute value for a Pareto chart.
        /// - Parameters:
        ///   - name: The category label.
        ///   - value: The absolute value for the category.
        public init(name: String, value: Int) {
            self.name = name
            self.value = value
        }
    }

    /// Represents a processed data point with cumulative percentage for the Pareto chart.
    struct DataPoint {
        /// The category name (X-axis).
        var name: String
        /// The absolute value associated with the category (left Y-axis).
        var value: Int
        /// The cumulative percentage value, scaled to the maximum value (right Y-axis).
        var cumulated: Double
    }

    /// The requested number of intervals on the Y-axis. Values below one use one interval.
    public var nbMarks: Int

    /// The title of the chart.
    public var title: String

    /// The label for the X-axis.
    public var xAxisLabel: String

    /// The label for the left Y-axis (value count).
    public var leftYAxisTitle: String

    /// The label for the right Y-axis (cumulative percentage).
    public var rightYAxisTitle: String

    /// The maximum value for scaling the left Y-axis.
    public var maxValue: Int

    /// The processed data points, including cumulative percentages.
    private var dataPoints: [DataPoint]

    /// Initializes the Pareto chart with given raw data points.
    /// - Parameters:
    ///   - title: The title of the chart.
    ///   - nbMarks: The number of marks on the Y-axis. Defaults to 5.
    ///   - xAxisLabel: The label for the X-axis.
    ///   - leftYAxisTitle: The label for the left Y-axis.
    ///   - rightYAxisTitle: The label for the right Y-axis.
    ///   - points: An array of `RawDataPoint` to process and display.
    public init(
        title: String,
        nbMarks: Int = 5,
        xAxisLabel: String,
        leftYAxisTitle: String,
        rightYAxisTitle: String,
        points: [RawDataPoint]
    ) {
        self.title = title
        self.nbMarks = nbMarks
        self.xAxisLabel = xAxisLabel
        self.leftYAxisTitle = leftYAxisTitle
        self.rightYAxisTitle = rightYAxisTitle
        self.maxValue = points.maxValue
        self.dataPoints = points.computedPoints
    }

    /// The content and behavior of the view.
    public var body: some View {
        VStack(alignment: .leading, spacing: .medium) {
            Chart {
                // Bar Chart for Absolute Values
                ForEach(dataPoints, id: \.name) { data in
                    BarMark(
                        x: .value(xAxisLabel, data.name),
                        y: .value(leftYAxisTitle, data.value)
                    )
                    .annotation(position: .top) {
                        Text("\(data.value)")
                            .font(.caption)
                            .foregroundStyle(theme.text3)
                    }
                    .foregroundStyle(by: .value(xAxisLabel, data.name))
                }

                // Line Chart for Cumulative Percentage
                ForEach(dataPoints, id: \.name) { data in
                    LineMark(
                        x: .value(xAxisLabel, data.name),
                        y: .value(rightYAxisTitle, data.cumulated)
                    )
                    .lineStyle(StrokeStyle(lineWidth: 2))
                    .foregroundStyle(theme.error)
                    .interpolationMethod(.linear)
                }

                // Circle Markers on Line Chart
                ForEach(dataPoints, id: \.name) { data in
                    PointMark(
                        x: .value(xAxisLabel, data.name),
                        y: .value(rightYAxisTitle, data.cumulated)
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
                Text(leftYAxisTitle)
                    .font(.caption)
                    .foregroundStyle(theme.text3)
            }
            .chartYAxisLabel(position: .trailing) {
                Text(rightYAxisTitle)
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

                // Right Y-Axis Markings (Percentage Scale)
                AxisMarks(
                    position: .trailing,
                    values: markValues()
                ) { value in
                    AxisValueLabel(percentValue(for: value.as(Int.self) ?? 0))
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
    /// - Parameter value: The value of the axis mark.
    /// - Returns: A string representing the percentage.
    func percentValue(for value: Int) -> String {
        (maxValue > 0 ? Double(value) / Double(maxValue) : 0).formatted(.percent)
    }
}

extension [ParetoChart.RawDataPoint] {
    /// Calculates the maximum raw value from the data points, rounded up to the nearest hundred, for Y-axis scaling.
    var maxValue: Int {
        let values: [Int] = map(\.value)
        let max = values.max() ?? 0
        return Int(ceil(Double(max) / 100.0)) * 100
    }

    /// Computes cumulative percentage for Pareto chart representation.
    /// The `cumulated` value is scaled to `maxValue` for display on the secondary Y-axis.
    var computedPoints: [ParetoChart.DataPoint] {
        let total = map(\.value).reduce(0, +)
        var cumulativeSum = 0
        return map { point in
            cumulativeSum += point.value
            return .init(
                name: point.name,
                value: point.value,
                cumulated: total == 0 ? 0 : Double(cumulativeSum) / Double(total) * Double(maxValue)
            )
        }
    }
}

#endif

#if canImport(SwiftUI)
import SnapshotPreviews
import SwiftUI

#if DEBUG
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
