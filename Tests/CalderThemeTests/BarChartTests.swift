#if canImport(SwiftUI)
    @testable import CalderTheme
    import Testing

    @MainActor struct BarChartTests {
        @Test func `vertical bar chart identifies points with duplicate names by position`() {
            let chart = VerticalBarChart(title: "Title", xAxisLabel: "X", leftYAxisTitle: "Y", points: [
                .init(name: "Other", value: 20),
                .init(name: "Other", value: 10),
                .init(name: "Equipment", value: 5)
            ])

            #expect(chart.plottedPoints.map(\.id) == [0, 1, 2])
            #expect(chart.plottedPoints.map(\.name) == ["Other", "Other", "Equipment"])
            #expect(chart.plottedPoints.map(\.value) == [20, 10, 5])
        }

        @Test func `horizontal bar chart identifies points with duplicate names by position`() {
            let chart = HorizontalBarChart(xAxisLabel: "X", leftYAxisTitle: "Y", points: [
                .init(name: "Other", value: 20),
                .init(name: "Other", value: 10)
            ])

            #expect(chart.plottedPoints.map(\.id) == [0, 1])
            #expect(chart.plottedPoints.map(\.value) == [20, 10])
        }
    }
#endif
