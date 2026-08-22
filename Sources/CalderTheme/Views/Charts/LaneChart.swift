#if canImport(SwiftUI)
import CalderStdLib
import CalderUIKit
import Charts
import Foundation
import SwiftUI

/// A SwiftUI view representing a lane chart, useful for visualizing timelines or gantt-like data.
struct LaneChartView: View {

    /// Represents a data point for the lane chart.
    struct DataPoint: Identifiable {
        /// A unique identifier for the data point.
        let id = UUID()
        /// The name or label for the lane/task.
        let name: String
        /// The start date of the task/event.
        let start: Date
        /// The end date of the task/event.
        let end: Date
    }

    /// The array of data points to display in the chart.
    let data: [DataPoint]

    /// The content and behavior of the view.
    var body: some View {
        VStack {
            Chart(data) { task in
                BarMark(
                    xStart: .value("Start", task.start),
                    xEnd: .value("End", task.end),
                    y: .value("Task", task.name)
                )
                .foregroundStyle(by: .value("Category", task.name))
            }
            .chartXAxis {
                AxisMarks(position: .bottom)
            }
            .chartYAxis {
                AxisMarks(position: .leading)
            }
            .chartLegend(.hidden)
            .chartScrollableAxes(.horizontal) // Allows horizontal scrolling for long timelines
        }
        .padding(.large)
    }
}

#endif

#if canImport(SwiftUI)
import CalderStdLib
import Foundation
import SnapshotPreviews
import SwiftUI

@MainActor enum LaneChartPreviews: PreviewProvider, SnapshotProvider {
    static let defaultLayout: PreviewSnapshotLayout = .device
    private static let date = Date(timeIntervalSince1970: 1_746_378_919)

    static var snapshots: [PreviewSnapshot] {
        PreviewSnapshot("default") {
            LaneChartView(data: [
                LaneChartView.DataPoint(name: "Idea", start: date, end: date.plusHour(1)),
                LaneChartView.DataPoint(name: "Analysis", start: date.plusHour(1), end: date.plusHour(2)),
                LaneChartView.DataPoint(name: "Design", start: date.plusHour(2), end: date.plusHour(3)),
                LaneChartView.DataPoint(name: "Implementation", start: date.plusHour(3), end: date.plusHour(5)),
                LaneChartView.DataPoint(name: "Testing", start: date.plusHour(5), end: date.plusHour(7)),
                LaneChartView.DataPoint(name: "Deployment", start: date.plusHour(7), end: date.plusHour(9))
            ])
        }
    }
}
#endif
