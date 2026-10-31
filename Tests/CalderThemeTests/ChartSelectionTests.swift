#if canImport(SwiftUI)
    @testable import CalderTheme
    import Foundation
    import SwiftUI
    import Testing

    @MainActor struct ChartSelectionTests {
        private static let date = Date(timeIntervalSince1970: 1_746_378_919)
        private static let barPoints: [VerticalBarChart.DataPoint] = [.init(name: "A", value: 30), .init(name: "B", value: 20)]
        private static let horizontalPoints: [HorizontalBarChart.DataPoint] = [.init(name: "A", value: 30), .init(name: "B", value: 20)]
        private static let linePoints: [LineChart.DataPoint] = [
            .init(date: date, value: 10), .init(date: date.addingTimeInterval(86400), value: 30)
        ]

        @Test func `bar charts highlight the selected category`() {
            let vertical = VerticalBarChart(title: "", xAxisLabel: "", leftYAxisTitle: "", points: Self.barPoints, selection: .constant("A"))
            let horizontal = HorizontalBarChart(xAxisLabel: "", leftYAxisTitle: "", points: Self.horizontalPoints, selection: .constant("A"))

            #expect(vertical.opacity(forCategory: "A") == 1)
            #expect(vertical.opacity(forCategory: "B") < 1)
            #expect(horizontal.opacity(forCategory: "A") == 1)
            #expect(horizontal.opacity(forCategory: "B") < 1)
        }

        @Test func `bar charts without a selection draw every bar fully`() {
            let charts = [
                VerticalBarChart(title: "", xAxisLabel: "", leftYAxisTitle: "", points: Self.barPoints),
                VerticalBarChart(title: "", xAxisLabel: "", leftYAxisTitle: "", points: Self.barPoints, selection: .constant(nil))
            ]
            let horizontalCharts = [
                HorizontalBarChart(xAxisLabel: "", leftYAxisTitle: "", points: Self.horizontalPoints),
                HorizontalBarChart(xAxisLabel: "", leftYAxisTitle: "", points: Self.horizontalPoints, selection: .constant(nil))
            ]

            for chart in charts {
                #expect(chart.opacity(forCategory: "A") == 1)
                #expect(chart.opacity(forCategory: "B") == 1)
            }
            for chart in horizontalCharts {
                #expect(chart.opacity(forCategory: "A") == 1)
                #expect(chart.opacity(forCategory: "B") == 1)
            }
        }

        @Test func `selection bindings receive the selected value`() {
            var category: String?
            var date: Date?
            let categoryBinding = Binding(get: { category }, set: { category = $0 })
            let dateBinding = Binding(get: { date }, set: { date = $0 })
            let vertical = VerticalBarChart(
                title: LocalizedStringResource(stringLiteral: ""), xAxisLabel: "", leftYAxisTitle: "",
                points: Self.barPoints, selection: categoryBinding
            )
            let horizontal = HorizontalBarChart(
                xAxisLabel: LocalizedStringResource(stringLiteral: ""), leftYAxisTitle: "",
                points: Self.horizontalPoints, selection: categoryBinding
            )
            let line = LineChart(
                title: LocalizedStringResource(stringLiteral: ""), xAxisLabel: "", leftYAxisTitle: "",
                points: Self.linePoints, selection: dateBinding
            )

            vertical.selection?.wrappedValue = "B"
            #expect(category == "B")
            horizontal.selection?.wrappedValue = "A"
            #expect(category == "A")
            line.selection?.wrappedValue = Self.date
            #expect(date == Self.date)
            #expect(line.selectedDate == Self.date)
        }

        @Test func `line chart without a selection has no selected date`() {
            #expect(LineChart(title: "", xAxisLabel: "", leftYAxisTitle: "", points: Self.linePoints).selectedDate == nil)
            #expect(LineChart(title: "", xAxisLabel: "", leftYAxisTitle: "", points: Self.linePoints, selection: .constant(nil)).selectedDate == nil)
        }

        @Test func `a nil selection renders like a chart without a binding`() throws {
            let plain = try #require(render(VerticalBarChart(title: "", xAxisLabel: "", leftYAxisTitle: "", points: Self.barPoints)))
            let unselected = try #require(render(VerticalBarChart(
                title: "", xAxisLabel: "", leftYAxisTitle: "", points: Self.barPoints, selection: .constant(nil)
            )))
            let plainLine = try #require(render(LineChart(title: "", xAxisLabel: "", leftYAxisTitle: "", points: Self.linePoints)))
            let unselectedLine = try #require(render(LineChart(
                title: "", xAxisLabel: "", leftYAxisTitle: "", points: Self.linePoints, selection: .constant(nil)
            )))

            #expect(plain == unselected)
            #expect(plainLine == unselectedLine)
        }

        @Test func `setting the selection changes the rendering`() throws {
            let plain = try #require(render(VerticalBarChart(title: "", xAxisLabel: "", leftYAxisTitle: "", points: Self.barPoints)))
            let selected = try #require(render(VerticalBarChart(
                title: "", xAxisLabel: "", leftYAxisTitle: "", points: Self.barPoints, selection: .constant("A")
            )))
            let plainLine = try #require(render(LineChart(title: "", xAxisLabel: "", leftYAxisTitle: "", points: Self.linePoints)))
            let selectedLine = try #require(render(LineChart(
                title: "", xAxisLabel: "", leftYAxisTitle: "", points: Self.linePoints, selection: .constant(Self.date.addingTimeInterval(43200))
            )))

            #expect(plain != selected)
            #expect(plainLine != selectedLine)
        }

        private func render(_ chart: some View) -> RenderedBitmap? {
            RenderedBitmap(rendering: chart.frame(width: 320, height: 240).environment(\.locale, Locale(identifier: "en_US")))
        }
    }
#endif
