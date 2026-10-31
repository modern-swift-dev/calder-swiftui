#if canImport(SwiftUI)
    import Charts
    import SwiftUI

    /// Shared highlighting for charts with a selection binding.
    enum ChartSelection {
        /// The opacity of marks that aren't selected while a category is selected.
        static let unselectedOpacity = 0.3

        /// The opacity of a category's marks.
        /// - Parameters:
        ///   - category: The category of the marks.
        ///   - selected: The selected category, or `nil` when nothing is selected.
        /// - Returns: `1` when nothing is selected or `category` is selected, and ``unselectedOpacity`` otherwise.
        static func opacity(forCategory category: String, selected: String?) -> Double {
            guard let selected, selected != category else {
                return 1
            }
            return unselectedOpacity
        }
    }

    extension View {
        /// Binds the chart's X selection when a binding is given, and leaves the chart unchanged otherwise.
        /// - Parameter selection: The binding that receives the selected X value, or `nil` for no selection.
        /// - Returns: The chart, selectable when `selection` isn't `nil`.
        @ViewBuilder
        func chartXSelection(optional selection: Binding<(some Plottable)?>?) -> some View {
            if let selection {
                chartXSelection(value: selection)
            } else {
                self
            }
        }

        /// Binds the chart's Y selection when a binding is given, and leaves the chart unchanged otherwise.
        /// - Parameter selection: The binding that receives the selected Y value, or `nil` for no selection.
        /// - Returns: The chart, selectable when `selection` isn't `nil`.
        @ViewBuilder
        func chartYSelection(optional selection: Binding<(some Plottable)?>?) -> some View {
            if let selection {
                chartYSelection(value: selection)
            } else {
                self
            }
        }
    }

#endif
