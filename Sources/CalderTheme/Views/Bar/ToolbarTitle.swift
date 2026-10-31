#if canImport(SwiftUI)
    #if !os(watchOS)
        import CalderSwiftUI
        import Foundation
        import SwiftUI

        /// A custom `ToolbarContent` that displays a styled title in the navigation bar.
        public struct ToolbarTitle: ToolbarContent {

            @Environment(\.theme) var theme
            private let titleText: LocalizableText

            /// The toolbar's title.
            ///
            /// A title created from a `LocalizedStringResource` is resolved for the current locale.
            ///
            /// - Note: Deprecated because it resolves a `LocalizedStringResource` with the process locale, which can
            ///   differ from the locale the view renders in. Use ``titleResource``.
            @available(
                *,
                deprecated,
                message: "Resolves with the process locale, which can differ from the rendered text. Use titleResource: set its locale to the one you need and resolve it with String(localized:)."
            )
            public var title: String {
                titleText.resolved
            }

            /// The title as a localized string resource.
            ///
            /// Set its `locale` to the locale you need and resolve it with `String(localized:)`. A title created
            /// from a `String` resolves to that string unchanged in every locale.
            public var titleResource: LocalizedStringResource {
                titleText.resource
            }

            /// Initializes a `ToolbarTitle` with the specified title string.
            ///
            /// - Parameter title: The string to display unchanged as the toolbar's title.
            public init(title: String) {
                titleText = .verbatim(title)
            }

            /// Initializes a `ToolbarTitle` with a localized title.
            ///
            /// SwiftUI looks up the resource in its bundle and table using the environment's locale.
            ///
            /// - Parameter title: The localized string to display as the toolbar's title.
            public init(title: LocalizedStringResource) {
                titleText = .localized(title)
            }

            public var body: some ToolbarContent {
                ToolbarItem(placement: .principal) {
                    titleText.text
                        .foregroundStyle(theme.text1)
                        .font(.headline)
                }
                .disableSharedBackground()
            }
        }

    #endif
#endif

#if DEBUG && canImport(SwiftUI)
    #if !os(watchOS)
        import SnapshotPreviews
        import SwiftUI

        @MainActor enum ToolbarTitlePreviews: PreviewProvider, SnapshotProvider {
            static let defaultLayout: PreviewSnapshotLayout = .device

            static var snapshots: [PreviewSnapshot] {
                PreviewSnapshot("default") {
                    PreviewContent()
                }
            }

            private struct PreviewContent: View {
                @Environment(\.theme) private var theme

                var body: some View {
                    NavigationStack {
                        VStack {
                            Spacer()
                            Text("Empty!")
                            Spacer()
                        }
                        .frame(maxWidth: .infinity)
                        .background(theme.backgroundGradient)
                        .toolbar {
                            ToolbarTitle(title: "Title!")
                        }
                    }
                }
            }
        }
    #endif
#endif
