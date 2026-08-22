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

    /// The label for the Y-axis (category axis).
    public var xAxisLabel: String

    /// The label for the X-axis (value count).
    public var yAxisTitle: String

    /// The processed data points to be displayed in the chart.
    private var dataPoints: [DataPoint]

    /// Initializes the horizontal bar chart with given data points.
    /// - Parameters:
    ///   - xAxisLabel: The label for the category axis.
    ///   - leftYAxisTitle: The label for the value axis.
    ///   - points: An array of `HorizontalBarChart.DataPoint` to display.
    public init(
        xAxisLabel: String,
        leftYAxisTitle: String,
        points: [HorizontalBarChart.DataPoint]
    ) {
        self.xAxisLabel = xAxisLabel
        self.yAxisTitle = leftYAxisTitle
        self.dataPoints = points
    }

    /// The content and behavior of the view.
    public var body: some View {
        VStack(alignment: .leading, spacing: .medium) {
            Chart {
                // Bar Chart for Absolute Values
                ForEach(dataPoints, id: \.name) { data in
                    BarMark(
                        x: .value(yAxisTitle, data.value),
                        y: .value(xAxisLabel, data.name)
                    )
                    .annotation(position: .trailing) {
                        Text("\(data.value)")
                            .font(.caption)
                            .foregroundStyle(theme.text3)
                    }
                    .foregroundStyle(by: .value(xAxisLabel, data.name))
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
