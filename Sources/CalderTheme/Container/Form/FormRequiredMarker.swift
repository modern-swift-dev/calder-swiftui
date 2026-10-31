#if canImport(SwiftUI)
    import SwiftUI

    /// The asterisk a form shows next to the name of a required field, which VoiceOver reads as "required".
    struct FormRequiredMarker: View {
        @Environment(\.theme) private var theme

        /// The font of the asterisk.
        let font: Font

        var body: some View {
            Text(verbatim: "*")
                .font(font)
                .foregroundStyle(theme.error)
                .offset(.init(width: 0, height: -3))
                .accessibilityLabel(Text(LocalizedStringResource("form.required", bundle: .module)))
        }
    }

#endif
