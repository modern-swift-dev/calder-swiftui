#if canImport(SwiftUI)
    import Accessibility
    import CalderStdLib
    import CalderUIKit
    import Charts
    import Foundation
    import SwiftUI

    /// A SwiftUI view representing a lane chart, useful for visualizing timelines or gantt-like data.
    ///
    /// The chart provides an Audio Graphs descriptor with the start and end of each task.
    struct LaneChartView: View {

        /// The locale used to describe the chart's values to Audio Graphs.
        @Environment(\.locale) private var locale

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
        /// The Audio Graphs title of the time axis.
        static let timeLabel = LocalizedStringResource("laneChart.time", bundle: .module)

        /// The array of data points to display in the chart.
        let data: [DataPoint]

        /// The state shown instead of the chart when there are no data points, or `nil` for the default.
        private let emptyState: GenericState?

        /// Creates a lane chart.
        /// - Parameters:
        ///   - data: The tasks to display.
        ///   - emptyState: The state shown instead of the chart when `data` is empty. Defaults to `nil`,
        ///     which shows `GenericState.empty` with a localized "No data" message.
        init(data: [DataPoint], emptyState: GenericState? = nil) {
            self.data = data
            self.emptyState = emptyState
        }

        /// The content and behavior of the view: the chart, or the empty state when there are no data points.
        var body: some View {
            GenericStateView(state: displayedState(locale: locale)) {
                chartContent
            }
        }

        /// The state the view displays: `.displaying` when there are data points, and otherwise the
        /// custom empty state or an `.empty` state with a localized "No data" message.
        /// - Parameter locale: The locale used to look up the default message.
        /// - Returns: The state passed to `GenericStateView`.
        func displayedState(locale: Locale) -> GenericState {
            ChartEmptyState.state(emptyState, isEmpty: data.isEmpty, locale: locale)
        }

        /// The chart drawn when there are data points.
        private var chartContent: some View {
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
                .accessibilityChartDescriptor(chartDescriptor(locale: locale))
            }
            .padding(.spacingLarge)
        }

        /// The Audio Graphs description of the chart: the tasks on a category axis, and a start series
        /// and an end series on a time axis described as dates and times.
        /// - Parameter locale: The locale used to resolve labels and format dates.
        /// - Returns: The chart's descriptor.
        func chartDescriptor(locale: Locale) -> ChartDescriptor {
            let taskTitle = ChartDescriptor.string(Self.taskLabel, locale: locale)
            let timeTitle = ChartDescriptor.string(Self.timeLabel, locale: locale)
            let startTitle = ChartDescriptor.string(Self.startLabel, locale: locale)
            let endTitle = ChartDescriptor.string(Self.endLabel, locale: locale)
            let tasks = data.map { (name: $0.name, start: $0.start.timeIntervalSince1970, end: $0.end.timeIntervalSince1970) }
            let times = tasks.flatMap { [$0.start, $0.end] }
            let range = (times.min() ?? 0) ... (times.max() ?? 0)
            let timeStyle = Date.FormatStyle(date: .abbreviated, time: .shortened, locale: locale)
            return ChartDescriptor {
                AXChartDescriptor(
                    title: nil,
                    xAxis: AXCategoricalDataAxisDescriptor(title: taskTitle, categoryOrder: ChartDescriptor.categories(tasks.map(\.name))),
                    yAxis: AXNumericDataAxisDescriptor(title: timeTitle, range: range, gridlinePositions: []) { value in
                        Date(timeIntervalSince1970: value).formatted(timeStyle)
                    },
                    series: [
                        AXDataSeriesDescriptor(
                            name: startTitle,
                            isContinuous: false,
                            dataPoints: tasks.map { AXDataPoint(x: $0.name, y: $0.start) }
                        ),
                        AXDataSeriesDescriptor(
                            name: endTitle,
                            isContinuous: false,
                            dataPoints: tasks.map { AXDataPoint(x: $0.name, y: $0.end) }
                        )
                    ]
                )
            }
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
