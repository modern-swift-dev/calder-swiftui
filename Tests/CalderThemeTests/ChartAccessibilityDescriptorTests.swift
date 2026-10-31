#if canImport(SwiftUI)
    import Accessibility
    @testable import CalderTheme
    import Foundation
    import SwiftUI
    import Testing

    @MainActor struct ChartAccessibilityDescriptorTests {
        private static let english = Locale(identifier: "en_US")
        private static let french = Locale(identifier: "fr_FR")
        /// A catalog entry whose English value differs from its key, so a lookup is observable.
        private static let warning = LocalizedStringResource("messageBox.severity.warning", bundle: .module)
        private static let date = Date(timeIntervalSince1970: 1_746_378_919)

        @Test func `vertical bar chart describes its categories values and axes`() throws {
            let chart = VerticalBarChart(
                title: "Downtime", nbMarks: 2, xAxisLabel: "Category", leftYAxisTitle: "Occurrences",
                points: [.init(name: "A", value: 1200), .init(name: "B", value: -42), .init(name: "A", value: 7)]
            )

            let descriptor = chart.chartDescriptor(locale: Self.english).makeChartDescriptor()

            #expect(descriptor.title == "Downtime")
            let xAxis = try #require(descriptor.xAxis as? AXCategoricalDataAxisDescriptor)
            #expect(xAxis.title == "Category")
            #expect(xAxis.categoryOrder == ["A", "B"])
            let yAxis = try #require(descriptor.yAxis)
            #expect(yAxis.title == "Occurrences")
            #expect(yAxis.range == -50 ... 2000)
            #expect(yAxis.valueDescriptionProvider(1200) == "1,200")
            #expect(descriptor.series.count == 1)
            #expect(descriptor.series[0].name == "Occurrences")
            #expect(!descriptor.series[0].isContinuous)
            #expect(categories(descriptor.series[0]) == ["A", "B", "A"])
            #expect(numbers(descriptor.series[0]) == [1200, -42, 7])
        }

        @Test func `horizontal bar chart describes its categories and values`() throws {
            let chart = HorizontalBarChart(
                xAxisLabel: "Category", leftYAxisTitle: "Occurrences",
                points: [.init(name: "A", value: 330), .init(name: "B", value: 21)]
            )

            let descriptor = chart.chartDescriptor(locale: Self.french).makeChartDescriptor()

            #expect(descriptor.title == nil)
            let xAxis = try #require(descriptor.xAxis as? AXCategoricalDataAxisDescriptor)
            #expect(xAxis.title == "Category")
            #expect(xAxis.categoryOrder == ["A", "B"])
            let yAxis = try #require(descriptor.yAxis)
            #expect(yAxis.title == "Occurrences")
            #expect(yAxis.range == 0 ... 330)
            #expect(yAxis.valueDescriptionProvider(1200) == "1\u{202F}200")
            #expect(descriptor.series.map(\.name) == ["Occurrences"])
            #expect(numbers(descriptor.series[0]) == [330, 21])
        }

        @Test func `line chart describes its dates and values`() throws {
            let chart = LineChart(
                title: "Trend", xAxisLabel: "Day", leftYAxisTitle: "Count",
                points: [.init(date: Self.date, value: 10), .init(date: Self.date.addingTimeInterval(86400), value: 1500)]
            )

            let descriptor = chart.chartDescriptor(locale: Self.english).makeChartDescriptor()

            #expect(descriptor.title == "Trend")
            let xAxis = try #require(descriptor.xAxis as? AXNumericDataAxisDescriptor)
            #expect(xAxis.title == "Day")
            #expect(xAxis.range == Self.date.timeIntervalSince1970 ... Self.date.timeIntervalSince1970 + 86400)
            #expect(xAxis.valueDescriptionProvider(Self.date.timeIntervalSince1970) == "May 4, 2025")
            let yAxis = try #require(descriptor.yAxis)
            #expect(yAxis.title == "Count")
            #expect(yAxis.range == 0 ... 1500)
            #expect(yAxis.valueDescriptionProvider(1500) == "1,500")
            #expect(descriptor.series.map(\.name) == ["Count"])
            #expect(descriptor.series[0].isContinuous)
            #expect(descriptor.series[0].dataPoints.map(\.xValue.__number) == [
                Self.date.timeIntervalSince1970, Self.date.timeIntervalSince1970 + 86400
            ])
            #expect(numbers(descriptor.series[0]) == [10, 1500])
        }

        @Test func `lane chart describes the start and end of each task`() throws {
            let chart = LaneChartView(data: [
                .init(name: "Design", start: Self.date, end: Self.date.addingTimeInterval(3600)),
                .init(name: "Build", start: Self.date.addingTimeInterval(3600), end: Self.date.addingTimeInterval(7200))
            ])

            let descriptor = chart.chartDescriptor(locale: Self.english).makeChartDescriptor()

            let xAxis = try #require(descriptor.xAxis as? AXCategoricalDataAxisDescriptor)
            #expect(xAxis.title == "Task")
            #expect(xAxis.categoryOrder == ["Design", "Build"])
            let yAxis = try #require(descriptor.yAxis)
            #expect(yAxis.title == "Time")
            #expect(yAxis.range == Self.date.timeIntervalSince1970 ... Self.date.timeIntervalSince1970 + 7200)
            #expect(yAxis.valueDescriptionProvider(Self.date.timeIntervalSince1970) == "May 4, 2025 at 5:15\u{202F}PM")
            #expect(descriptor.series.map(\.name) == ["Start", "End"])
            #expect(numbers(descriptor.series[0]) == [Self.date.timeIntervalSince1970, Self.date.timeIntervalSince1970 + 3600])
            #expect(numbers(descriptor.series[1]) == [Self.date.timeIntervalSince1970 + 3600, Self.date.timeIntervalSince1970 + 7200])
        }

        @Test func `pareto chart describes cumulative values as percentages`() throws {
            let chart = ParetoChart(
                title: "Downtime", xAxisLabel: "Category", leftYAxisTitle: "Occurrences", rightYAxisTitle: "Cumulative",
                points: [.init(name: "B", value: 100), .init(name: "A", value: 300)]
            )

            let descriptor = chart.chartDescriptor(locale: Self.english).makeChartDescriptor()

            #expect(descriptor.title == "Downtime")
            let xAxis = try #require(descriptor.xAxis as? AXCategoricalDataAxisDescriptor)
            #expect(xAxis.categoryOrder == ["A", "B"])
            let yAxis = try #require(descriptor.yAxis)
            #expect(yAxis.title == "Occurrences")
            #expect(yAxis.range == 0 ... 300)
            let percentAxis = try #require(descriptor.additionalAxes.first as? AXNumericDataAxisDescriptor)
            #expect(descriptor.additionalAxes.count == 1)
            #expect(percentAxis.title == "Cumulative")
            #expect(percentAxis.range == 0 ... 1)
            #expect(percentAxis.valueDescriptionProvider(1) == "100%")
            #expect(descriptor.series.map(\.name) == ["Occurrences"])
            #expect(numbers(descriptor.series[0]) == [300, 100])
            #expect(descriptor.series[0].dataPoints.map { $0.__additionalValues.map(\.__number) } == [[0.75], [1]])
        }

        @Test func `pareto percentages are formatted for the locale`() throws {
            let chart = ParetoChart(
                title: "", xAxisLabel: "", leftYAxisTitle: "", rightYAxisTitle: "",
                points: [.init(name: "A", value: 10)]
            )

            let descriptor = chart.chartDescriptor(locale: Self.french).makeChartDescriptor()

            let percentAxis = try #require(descriptor.additionalAxes.first as? AXNumericDataAxisDescriptor)
            #expect(percentAxis.valueDescriptionProvider(0.5) == "50\u{00A0}%")
        }

        @Test func `chart descriptors resolve localized titles for the locale`() {
            let vertical = VerticalBarChart(
                title: Self.warning, xAxisLabel: Self.warning, leftYAxisTitle: Self.warning, points: [.init(name: "A", value: 1)]
            )
            let horizontal = HorizontalBarChart(xAxisLabel: Self.warning, leftYAxisTitle: Self.warning, points: [.init(name: "A", value: 1)])
            let line = LineChart(
                title: Self.warning, xAxisLabel: Self.warning, leftYAxisTitle: Self.warning, points: [.init(date: Self.date, value: 1)]
            )
            let pareto = ParetoChart(
                title: Self.warning, xAxisLabel: Self.warning, leftYAxisTitle: Self.warning, rightYAxisTitle: Self.warning,
                points: [.init(name: "A", value: 1)]
            )

            for descriptor in [
                vertical.chartDescriptor(locale: Self.english).makeChartDescriptor(),
                line.chartDescriptor(locale: Self.english).makeChartDescriptor(),
                pareto.chartDescriptor(locale: Self.english).makeChartDescriptor()
            ] {
                #expect(descriptor.title == "Warning")
                #expect(descriptor.xAxis.title == "Warning")
                #expect(descriptor.yAxis?.title == "Warning")
                #expect(descriptor.series.first?.name == "Warning")
            }
            let horizontalDescriptor = horizontal.chartDescriptor(locale: Self.english).makeChartDescriptor()
            #expect(horizontalDescriptor.xAxis.title == "Warning")
            #expect(horizontalDescriptor.yAxis?.title == "Warning")
            #expect(pareto.chartDescriptor(locale: Self.english).makeChartDescriptor().additionalAxes.first?.title == "Warning")
        }

        @Test func `empty charts produce a descriptor without data points`() {
            let vertical = VerticalBarChart(title: "", xAxisLabel: "", leftYAxisTitle: "", points: [])
            let line = LineChart(title: "", xAxisLabel: "", leftYAxisTitle: "", points: [])

            #expect(vertical.chartDescriptor(locale: Self.english).makeChartDescriptor().series.first?.dataPoints.isEmpty == true)
            #expect(line.chartDescriptor(locale: Self.english).makeChartDescriptor().series.first?.dataPoints.isEmpty == true)
        }

        private func categories(_ series: AXDataSeriesDescriptor) -> [String] {
            series.dataPoints.map(\.xValue.__category)
        }

        private func numbers(_ series: AXDataSeriesDescriptor) -> [Double?] {
            series.dataPoints.map { $0.yValue?.__number }
        }
    }
#endif
