#if canImport(SwiftUI) && !os(tvOS)
    @testable import CalderTheme
    import Foundation
    import SwiftUI
    import Testing

    @Suite(.serialized)
    @MainActor struct FormDatePickerTests {
        private let earlier = Date(timeIntervalSince1970: 1000)
        private let later = Date(timeIntervalSince1970: 2000)

        @Test func `selectable range spans the minimum and maximum dates`() {
            let picker = FormDatePicker(name: "Date", min: earlier, max: later, value: .constant(earlier))

            #expect(picker.selectableRange == earlier ... later)
        }

        @Test func `selectable range is unbounded without limits`() {
            let picker = FormDatePicker(name: "Date", value: .constant(earlier))

            #expect(picker.selectableRange == Date.distantPast ... Date.distantFuture)
        }

        @Test func `a maximum earlier than the minimum collapses the range to the minimum`() {
            let picker = FormDatePicker(name: "Date", min: later, max: earlier, value: .constant(later))

            #expect(picker.selectableRange == later ... later)
            _ = picker.body
        }
    }
#endif
