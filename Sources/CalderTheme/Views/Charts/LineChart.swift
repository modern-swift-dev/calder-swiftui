#if canImport(SwiftUI)
import CalderStdLib
import CalderUIKit
import Charts
import Foundation
import SwiftUI

/// A SwiftUI view representing a line chart.
public struct LineChart: View {

    /// The current theme, injected via Environment.
    @Environment(\.theme) var theme

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

    /// The number of marks on the Y-axis.
    public var nbMarks: Int

    /// The title of the chart.
    public var title: String

    /// The label for the X-axis.
    public var xAxisLabel: String

    /// The label for the Y-axis (value count).
    public var yAxisTitle: String

    /// The data points to be displayed in the chart.
    private var dataPoints: [DataPoint]

    /// Initializes the line chart with given data points.
    /// - Parameters:
    ///   - title: The title of the chart.
    ///   - nbMarks: The number of marks on the Y-axis. Defaults to 5.
    ///   - xAxisLabel: The label for the X-axis.
    ///   - leftYAxisTitle: The label for the Y-axis.
    ///   - points: An array of `DataPoint` to display.
    public init(
        title: String,
        nbMarks: Int = 5,
        xAxisLabel: String,
        leftYAxisTitle: String,
        points: [DataPoint]
    ) {
        self.title = title
        self.nbMarks = nbMarks
        self.xAxisLabel = xAxisLabel
        self.yAxisTitle = leftYAxisTitle
        self.dataPoints = points
    }

    /// The content and behavior of the view.
    public var body: some View {
        VStack(alignment: .leading, spacing: .medium) {
            Chart {

                // Line Chart for Cumulative Percentage
                ForEach(dataPoints, id: \.date) { data in
                    LineMark(
                        x: .value(xAxisLabel, data.date),
                        y: .value(yAxisTitle, data.value)
                    )
                    .lineStyle(StrokeStyle(lineWidth: 2))
                    .foregroundStyle(theme.error)
                    .interpolationMethod(.linear)
                }

                // Circle Markers on Line Chart
                ForEach(dataPoints, id: \.date) { data in
                    PointMark(
                        x: .value(xAxisLabel, data.date),
                        y: .value(yAxisTitle, data.value)
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
                AxisMarks(
                    position: .automatic,
                    values: .automatic
                )
            }
            .chartYAxis {
                AxisMarks(
                    position: .leading,
                    values: .automatic
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
        .padding(.large)
    }

}

extension [LineChart.DataPoint] {
    /// Calculates the maximum value for Y-axis scaling, rounded up to the nearest hundred.
    var maxValue: Int {
        let values: [Int] = map(\.value)
        let max = values.max() ?? 0
        return Int(ceil(Double(max) / 100.0)) * 100
    }
}

#endif

#if canImport(SwiftUI)
import CalderStdLib
import Foundation
import SnapshotPreviews
import SwiftUI

#if DEBUG
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
