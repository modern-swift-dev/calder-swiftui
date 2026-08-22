#if canImport(SwiftUI)
import CalderSwiftUI
import CalderUIKit
import SFSafeSymbols
import SnapshotPreviews
import SwiftUI

/// A form field component that adapts its layout based on the horizontal size class.
///
/// In a compact environment (e.g., iPhone portrait), the name and content are stacked vertically.
/// In a regular environment (e.g., iPhone landscape, iPad), they are arranged horizontally.
/// It can also include an optional accessory view, such as a chevron.
public struct FormFieldResponsive<Content: View>: View {
    /// The theme
    @Environment(\.theme) private var theme
    /// The name or label for the form field.
    public let name: String
    /// A boolean indicating if the field is mandatory, displaying an asterisk if `true`.
    public let mandatory: Bool
    /// The custom content to be displayed within the form field. It receives the current
    /// `UserInterfaceSizeClass` for adaptive layout.
    public let content: @MainActor @Sendable (UserInterfaceSizeClass?) -> Content
    /// An optional accessory image (e.g., an SF Symbol) to display at the end of the field.
    public let accessory: Image?

    @Environment(\.horizontalSizeClass) var horizontalSizeClass

    /// Initializes a new `FormFieldResponsive` view.
    ///
    /// - Parameters:
    ///   - name: The label text for the form field.
    ///   - mandatory: A boolean value indicating if the field is required. Defaults to `false`.
    ///   - accessory: An optional `Image` to display as an accessory. Defaults to `nil`.
    ///   - content: A `ViewBuilder` that provides the content (e.g., a `Text` view, an `InputText`)
    ///              to be displayed alongside the field name. The `UserInterfaceSizeClass`
    ///              is passed to the content closure for adaptive layout.
    public init(
        name: String,
        mandatory: Bool = false,
        accessory: Image? = nil,
        @ViewBuilder content: @escaping @MainActor (UserInterfaceSizeClass?) -> Content
    ) {
        self.name = name
        self.mandatory = mandatory
        self.content = content
        self.accessory = accessory
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: .xxs) {
            if horizontalSizeClass == .compact {
                HStack(alignment: .center, spacing: .xxs) {
                    VStack(alignment: .leading, spacing: .xxs) {
                        createFieldName()
                        content(horizontalSizeClass)
                    }

                    Spacer()
                    createAccessory()
                }
            } else {
                HStack(alignment: .center, spacing: .xxs) {
                    createFieldName()
                    Spacer()
                    content(horizontalSizeClass)
                    createAccessory()
                }
            }
        }
        .padding(.small)
        .frame(minHeight: 52)
        .background(Material.regular)
        .applyThemedCell()
    }

    @ViewBuilder private func createAccessory() -> some View {
        if let accessory {
            accessory
                .symbolRenderingMode(.monochrome)
                .renderingMode(.template)
                .flipsForRightToLeftLayoutDirection(true)
                .imageScale(.small)
                .foregroundStyle(theme.text2)
        }
    }

    private func createFieldName() -> some View {
        HStack(alignment: .center, spacing: 0) {
            Text(verbatim: name)
                .font(.headline)
                .foregroundStyle(theme.text1)

            if mandatory {
                Text(verbatim: "*")
                    .font(.headline)
                    .foregroundStyle(theme.error)
                    .offset(.init(width: 0, height: -3))
            }
        }
    }
}

public extension FormFieldResponsive where Content == EmptyView {
    /// Initializes a new `FormFieldResponsive` view with an `EmptyView` as content.
    /// This initializer is useful for creating simple navigation links or fields
    /// where the content is implicitly handled by the navigation action.
    ///
    /// - Parameters:
    ///   - name: The label text for the form field.
    ///   - mandatory: A boolean value indicating if the field is required. Defaults to `false`.
    ///   - accessory: An optional `Image` to display as an accessory. Defaults to a right chevron.
    init(
        name: String,
        mandatory: Bool = false,
        accessory: Image = Image(systemSymbol: .chevronRight)
    ) {
        self.name = name
        self.mandatory = mandatory
        self.content = { _ in EmptyView() }
        self.accessory = accessory
    }
}

#endif

#if DEBUG
@MainActor enum FormFieldResponsivePreviews: PreviewProvider, SnapshotProvider {
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
                        FormFieldResponsive(
                            name: "Test",
                            mandatory: mandatory,
                            accessory: Image(systemSymbol: .chevronRight)
                        ) { _ in
                            Text(verbatim: mandatory ? "Value2" : "Value1")
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
