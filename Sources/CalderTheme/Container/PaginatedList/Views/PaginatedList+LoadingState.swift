#if canImport(SwiftUI)
import CalderUIKit
import SwiftUI

public extension PaginatedList {

    /// A view that displays a loading indicator, typically used to show that more data is being fetched
    /// in a paginated list.
    struct LoadingState: View {
        public var body: some View {
            HStack {
                Spacer()
                ProgressView()
                    .progressViewStyle(.circular)
                Spacer()
            }
            .padding(.xs)
        }
    }

}

#endif
