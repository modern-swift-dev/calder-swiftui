#if canImport(SwiftUI)
    import Foundation

    /// Shared value-axis scaling for Calder's bar charts.
    enum ChartAxis {
        /// Rounds a data maximum up to a nice axis maximum proportional to the data.
        ///
        /// The value is rounded up to the next multiple of its own order of magnitude, so `7` stays `7`,
        /// `15` becomes `20`, `330` becomes `400`, and `1200` becomes `2000`.
        /// - Parameter value: The largest value plotted on the axis.
        /// - Returns: The axis maximum, `Int.max` when the rounded value doesn't fit in `Int`,
        ///   or `0` when `value` is not positive.
        static func niceMaximum(for value: Int) -> Int {
            guard value > 0 else {
                return 0
            }
            var magnitude = 1
            while magnitude <= value / 10 {
                magnitude *= 10
            }
            let multiples = value / magnitude + (value % magnitude == 0 ? 0 : 1)
            let (maximum, overflow) = multiples.multipliedReportingOverflow(by: magnitude)
            return overflow ? .max : maximum
        }
    }

#endif
