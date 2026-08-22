#if canImport(SwiftUI)
import CalderSwiftUI
import SnapshotPreviews
import SwiftUI

/// A form field component that provides a toggle switch.
///
/// It integrates a `Toggle` within a `FormField` structure for consistent styling
/// and behavior within forms.
public struct FormSwitch: View {

    /// The theme
    @Environment(\.theme) private var theme
    /// The name or label for the switch field.
    public let name: String
    /// A binding to the boolean value that the switch controls.
    @Binding public var value: Bool

    /// Initializes a new `FormSwitch` view.
    ///
    /// - Parameters:
    ///   - name: The label text for the switch.
    ///   - value: A binding to the boolean property that stores the switch's state.
    public init(name: String, value: Binding<Bool>) {
        self.name = name
        _value = value
    }

    public var body: some View {
        FormField(
            name: name,
            mandatory: false
        ) {
            Toggle("", isOn: $value)
                .tint(theme.primary)
                .labelsHidden()
        }
    }
}

#endif

#if DEBUG
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
