#if canImport(SwiftUI)
    import CalderSwiftUI
    import CalderUIKit
    import SFSafeSymbols
    import SnapshotPreviews
    import SwiftUI

    /// A styled header for sections within forms or lists.
    ///
    /// This view displays a title and can optionally include a mandatory indicator,
    /// providing clear labeling for form sections.
    public struct FormHeader: View {
        /// The theme
        @Environment(\.theme) private var theme
        private let titleText: LocalizableText

        /// The title text for the header.
        ///
        /// A title created from a `LocalizedStringResource` is resolved for the current locale.
        public var title: String {
            titleText.resolved
        }

        /// A boolean indicating if the section represented by the header contains mandatory fields.
        public let mandatory: Bool

        /// Initializes a new `FormHeader` view.
        ///
        /// - Parameters:
        ///   - title: The title text to display unchanged in the header.
        ///   - mandatory: A boolean value indicating if the section is mandatory. Defaults to `false`.
        public init(title: String, mandatory: Bool = false) {
            titleText = .verbatim(title)
            self.mandatory = mandatory
        }

        /// Initializes a new `FormHeader` view with a localized title.
        ///
        /// SwiftUI looks up the title in its bundle and table using the environment's locale.
        ///
        /// - Parameters:
        ///   - title: The localized title to display in the header.
        ///   - mandatory: A boolean value indicating if the section is mandatory. Defaults to `false`.
        public init(title: LocalizedStringResource, mandatory: Bool = false) {
            titleText = .localized(title)
            self.mandatory = mandatory
        }

        public var body: some View {
            HStack(spacing: 0) {
                titleText.text
                    .font(.headline)
                    .foregroundStyle(theme.text1)

                if mandatory {
                    Text(verbatim: "*")
                        .font(.headline)
                        .foregroundStyle(theme.error)
                        .offset(.init(width: 0, height: -3))
                }
            }
            .lineLimit(1)
            .textCase(.none)
        }
    }

#endif

#if DEBUG
    @MainActor enum FormHeaderPreviews: PreviewProvider, SnapshotProvider {
        static let defaultLayout: PreviewSnapshotLayout = .device

        static var snapshots: [PreviewSnapshot] {
            PreviewSnapshot("default") {
                NavigationStack {
                    List {
                        Section {
                            FormFieldResponsive(name: "Test", accessory: Image(systemSymbol: .chevronRight)) { _ in
                                Text(verbatim: "Value1")
                            }
                        } header: {
                            FormHeader(title: "Title", mandatory: true)
                        }
                    }
                    #if !os(watchOS) && !os(tvOS)
                    .listStyle(.inset)
                    #endif
                    #if os(iOS)
                    .navigationBarTitleDisplayMode(.inline)
                    #endif
                }
            }
        }
    }
#endif
