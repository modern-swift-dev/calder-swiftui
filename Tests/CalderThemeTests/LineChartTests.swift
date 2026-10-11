#if canImport(SwiftUI)
    @testable import CalderTheme
    import Foundation
    import Testing

    @MainActor struct LineChartTests {
        private static let date = Date(timeIntervalSince1970: 1_746_378_919)

        @Test(arguments: [(4, 4), (1, 1), (0, 1), (-3, 1)])
        func `nbMarks sets the desired y axis mark count`(nbMarks: Int, expected: Int) {
            let chart = LineChart(title: "", nbMarks: nbMarks, xAxisLabel: "", leftYAxisTitle: "", points: [])

            #expect(chart.yAxisMarkCount == expected)
        }

        @Test func `points sharing a date keep distinct identities`() {
            let chart = LineChart(
                title: "", xAxisLabel: "", leftYAxisTitle: "",
                points: [
                    .init(date: Self.date, value: 3),
                    .init(date: Self.date, value: 8),
                    .init(date: Self.date.addingTimeInterval(86400), value: 5)
                ]
            )

            #expect(Set(chart.plottedPoints.map(\.id)).count == 3)
            #expect(chart.plottedPoints.map(\.value) == [3, 8, 5])
        }
    }
#endif
