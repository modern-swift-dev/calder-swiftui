#if canImport(SwiftUI)
    import CalderUIKit
    import SwiftUI

    extension PaginatedList {

        /// A list footer row shown after a next-page request fails, offering to request the page again.
        struct RetryState: View {
            /// The message explaining that the next page failed to load.
            static let message = LocalizedStringResource("paginatedList.nextPageFailed", bundle: .module)

            /// The title of the button that requests the failed page again.
            static let retryTitle = LocalizedStringResource("paginatedList.retry", bundle: .module)

            @Environment(\.theme) private var theme

            /// The action that requests the failed page again.
            let retry: @MainActor () -> Void

            var body: some View {
                HStack(spacing: .spacingSmall) {
                    Text(Self.message)
                        .font(.footnote)
                        .foregroundStyle(theme.text2)
                    Spacer()
                    Button(action: retry) {
                        Text(Self.retryTitle)
                    }
                }
                .padding(.xs)
            }
        }

    }

#endif
