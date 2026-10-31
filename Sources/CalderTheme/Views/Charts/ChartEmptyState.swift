#if canImport(SwiftUI)
    import Foundation

    /// The state a chart shows instead of its axes when it has no data points.
    enum ChartEmptyState {
        /// The message of the default empty state.
        static let message = LocalizedStringResource("chart.noData", bundle: .module)

        /// The state a chart displays.
        /// - Parameters:
        ///   - custom: The empty state passed to the chart, or `nil` for the default.
        ///   - isEmpty: Whether the chart has no data points.
        ///   - locale: The locale used to look up the default message.
        /// - Returns: `.displaying` when the chart has data points; otherwise `custom`, or an `.empty`
        ///   state with a localized "No data" message when `custom` is `nil`.
        static func state(_ custom: GenericState?, isEmpty: Bool, locale: Locale) -> GenericState {
            guard isEmpty else {
                return .displaying
            }
            return custom ?? .empty(ChartDescriptor.string(message, locale: locale))
        }
    }

#endif
