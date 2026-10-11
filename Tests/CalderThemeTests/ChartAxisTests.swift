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
                #expect(vertical.markValues().last == 1)
                #expect(pareto.markValues() == vertical.markValues())
                #expect(pareto.percentValue(for: 1) == 1.0.formatted(.percent))
            }
        }

        @Test(arguments: [
            (0, 0),
            (-3, 0),
            (1, 1),
            (7, 7),
            (10, 10),
            (15, 20),
            (99, 100),
            (100, 100),
            (101, 200),
            (330, 400),
            (1200, 2000)
        ])
        func `axis maximum rounds up to the leading digit of the data`(value: Int, expected: Int) {
            let vertical = VerticalBarChart(title: "", xAxisLabel: "", leftYAxisTitle: "", points: [.init(name: "A", value: value)])
            let pareto = ParetoChart(title: "", xAxisLabel: "", leftYAxisTitle: "", rightYAxisTitle: "", points: [.init(name: "A", value: value)])

            #expect(vertical.maxValue == expected)
            #expect(pareto.maxValue == expected)
        }

        @Test func `small values use an axis that fits them`() {
            let chart = VerticalBarChart(
                title: "", xAxisLabel: "", leftYAxisTitle: "",
                points: [.init(name: "A", value: 3), .init(name: "B", value: 7)]
            )

            #expect(chart.maxValue == 7)
            #expect(chart.markValues() == [0, 1, 2, 3, 4, 5, 6, 7])
        }
    }
#endif
