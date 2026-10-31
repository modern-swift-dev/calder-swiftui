#if canImport(SwiftUI)
    import CalderSwiftUI
    import SwiftUI

    /// A form field component that provides a toggle switch.
    ///
    /// It integrates a `Toggle` within a `FormField` structure for consistent styling
    /// and behavior within forms.
    public struct FormSwitch: View {

        /// The theme
        @Environment(\.theme) private var theme
        private let nameText: LocalizableText

        /// The name or label for the switch field.
        ///
        /// A name created from a `LocalizedStringResource` is resolved for the current locale.
        ///
        /// - Note: Deprecated because it resolves a `LocalizedStringResource` with the process locale, which can
        ///   differ from the locale the view renders in. Use ``nameResource``.
        @available(
            *,
            deprecated,
            message: "Resolves with the process locale, which can differ from the rendered text. Use nameResource: set its locale to the one you need and resolve it with String(localized:)."
        )
        public var name: String {
            nameText.resolved
        }

        /// The name as a localized string resource.
        ///
        /// Set its `locale` to the locale you need and resolve it with `String(localized:)`. A name created
        /// from a `String` resolves to that string unchanged in every locale.
        public var nameResource: LocalizedStringResource {
            nameText.resource
        }

        /// A binding to the boolean value that the switch controls.
        @Binding public var value: Bool

        /// Initializes a new `FormSwitch` view.
        ///
        /// - Parameters:
        ///   - name: The label text for the switch, displayed unchanged. VoiceOver also reads it as the switch's label.
        ///   - value: A binding to the boolean property that stores the switch's state.
        public init(name: String, value: Binding<Bool>) {
            nameText = .verbatim(name)
            _value = value
        }

        /// Initializes a new `FormSwitch` view with a localized name.
        ///
        /// SwiftUI looks up the name in its bundle and table using the environment's locale.
        ///
        /// - Parameters:
        ///   - name: The localized label for the switch. VoiceOver also reads it as the switch's label.
        ///   - value: A binding to the boolean property that stores the switch's state.
        public init(name: LocalizedStringResource, value: Binding<Bool>) {
            nameText = .localized(name)
            _value = value
        }

        public var body: some View {
            FormField(
                nameText: nameText,
                mandatory: false
            ) {
                // The row name is the switch's hidden label, so VoiceOver announces it.
                Toggle(isOn: $value) {
                    nameText.text
                }
                .tint(theme.primary)
                .labelsHidden()
            }
        }
    }

#endif

#if DEBUG
    import SnapshotPreviews

    @MainActor enum FormSwitchPreviews: PreviewProvider, SnapshotProvider {
        static let defaultLayout: PreviewSnapshotLayout = .device

        static var snapshots: [PreviewSnapshot] {
            PreviewSnapshot("default") {
                NavigationStack {
                    List {
                        Section {
                            FormSwitch(name: "Toggle 1", value: .constant(true))
                            FormSwitch(name: "Toggle 2", value: .constant(false))
                        } header: {
                            FormHeader(title: "Options")
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
