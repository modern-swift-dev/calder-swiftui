#if canImport(SwiftUI)
    import Accessibility
    import Foundation
    import SwiftUI

    /// The Audio Graphs description of a chart, built from values captured when the chart renders.
    ///
    /// Charts pass it to `accessibilityChartDescriptor(_:)`, so VoiceOver can play the chart as an
    /// Audio Graph and read its axes and values.
    struct ChartDescriptor: AXChartDescriptorRepresentable {
        /// Builds the chart's descriptor from the captured values.
        let make: @Sendable () -> AXChartDescriptor

        /// Creates the chart's descriptor.
        /// - Returns: A new descriptor describing the chart's axes and data series.
        func makeChartDescriptor() -> AXChartDescriptor {
            make()
        }

        /// Resolves a chart label for a locale.
        /// - Parameters:
        ///   - text: The label, displayed unchanged or looked up in its string catalog.
        ///   - locale: The locale used to look up a localized label.
        /// - Returns: The label text.
        static func string(_ text: LocalizableText, locale: Locale) -> String {
            switch text {
                case let .verbatim(string):
                    string
                case let .localized(resource):
                    string(resource, locale: locale)
            }
        }

        /// Resolves a localized chart label for a locale.
        /// - Parameters:
        ///   - resource: The label to look up in its string catalog.
        ///   - locale: The locale used to look up the label.
        /// - Returns: The label text.
        static func string(_ resource: LocalizedStringResource, locale: Locale) -> String {
            var resource = resource
            resource.locale = locale
            return String(localized: resource)
        }

        /// The distinct category names in order of first appearance.
        /// - Parameter names: The category name of each data point.
        /// - Returns: Each name once, in the order it first appears.
        static func categories(_ names: [String]) -> [String] {
            var seen = Set<String>()
            return names.filter { seen.insert($0).inserted }
        }

        /// The value range of a numeric axis that starts or ends at zero, as charts plot bars and lines.
        /// - Parameter values: The values plotted on the axis.
        /// - Returns: The range from the smaller of zero and the minimum to the larger of zero and the maximum.
        static func zeroBasedRange(_ values: [Double]) -> ClosedRange<Double> {
            min(0, values.min() ?? 0) ... max(0, values.max() ?? 0)
        }

        /// Formats a numeric axis value as a number for a locale.
        /// - Parameter locale: The locale used to format the value.
        /// - Returns: A closure that describes a value, such as "1,200" in English.
        static func numberDescription(locale: Locale) -> (Double) -> String {
            { value in value.formatted(.number.locale(locale)) }
        }
    }

#endif
