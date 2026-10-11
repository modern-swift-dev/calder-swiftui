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

        /// The desired number of marks on the Y-axis. Swift Charts picks evenly spaced, rounded
        /// values close to this count. Values below one request a single mark.
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

        /// The data points to be displayed in the chart.
        private var dataPoints: [DataPoint]

        /// A data point paired with its position, so points sharing a date keep distinct identities.
        struct PlottedPoint: Identifiable {
            /// The position of the point in the input data.
            let id: Int
            /// The date for the data point (X-axis).
            let date: Date
            /// The value associated with the date (Y-axis).
            let value: Int
        }

        /// The data points in input order, identified by position rather than by date.
        var plottedPoints: [PlottedPoint] {
            dataPoints.enumerated().map { PlottedPoint(id: $0.offset, date: $0.element.date, value: $0.element.value) }
        }

        /// The desired Y-axis mark count derived from `nbMarks`, never less than one.
        var yAxisMarkCount: Int {
            max(1, nbMarks)
        }

        /// Initializes the line chart with given data points.
        /// - Parameters:
        ///   - title: The title of the chart, displayed unchanged.
        ///   - nbMarks: The desired number of marks on the Y-axis. Defaults to 5.
        ///   - xAxisLabel: The label for the X-axis, displayed unchanged.
        ///   - leftYAxisTitle: The label for the Y-axis, displayed unchanged.
        ///   - points: An array of `DataPoint` to display. Several points may share a date.
        public init(
            title: String,
            nbMarks: Int = 5,
            xAxisLabel: String,
            leftYAxisTitle: String,
            points: [DataPoint]
        ) {
            self.init(
                titleText: .verbatim(title),
                nbMarks: nbMarks,
                xAxisLabelText: .verbatim(xAxisLabel),
                yAxisTitleText: .verbatim(leftYAxisTitle),
                points: points
            )
        }

        /// Initializes the line chart with localized labels.
        ///
        /// SwiftUI looks up each label in its bundle and table using the environment's locale.
        /// - Parameters:
        ///   - title: The localized title of the chart.
        ///   - nbMarks: The desired number of marks on the Y-axis. Defaults to 5.
        ///   - xAxisLabel: The localized label for the X-axis.
        ///   - leftYAxisTitle: The localized label for the Y-axis.
        ///   - points: An array of `DataPoint` to display. Several points may share a date.
        public init(
            title: LocalizedStringResource,
            nbMarks: Int = 5,
            xAxisLabel: LocalizedStringResource,
            leftYAxisTitle: LocalizedStringResource,
            points: [DataPoint]
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
            points: [DataPoint]
        ) {
            self.titleText = titleText
            self.nbMarks = nbMarks
            self.xAxisLabelText = xAxisLabelText
            self.yAxisTitleText = yAxisTitleText
            dataPoints = points
        }

        /// The content and behavior of the view.
        public var body: some View {
            VStack(alignment: .leading, spacing: .medium) {
                Chart {

                    // Line Chart for Cumulative Percentage
                    ForEach(plottedPoints) { data in
                        LineMark(
                            x: .value(xAxisLabelText.text, data.date),
                            y: .value(yAxisTitleText.text, data.value)
                        )
                        .lineStyle(StrokeStyle(lineWidth: 2))
                        .foregroundStyle(theme.error)
                        .interpolationMethod(.linear)
                    }

                    // Circle Markers on Line Chart
                    ForEach(plottedPoints) { data in
                        PointMark(
                            x: .value(xAxisLabelText.text, data.date),
                            y: .value(yAxisTitleText.text, data.value)
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
                    AxisMarks(
                        position: .automatic,
                        values: .automatic
                    )
                }
                .chartYAxis {
                    AxisMarks(
                        position: .leading,
                        values: .automatic(desiredCount: yAxisMarkCount)
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
