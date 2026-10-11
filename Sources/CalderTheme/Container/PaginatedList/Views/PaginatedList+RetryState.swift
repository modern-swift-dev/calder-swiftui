#if canImport(SwiftUI)
    import CalderUIKit
    import SwiftUI

    extension PaginatedList {

        /// A list footer row shown after a next-page request fails, offering to request the page again.
        struct RetryState: View {
            @Environment(\.theme) private var theme

            /// The action that requests the failed page again.
            let retry: @MainActor () -> Void

            var body: some View {
                HStack(spacing: .small) {
                    Text("Couldn't load more results.")
                        .font(.footnote)
                        .foregroundStyle(theme.text2)
                    Spacer()
                    Button("Retry", action: retry)
                }
                .padding(.xs)
            }
        }

    }

#endif
