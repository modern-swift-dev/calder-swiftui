import CalderStdLib
import Foundation
import Testing

struct DateManipTests {
    private let calendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0) ?? .current
        return calendar
    }()

    @Test func `adds days`() throws {
        let date = try #require(calendar.date(from: DateComponents(year: 2023, month: 1, day: 1, hour: 12)))
        let result = date.plusDay(2, calendar: calendar)

        #expect(calendar.dateComponents([.year, .month, .day, .hour], from: result).day == 3)
    }

    @Test func `adds hours`() throws {
        let date = try #require(calendar.date(from: DateComponents(year: 2023, month: 1, day: 1, hour: 12)))
        let result = date.plusHour(2, calendar: calendar)

        #expect(calendar.dateComponents([.year, .month, .day, .hour], from: result).hour == 14)
    }
}
