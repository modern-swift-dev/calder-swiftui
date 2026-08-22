#if canImport(SwiftUI)
import CalderSwiftUI
import CalderUIKit
import SnapshotPreviews
import SwiftUI

/// A generic form field container that displays a name/label and hosts custom content.
///
/// This view provides a consistent layout for form elements, including an optional
/// mandatory indicator.
public struct FormField<Content: View>: View {
    /// The theme
    @Environment(\.theme) private var theme
    /// The name or label of the form field.
    public let name: String
    /// A boolean indicating if the field is mandatory, displaying an asterisk if `true`.
    public let mandatory: Bool
    /// The custom content to be displayed within the form field, typically an input control.
    public let content: @MainActor @Sendable () -> Content

    /// Initializes a new `FormField` view.
    ///
    /// - Parameters:
    ///   - name: The label text for the form field.
    ///   - mandatory: A boolean value indicating if the field is required. Defaults to `false`.
    ///   - content: A `ViewBuilder` that provides the content (e.g., an `InputText`, `Toggle`)
    ///              to be displayed alongside the field name.
    public init(
        name: String,
        mandatory: Bool = false,
        @ViewBuilder content: @escaping @MainActor () -> Content
    ) {
        self.name = name
        self.mandatory = mandatory
        self.content = content
    }

    public var body: some View {
        HStack(alignment: .center, spacing: 0) {
            Text(name)
                .font(.headline)
                .foregroundStyle(theme.text1)

            if mandatory {
                Text(verbatim: "*")
                    .font(.subheadline)
                    .foregroundStyle(theme.error)
                    .offset(.init(width: 0, height: -3))
            }

            Spacer()

            content()
        }
        .padding(.small)
        .frame(minHeight: 52)
        .background(Material.regular)
        .applyThemedCell()
    }
}

#endif

#if DEBUG
@MainActor enum FormFieldPreviews: PreviewProvider, SnapshotProvider {
    static let defaultLayout: PreviewSnapshotLayout = .device

    static var snapshots: [PreviewSnapshot] {
        PreviewSnapshot("Basic Field") { Content(mandatory: false) }
        PreviewSnapshot("Mandatory Field") { Content(mandatory: true) }
    }

    private struct Content: View {
        let mandatory: Bool

        var body: some View {
            NavigationStack {
                List {
                    Section {
                        FormField(name: "Test", mandatory: mandatory) {
                            Text(verbatim: "Value")
                        }
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
