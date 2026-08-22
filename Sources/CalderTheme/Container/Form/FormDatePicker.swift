#if canImport(SwiftUI)
#if !os(tvOS)
import CalderStdLib
import CalderSwiftUI
import Foundation
import SnapshotPreviews
import SwiftUI

/// A form field component that allows users to select a date and/or time.
///
/// This view integrates a `DatePicker` within a `FormField` structure,
/// providing options for different date picker modes, date ranges, and localization settings.
public struct FormDatePicker: View {

    /// Defines the modes for the date picker, specifying what components (date, time, or both) are displayed.
    public enum Mode {
        /// Displays only the date components (day, month, year).
        case date
        /// Displays only the time components (hour, minute).
        case time
        /// Displays both date and time components.
        case dateAndTime

        /// The `DatePicker.Components` corresponding to the chosen mode.
        var components: DatePicker.Components {
            switch self {
                case .date:
                    [.date]
                case .time:
                    [.hourAndMinute]
                case .dateAndTime:
                    [.date, .hourAndMinute]
            }
        }
    }

    /// The theme
    @Environment(\.theme) private var theme
    /// The name or label for the date picker field.
    public let name: String
    /// A boolean indicating if the field is mandatory.
    public let mandatory: Bool
    /// A binding to the `Date` value selected in the date picker.
    @Binding public var value: Date
    /// The mode of the date picker (date, time, or date and time).
    public let mode: Mode
    /// The minimum selectable date. If `nil`, `Date.distantPast` is used.
    public let min: Date?
    /// The maximum selectable date. If `nil`, `Date.distantFuture` is used.
    public let max: Date?
    /// The locale to use for formatting dates and times in the picker. Defaults to `Locale.current`.
    public let locale: Locale
    /// The time zone to use for date calculations in the picker. Defaults to `TimeZone.current`.
    public let timeZone: TimeZone
    /// The calendar to use for date calculations in the picker. Defaults to `Calendar.current`.
    public let calendar: Calendar

    /// Initializes a new `FormDatePicker` view.
    ///
    /// - Parameters:
    ///   - name: The label text for the date picker.
    ///   - mandatory: A boolean indicating if the field is required. Defaults to `false`.
    ///   - mode: The display mode for the date picker (date, time, or dateAndTime). Defaults to `.dateAndTime`.
    ///   - min: The earliest selectable date. Defaults to `nil` (no minimum).
    ///   - max: The latest selectable date. Defaults to `nil` (no maximum).
    ///   - locale: The locale to use for date formatting. Defaults to `Locale.current`.
    ///   - timeZone: The time zone for the date picker. Defaults to `TimeZone.current`.
    ///   - calendar: The calendar for the date picker. Defaults to `Calendar.current`.
    ///   - value: A binding to the `Date` property that stores the selected date.
    public init(
        name: String,
        mandatory: Bool = false,
        mode: Mode = .dateAndTime,
        min: Date? = nil,
        max: Date? = nil,
        locale: Locale = .current,
        timeZone: TimeZone = .current,
        calendar: Calendar = .current,
        value: Binding<Date>
    ) {
        self.name = name
        self.mandatory = mandatory
        self.min = min
        self.max = max
        self.locale = locale
        self.timeZone = timeZone
        self.calendar = calendar
        _value = value
        self.mode = mode
    }

    public var body: some View {
        FormField(
            name: name,
            mandatory: mandatory
        ) {
            DatePicker(
                "",
                selection: $value,
                in: (min ?? Date.distantPast) ... (max ?? Date.distantFuture),
                displayedComponents: mode.components
            )
            #if !os(watchOS)
            .datePickerStyle(.compact)
            #endif
            .labelsHidden()
            .environment(\.locale, locale)
            .environment(\.timeZone, timeZone)
            .environment(\.calendar, calendar)
        }
    }
}

#endif

#endif

#if !os(tvOS)
import CalderStdLib
import Foundation
import SnapshotPreviews
import SwiftUI

#if DEBUG
@MainActor enum FormDatePickerPreviews: PreviewProvider, SnapshotProvider {
    static let defaultLayout: PreviewSnapshotLayout = .device
    private static let calendar = Calendar(identifier: .gregorian)

    static var snapshots: [PreviewSnapshot] {
        PreviewSnapshot("Date & Time") { Content(name: "Date & Time", mode: .dateAndTime) }
        PreviewSnapshot("Time Only") { Content(name: "Time", mode: .time) }
        PreviewSnapshot("Date Only") { Content(name: "Date", mode: .date) }
    }

    private struct Content: View {
        let name: String
        let mode: FormDatePicker.Mode

        var body: some View {
            NavigationStack {
                List {
                    Section {
                        FormDatePicker(
                            name: name,
                            mode: mode,
                            locale: .en,
                            timeZone: TimeZone(secondsFromGMT: 0) ?? .current,
                            calendar: FormDatePickerPreviews.calendar,
                            value: .constant(.distantPast)
                        )
                    }
                }
                #if !os(macOS) && !os(watchOS)
                .listStyle(.grouped)
                #if !os(tvOS)
                    .navigationBarTitleDisplayMode(.inline)
                #endif
                #endif
            }
        }
    }
}
#endif
#endif
