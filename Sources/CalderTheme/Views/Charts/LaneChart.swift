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

        /// The chart label of a task's start date.
        static let startLabel = LocalizedStringResource("laneChart.start", bundle: .module)
        /// The chart label of a task's end date.
        static let endLabel = LocalizedStringResource("laneChart.end", bundle: .module)
        /// The chart label of a task's lane.
        static let taskLabel = LocalizedStringResource("laneChart.task", bundle: .module)
        /// The chart label of a task's colour category.
        static let categoryLabel = LocalizedStringResource("laneChart.category", bundle: .module)

        /// The array of data points to display in the chart.
        let data: [DataPoint]

        /// The content and behavior of the view.
        var body: some View {
            VStack {
                Chart(data) { task in
                    BarMark(
                        xStart: .value(Text(Self.startLabel), task.start),
                        xEnd: .value(Text(Self.endLabel), task.end),
                        y: .value(Text(Self.taskLabel), task.name)
                    )
                    .foregroundStyle(by: .value(Text(Self.categoryLabel), task.name))
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

#if DEBUG && canImport(SwiftUI)
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
