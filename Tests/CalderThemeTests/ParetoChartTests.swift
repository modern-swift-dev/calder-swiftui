#if canImport(SwiftUI)
    @testable import CalderTheme
    import Testing

    @MainActor struct ParetoChartTests {
        @Test func `points are sorted by descending value before plotting`() {
            let points: [ParetoChart.RawDataPoint] = [
                .init(name: "Small", value: 20),
                .init(name: "Large", value: 100),
                .init(name: "Medium", value: 80)
            ]

            let computed = points.computedPoints

            #expect(computed.map(\.name) == ["Large", "Medium", "Small"])
            #expect(computed.map(\.value) == [100, 80, 20])
            // Cumulative share scaled to the 100 axis maximum: 50%, 90%, 100%.
            #expect(computed.map(\.cumulated) == [50, 90, 100])
        }

        @Test func `negative values are clamped to zero`() {
            let point = ParetoChart.RawDataPoint(name: "Refund", value: -20)

            #expect(point.value == 0)
        }

        @Test func `negative values do not push the cumulative share past the axis maximum`() {
            let points: [ParetoChart.RawDataPoint] = [
                .init(name: "A", value: 100),
                .init(name: "B", value: -10),
                .init(name: "C", value: 100)
            ]

            let computed = points.computedPoints

            // Scaled to the 100 axis maximum: 50%, 100%, then the clamped point adds nothing.
            #expect(computed.map(\.name) == ["A", "C", "B"])
            #expect(computed.map(\.cumulated) == [50, 100, 100])
        }

        @Test func `only negative values produce a zero total without division by zero`() {
            let computed = [ParetoChart.RawDataPoint(name: "A", value: -5)].computedPoints

            #expect(computed.map(\.cumulated) == [0])
        }

        @Test func `duplicate names keep distinct identities`() {
            let points: [ParetoChart.RawDataPoint] = [
                .init(name: "Other", value: 20),
                .init(name: "Other", value: 10)
            ]

            let ids = points.computedPoints.map(\.id)

            #expect(Set(ids).count == 2)
        }
    }
#endif
