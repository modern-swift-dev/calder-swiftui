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

        @Test func `vertical bar chart domain and marks include negative values`() {
            let chart = VerticalBarChart(title: "", xAxisLabel: "", leftYAxisTitle: "", points: [
                .init(name: "Loss", value: -42),
                .init(name: "Gain", value: 15)
            ])

            #expect(chart.yDomain == -50 ... 20)
            #expect(chart.markValues() == [-50, 0, 4, 8, 12, 16, 20])
        }

        @Test func `vertical bar chart with only negative values ends its domain at zero`() {
            let chart = VerticalBarChart(title: "", xAxisLabel: "", leftYAxisTitle: "", points: [.init(name: "Loss", value: -3)])

            #expect(chart.yDomain == -3 ... 0)
            #expect(chart.markValues() == [-3, 0])
        }

        @Test func `vertical bar chart without negative values keeps a zero based domain`() {
            let empty = VerticalBarChart(title: "", xAxisLabel: "", leftYAxisTitle: "", points: [])
            let positive = VerticalBarChart(title: "", xAxisLabel: "", leftYAxisTitle: "", points: [.init(name: "A", value: 7)])

            #expect(empty.yDomain == 0 ... 1)
            #expect(positive.yDomain == 0 ... 7)
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
