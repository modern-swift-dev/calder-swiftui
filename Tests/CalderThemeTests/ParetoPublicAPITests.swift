#if canImport(SwiftUI)
import CalderTheme
import Testing

@MainActor struct ParetoPublicAPITests {
    @Test func `a library client can create a populated Pareto chart`() {
        let chart = ParetoChart(
            title: "Counts", xAxisLabel: "Category", leftYAxisTitle: "Count", rightYAxisTitle: "Percent",
            points: [.init(name: "Example", value: 10)]
        )
        #expect(chart.maxValue == 100)
    }
}
#endif
