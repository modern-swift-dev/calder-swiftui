#if canImport(SwiftUI)
    import Accessibility
    import CalderUIKit
    import Charts
    import Foundation
    import SwiftUI

    /// A SwiftUI view representing a horizontal bar chart.
    public struct HorizontalBarChart: View {

        /// The current theme, injected via Environment.
        @Environment(\.theme) var theme

        /// The locale used to describe the chart's values to Audio Graphs.
        @Environment(\.locale) private var locale

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

        /// The state shown instead of the chart when there are no data points, or `nil` for the default.
        private let emptyState: GenericState?

        /// A data point paired with its position, so points sharing a name keep distinct identities.
        struct PlottedPoint: Identifiable {
            /// The position of the point in the input data.
            let id: Int
            /// The category name for the bar.
            let name: String
            /// The value associated with the category.
            let value: Int
        }

        /// The data points in input order, identified by position rather than by name.
        var plottedPoints: [PlottedPoint] {
            dataPoints.enumerated().map { PlottedPoint(id: $0.offset, name: $0.element.name, value: $0.element.value) }
        }

        /// Initializes the horizontal bar chart with given data points.
        ///
        /// Each bar is annotated with its value, formatted for the environment's locale.
        /// The chart provides an Audio Graphs descriptor with its axes and values.
        /// - Parameters:
        ///   - xAxisLabel: The label for the category axis, displayed unchanged.
        ///   - leftYAxisTitle: The label for the value axis, displayed unchanged.
        ///   - points: An array of `HorizontalBarChart.DataPoint` to display.
        ///   - emptyState: The state shown instead of the chart when there are no data points. Defaults to
        ///     `nil`, which shows `GenericState.empty` with a localized "No data" message.
        public init(
            xAxisLabel: String,
            leftYAxisTitle: String,
            points: [HorizontalBarChart.DataPoint],
            emptyState: GenericState? = nil
        ) {
            self.init(xAxisLabelText: .verbatim(xAxisLabel), yAxisTitleText: .verbatim(leftYAxisTitle), points: points, emptyState: emptyState)
        }

        /// Initializes the horizontal bar chart with localized axis labels.
        ///
        /// SwiftUI looks up each label in its bundle and table using the environment's locale.
        /// Each bar is annotated with its value, formatted for the environment's locale.
        /// The chart provides an Audio Graphs descriptor with its axes and values.
        /// - Parameters:
        ///   - xAxisLabel: The localized label for the category axis.
        ///   - leftYAxisTitle: The localized label for the value axis.
        ///   - points: An array of `HorizontalBarChart.DataPoint` to display.
        ///   - emptyState: The state shown instead of the chart when there are no data points. Defaults to
        ///     `nil`, which shows `GenericState.empty` with a localized "No data" message.
        public init(
            xAxisLabel: LocalizedStringResource,
            leftYAxisTitle: LocalizedStringResource,
            points: [HorizontalBarChart.DataPoint],
            emptyState: GenericState? = nil
        ) {
            self.init(xAxisLabelText: .localized(xAxisLabel), yAxisTitleText: .localized(leftYAxisTitle), points: points, emptyState: emptyState)
        }

        private init(
            xAxisLabelText: LocalizableText,
            yAxisTitleText: LocalizableText,
            points: [HorizontalBarChart.DataPoint],
            emptyState: GenericState?
        ) {
            self.emptyState = emptyState
            self.xAxisLabelText = xAxisLabelText
            self.yAxisTitleText = yAxisTitleText
            dataPoints = points
        }

        /// The content and behavior of the view: the chart, or the empty state when there are no data points.
        public var body: some View {
            GenericStateView(state: displayedState(locale: locale)) {
                chartContent
            }
        }

        /// The state the view displays: `.displaying` when there are data points, and otherwise the
        /// custom empty state or an `.empty` state with a localized "No data" message.
        /// - Parameter locale: The locale used to look up the default message.
        /// - Returns: The state passed to `GenericStateView`.
        func displayedState(locale: Locale) -> GenericState {
            ChartEmptyState.state(emptyState, isEmpty: dataPoints.isEmpty, locale: locale)
        }

        /// The chart drawn when there are data points.
        private var chartContent: some View {
            VStack(alignment: .leading, spacing: .spacingMedium) {
                Chart {
                    // Bar Chart for Absolute Values
                    ForEach(plottedPoints) { data in
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
                .accessibilityChartDescriptor(chartDescriptor(locale: locale))
            }
            .padding(.spacingLarge)
        }

        /// The Audio Graphs description of the chart: one bar per data point, in input order, with
        /// the categories on the descriptor's X-axis and the values on its Y-axis.
        /// - Parameter locale: The locale used to resolve localized labels and format values.
        /// - Returns: The chart's descriptor.
        func chartDescriptor(locale: Locale) -> ChartDescriptor {
            let categoryTitle = ChartDescriptor.string(xAxisLabelText, locale: locale)
            let valueTitle = ChartDescriptor.string(yAxisTitleText, locale: locale)
            let points = plottedPoints.map { (name: $0.name, value: Double($0.value)) }
            return ChartDescriptor {
                AXChartDescriptor(
                    title: nil,
                    xAxis: AXCategoricalDataAxisDescriptor(title: categoryTitle, categoryOrder: ChartDescriptor.categories(points.map(\.name))),
                    yAxis: AXNumericDataAxisDescriptor(
                        title: valueTitle,
                        range: ChartDescriptor.zeroBasedRange(points.map(\.value)),
                        gridlinePositions: [],
                        valueDescriptionProvider: ChartDescriptor.numberDescription(locale: locale)
                    ),
                    series: [
                        AXDataSeriesDescriptor(
                            name: valueTitle,
                            isContinuous: false,
                            dataPoints: points.map { AXDataPoint(x: $0.name, y: $0.value) }
                        )
                    ]
                )
            }
        }
    }

#endif

#if canImport(SwiftUI)
    import SwiftUI

    #if DEBUG
        import SnapshotPreviews

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
