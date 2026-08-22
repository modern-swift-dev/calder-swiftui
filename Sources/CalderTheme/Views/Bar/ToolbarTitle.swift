#if canImport(SwiftUI)
#if !os(watchOS)
import CalderSwiftUI
import Foundation
import SwiftUI

/// A custom `ToolbarContent` that displays a styled title in the navigation bar.
public struct ToolbarTitle: ToolbarContent {

    @Environment(\.theme) var theme
    public let title: String

    /// Initializes a `ToolbarTitle` with the specified title string.
    ///
    /// - Parameter title: The string to display as the toolbar's title.
    public init(title: String) {
        self.title = title
    }

    public var body: some ToolbarContent {
        ToolbarItem(placement: .principal) {
            Text(verbatim: title)
                .foregroundStyle(theme.text1)
                .font(.headline)
        }
        .disableSharedbackground(disable: true)
    }
}

#endif
#endif

#if canImport(SwiftUI)
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
