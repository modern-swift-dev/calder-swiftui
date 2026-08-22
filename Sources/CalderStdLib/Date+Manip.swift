import Foundation

public extension Date {
    /// Adds or subtracts days from the date.
    /// - Parameters:
    ///   - value: The number of days to add. Pass a negative value to subtract days.
    ///   - calendar: The calendar used for the calculation.
    /// - Returns: The adjusted date, or this date when the calculation fails.
    func plusDay(_ value: Int = 1, calendar: Calendar = .current) -> Date {
        calendar.date(byAdding: .day, value: value, to: self) ?? self
    }

    /// Adds or subtracts hours from the date.
    /// - Parameters:
    ///   - value: The number of hours to add. Pass a negative value to subtract hours.
    ///   - calendar: The calendar used for the calculation.
    /// - Returns: The adjusted date, or this date when the calculation fails.
    func plusHour(_ value: Int = 1, calendar: Calendar = .current) -> Date {
        calendar.date(byAdding: .hour, value: value, to: self) ?? self
    }
}
