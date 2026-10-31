#if canImport(SwiftUI)
    @testable import CalderTheme
    import Foundation
    import SwiftUI
    import Testing

    @MainActor struct ChartEmptyStateTests {
        private static let english = Locale(identifier: "en_US")
        private static let date = Date(timeIntervalSince1970: 1_746_378_919)

        @Test func `the default empty state message comes from the catalog`() {
            #expect(String(localized: ChartEmptyState.message) == "No data")
        }

        @Test func `charts without data show the default empty state`() {
            let states = [
                VerticalBarChart(title: "", xAxisLabel: "", leftYAxisTitle: "", points: []).displayedState(locale: Self.english),
                HorizontalBarChart(xAxisLabel: "", leftYAxisTitle: "", points: []).displayedState(locale: Self.english),
                LineChart(title: "", xAxisLabel: "", leftYAxisTitle: "", points: []).displayedState(locale: Self.english),
                ParetoChart(title: "", xAxisLabel: "", leftYAxisTitle: "", rightYAxisTitle: "", points: [])
                    .displayedState(locale: Self.english),
                LaneChartView(data: []).displayedState(locale: Self.english)
            ]

            for state in states {
                guard case let .empty(message, _) = state else {
                    Issue.record("Expected .empty, got \(state)")
                    continue
                }
                #expect(message == "No data")
            }
        }

        @Test func `charts without data show a custom empty state`() {
            let custom = GenericState.error("Nothing yet")
            let states = [
                VerticalBarChart(title: "", xAxisLabel: "", leftYAxisTitle: "", points: [], emptyState: custom)
                    .displayedState(locale: Self.english),
                VerticalBarChart(
                    title: LocalizedStringResource(stringLiteral: ""), xAxisLabel: "", leftYAxisTitle: "", points: [], emptyState: custom
                ).displayedState(locale: Self.english),
                HorizontalBarChart(xAxisLabel: "", leftYAxisTitle: "", points: [], emptyState: custom).displayedState(locale: Self.english),
                HorizontalBarChart(
                    xAxisLabel: LocalizedStringResource(stringLiteral: ""), leftYAxisTitle: "", points: [], emptyState: custom
                ).displayedState(locale: Self.english),
                LineChart(title: "", xAxisLabel: "", leftYAxisTitle: "", points: [], emptyState: custom).displayedState(locale: Self.english),
                LineChart(
                    title: LocalizedStringResource(stringLiteral: ""), xAxisLabel: "", leftYAxisTitle: "", points: [], emptyState: custom
                ).displayedState(locale: Self.english),
                ParetoChart(title: "", xAxisLabel: "", leftYAxisTitle: "", rightYAxisTitle: "", points: [], emptyState: custom)
                    .displayedState(locale: Self.english),
                ParetoChart(
                    title: LocalizedStringResource(stringLiteral: ""), xAxisLabel: "", leftYAxisTitle: "", rightYAxisTitle: "",
                    points: [], emptyState: custom
                ).displayedState(locale: Self.english),
                LaneChartView(data: [], emptyState: custom).displayedState(locale: Self.english)
            ]

            for state in states {
                guard case let .error(message, _) = state else {
                    Issue.record("Expected .error, got \(state)")
                    continue
                }
                #expect(message == "Nothing yet")
            }
        }

        @Test func `charts with data display the chart`() {
            let states = [
                VerticalBarChart(title: "", xAxisLabel: "", leftYAxisTitle: "", points: [.init(name: "A", value: 0)])
                    .displayedState(locale: Self.english),
                HorizontalBarChart(xAxisLabel: "", leftYAxisTitle: "", points: [.init(name: "A", value: 1)])
                    .displayedState(locale: Self.english),
                LineChart(title: "", xAxisLabel: "", leftYAxisTitle: "", points: [.init(date: Self.date, value: 1)])
                    .displayedState(locale: Self.english),
                ParetoChart(title: "", xAxisLabel: "", leftYAxisTitle: "", rightYAxisTitle: "", points: [.init(name: "A", value: 0)])
                    .displayedState(locale: Self.english),
                LaneChartView(data: [.init(name: "A", start: Self.date, end: Self.date)], emptyState: .error("Nothing yet"))
                    .displayedState(locale: Self.english)
            ]

            for state in states {
                guard case .displaying = state else {
                    Issue.record("Expected .displaying, got \(state)")
                    continue
                }
            }
        }

        #if os(iOS)
            @Test func `an empty chart renders the localized no data message`() {
                let chart = VerticalBarChart(title: "", xAxisLabel: "", leftYAxisTitle: "", points: [])
                    .environment(\.locale, Self.english)
                let labels = AccessibilityTree.elements(of: chart).compactMap(\.label)

                #expect(labels.contains("No data"))
            }
        #endif
    }
#endif
