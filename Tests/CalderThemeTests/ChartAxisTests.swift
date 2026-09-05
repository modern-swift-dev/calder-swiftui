#if canImport(SwiftUI)
@testable import CalderTheme
import Foundation
import Testing

@MainActor struct ChartAxisTests {
    @Test func `empty and zero valued charts have finite axis marks`() {
        let verticalPoints: [[VerticalBarChart.DataPoint]] = [[], [.init(name: "Zero", value: 0)]]
        for points in verticalPoints {
            let chart = VerticalBarChart(title: "", xAxisLabel: "", leftYAxisTitle: "", points: points)
            #expect(chart.markValues() == [0])
        }
        let paretoPoints: [[ParetoChart.RawDataPoint]] = [[], [.init(name: "Zero", value: 0)]]
        for points in paretoPoints {
            let chart = ParetoChart(title: "", xAxisLabel: "", leftYAxisTitle: "", rightYAxisTitle: "", points: points)
            #expect(chart.markValues() == [0])
            let allPercentagesAreFinite = points.computedPoints.allSatisfy(\.cumulated.isFinite)
            #expect(allPercentagesAreFinite)
        }
    }

    @Test func `zero negative and excessive tick counts do not produce zero strides`() {
        for count in [0, -1, 101] {
            let vertical = VerticalBarChart(title: "", nbMarks: count, xAxisLabel: "", leftYAxisTitle: "", points: [.init(name: "A", value: 1)])
            let pareto = ParetoChart(title: "", nbMarks: count, xAxisLabel: "", leftYAxisTitle: "", rightYAxisTitle: "", points: [.init(name: "A", value: 1)])
            #expect(vertical.markValues().first == 0)
            #expect(vertical.markValues().last == 100)
            #expect(pareto.markValues() == vertical.markValues())
            #expect(pareto.percentValue(for: 100) == 1.0.formatted(.percent))
        }
    }
}
#endif
