#if canImport(SwiftUI)
    import SwiftUI

    extension View {
        /// Exposes toggle semantics for a custom toggle style built from a button, so assistive
        /// technologies announce a toggle with its on or off value instead of a plain button.
        /// - Parameter isOn: Whether the toggle is currently on.
        /// - Returns: A view with the toggle trait, selected when `isOn` is `true`.
        func toggleAccessibility(isOn: Bool) -> some View {
            accessibilityAddTraits(isOn ? [.isToggle, .isSelected] : .isToggle)
        }
    }

#endif
