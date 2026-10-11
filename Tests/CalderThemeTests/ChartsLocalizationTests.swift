#if canImport(SwiftUI)
    @testable import CalderTheme
    import Foundation
    import SwiftUI
    import Testing

    @Suite(.serialized)
    @MainActor struct ChartsLocalizationTests {
        private static let english = Locale(identifier: "en_US")
        private static let french = Locale(identifier: "fr_FR")
        /// A catalog entry whose English value differs from its key, so a lookup is observable.
        private static let warning = LocalizedStringResource("messageBox.severity.warning", bundle: .module)

        @Test func `percent bar formats its counts for the locale`() {
            #expect(String(localized: PercentBar(value: 1200, total: 5000).progressText(locale: Self.english)) == "1,200 / 5,000")
            #expect(String(localized: PercentBar(value: 1200, total: 5000).progressText(locale: Self.french)) == "1\u{202F}200 / 5\u{202F}000")
        }

        @Test func `percent bar appends its unit through the catalog`() {
            let verbatim = PercentBar(value: 3, total: 1200, text: "messageBox.severity.warning")
            let localized = PercentBar(value: 3, total: 1200, text: Self.warning)

            #expect(String(localized: verbatim.progressText(locale: Self.english)) == "3 / 1,200 messageBox.severity.warning")
            #expect(String(localized: localized.progressText(locale: Self.english)) == "3 / 1,200 Warning")
            #expect(verbatim.text == "messageBox.severity.warning")
            #expect(localized.text == "Warning")
        }

        #if os(iOS)
            @Test func `percent bar renders its localized progress text`() {
                let bar = PercentBar(value: 1200, total: 5000, text: Self.warning).environment(\.locale, Self.english)
                let texts = AccessibilityTree.elements(of: bar).flatMap { [$0.label, $0.value] }.compactMap(\.self)

                #expect(texts.contains { $0.contains("1,200 / 5,000 Warning") })
            }
        #endif

        @Test func `percentage circle displays its percentage for the locale`() {
            #expect(PercentageCircle(percent: 0.25).displayText(locale: Self.french) == "25\u{00A0}%")
            #expect(PercentageCircle(percent: 0).displayText(locale: Self.french) == "-")
        }

        @Test func `pareto percentage axis is formatted for the locale`() {
            let chart = ParetoChart(
                title: "", xAxisLabel: "", leftYAxisTitle: "", rightYAxisTitle: "",
                points: [.init(name: "A", value: 10)]
            )

            #expect(chart.percentValue(for: 5, locale: Self.english) == "50%")
            #expect(chart.percentValue(for: 5, locale: Self.french) == "50\u{00A0}%")
        }

        @Test func `lane chart labels resolve from the package catalog`() {
            #expect(String(localized: LaneChartView.startLabel) == "Start")
            #expect(String(localized: LaneChartView.endLabel) == "End")
            #expect(String(localized: LaneChartView.taskLabel) == "Task")
            #expect(String(localized: LaneChartView.categoryLabel) == "Category")
        }

        @Test func `charts offer localized labels`() {
            let line = LineChart(title: Self.warning, xAxisLabel: Self.warning, leftYAxisTitle: Self.warning, points: [])
            let vertical = VerticalBarChart(title: Self.warning, xAxisLabel: Self.warning, leftYAxisTitle: Self.warning, points: [])
            let horizontal = HorizontalBarChart(xAxisLabel: Self.warning, leftYAxisTitle: Self.warning, points: [])
            let pareto = ParetoChart(
                title: Self.warning, xAxisLabel: Self.warning, leftYAxisTitle: Self.warning, rightYAxisTitle: Self.warning, points: []
            )

            #expect([line.title, line.xAxisLabel, line.yAxisTitle] == ["Warning", "Warning", "Warning"])
            #expect([vertical.title, vertical.xAxisLabel, vertical.yAxisTitle] == ["Warning", "Warning", "Warning"])
            #expect([horizontal.xAxisLabel, horizontal.yAxisTitle] == ["Warning", "Warning"])
            #expect([pareto.title, pareto.xAxisLabel, pareto.leftYAxisTitle, pareto.rightYAxisTitle] == ["Warning", "Warning", "Warning", "Warning"])
        }

        @Test func `assigning a string chart label keeps it verbatim`() {
            var chart = LineChart(title: Self.warning, xAxisLabel: Self.warning, leftYAxisTitle: Self.warning, points: [])
            chart.title = "messageBox.severity.error"

            #expect(chart.title == "messageBox.severity.error")
        }
    }
#endif
