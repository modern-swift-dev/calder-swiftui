#if canImport(SwiftUI)
import CalderStdLib
import CalderSwiftUI
import CalderUIKit
import Foundation
import SFSafeSymbols
import SnapshotPreviews
import SwiftUI

/// A customizable header view that adapts its appearance based on the `Mode` and
/// is typically used within `List` or `ScrollView` containers.
///
/// This view provides a consistent way to display titles, subtitles, and other
/// content at the top of a screen or section, adhering to the app's theme.
public struct Header<Content: View>: View {

    /// Defines the visual and layout mode for the `Header`.
    public enum Mode {
        /// A plain header, typically used in `ScrollView` or plain `List` styles.
        case plain
        /// An inset header, commonly used with `InsetGroupedListStyle`.
        case inset
        /// A grouped header, typically used with `GroupedListStyle`.
        case grouped
        /// An inset grouped header, commonly used with `InsetGroupedListStyle`.
        case insetGrouped

        /// The `EdgeInsets` to apply to the list row containing the header,
        /// ensuring proper spacing for different list styles.
        var rowInsets: EdgeInsets {
            switch self {
                case .grouped:
                    .init(top: -30, leading: 0, bottom: 0, trailing: 0)
                default:
                    .init(all: .zero)
            }
        }
    }

    @Environment(\.theme) var theme

    /// The mode of the header, determining its visual style and layout behavior.
    public let mode: Mode
    /// The content to be displayed within the header.
    public let content: () -> Content

    /// Initializes a new `Header` view.
    ///
    /// - Parameters:
    ///   - mode: The `Mode` of the header, which dictates its styling and layout.
    ///           Defaults to `.plain`.
    ///   - content: A `ViewBuilder` that provides the content to be displayed
    ///              inside the header.
    public init(mode: Mode = .plain, @ViewBuilder content: @escaping () -> Content) {
        self.mode = mode
        self.content = content
    }

    public var body: some View {
        content()
            .padding(.medium)
            .listRowInsets(mode.rowInsets)
        #if !os(watchOS) && !os(tvOS)
            .listRowSeparator(.hidden)
            .listSectionSeparator(.hidden)
        #endif
        #if !os(macOS) && !os(watchOS) && !os(tvOS)
        .listRowSpacing(0)
        .listSectionSpacing(.zero)
        #endif
    }
}

#endif

#if DEBUG
@MainActor enum HeaderPreviews: PreviewProvider, SnapshotProvider {
    static let defaultLayout: PreviewSnapshotLayout = .device

    static var snapshots: [PreviewSnapshot] {
        PreviewSnapshot("scroll-view") { Content(mode: .plain, container: .scroll) }
        PreviewSnapshot("list-plain") { Content(mode: .plain, container: .plain) }
        #if !os(watchOS)
        PreviewSnapshot("list-inset") { Content(mode: .inset, container: .inset) }
        #endif
        #if !os(macOS) && !os(watchOS)
        PreviewSnapshot("list-grouped") { Content(mode: .grouped, container: .grouped) }
        PreviewSnapshot("list-inset-grouped") { Content(mode: .insetGrouped, container: .insetGrouped) }
        #endif
        #if !os(watchOS)
        PreviewSnapshot("list-sidebar") { Content(mode: .insetGrouped, container: .sidebar) }
        #endif
    }

    private enum Container { case scroll, plain, inset, grouped, insetGrouped, sidebar }

    private struct Content: View {
        @Environment(\.theme) private var theme
        let mode: Header<EmptyView>.Mode
        let container: Container

        var body: some View {
            switch container {
                case .scroll: scrollView
                case .plain: plainList
                case .inset: insetList
                case .grouped: groupedList
                case .insetGrouped: insetGroupedList
                case .sidebar: sidebarList
            }
        }

        private var headerContent: some View {
            VStack(alignment: .leading, spacing: .xxs) {
                Text(verbatim: "👋 Hello John!").font(.title).foregroundStyle(theme.text1)
                Text(verbatim: "👋 Hello John!").font(.title2).foregroundStyle(theme.text2)
                Text(verbatim: "👋 Hello John!").font(.title3).foregroundStyle(theme.text3)
            }
        }

        private var rows: some View {
            Section {
                ListRow<_, Never, Never>(content: { ListRowBody(title: "Title", subtitle: "Subtitle", caption: "Caption") }, symbol: .chevronRight)
                ListRow<_, Never, Never>(content: { ListRowBody(title: "Title", subtitle: "Subtitle", caption: "Caption") }, symbol: .chevronRight)
                ListRow<_, Never, Never>(content: { ListRowBody(title: "Title", subtitle: "Subtitle", caption: "Caption") }, symbol: .chevronRight)
            }
        }

        private var scrollView: some View {
            NavigationStack {
                ScrollView {
                    VStack {
                        Header(mode: .plain) { headerContent.frame(maxWidth: .infinity) }
                            .scrollClipDisabled(true)
                            .edgesIgnoringSafeArea(.all)
                        rows
                    }
                    .frame(maxWidth: .infinity)
                }
                .background(theme.backgroundGradient)
                #if !os(macOS) && !os(watchOS)
                #if !os(tvOS) && !os(macOS)
                    .navigationBarTitleDisplayMode(.inline)
                #endif
                    .toolbar { toolbar }
                #endif
            }
        }

        private var plainList: some View {
            NavigationStack {
                List {
                    Header(mode: .plain) { headerContent }.applyThemedCell()
                    rows
                }
                .listStyle(.plain)
                #if !os(tvOS)
                    .scrollContentBackground(.hidden)
                #endif
                    .background(theme.backgroundGradient)
                #if !os(macOS) && !os(watchOS)
                #if !os(tvOS)
                    .navigationBarTitleDisplayMode(.inline)
                #endif
                    .toolbar { toolbar }
                #endif
            }
        }

        private var insetList: some View {
            NavigationStack {
                List {
                    Header(mode: .inset) { headerContent }.applyThemedCell()
                    rows
                }
                #if !os(tvOS) && !os(watchOS)
                .listStyle(.inset)
                .scrollContentBackground(.hidden)
                .background(theme.backgroundGradient)
                #endif
                #if !os(macOS) && !os(watchOS) && !os(tvOS)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar { toolbar }
                #endif
            }
        }

        private var groupedList: some View {
            NavigationStack {
                List {
                    Header(mode: .grouped) {
                        VStack(alignment: .leading, spacing: .xs) {
                            Text(verbatim: "👋 Hello John!").font(.title).foregroundStyle(theme.text1)
                            Text(verbatim: "👋 Hello John!").font(.title2).foregroundStyle(theme.text1)
                            Text(verbatim: "👋 Hello John!").font(.title3).foregroundStyle(theme.text3)
                            Tiles { hclass in
                                Tile(icon: Image(systemSymbol: .checkmarkCircle), label: "To-Do", text: "12", variant: .info, expand: hclass == .regular, action: {})
                            } secondaryTiles: { _ in
                                [
                                    Tile(icon: Image(systemSymbol: .xmarkOctagon), label: "Overdue", text: "12", variant: .error, action: {}),
                                    Tile(icon: Image(systemSymbol: .xmarkOctagon), label: "Loading", text: "12", variant: .loading, action: {}),
                                    Tile(icon: Image(systemSymbol: .xmarkOctagon), label: "Loading", text: "12", variant: .loading, action: {})
                                ]
                            }
                            MessageBox(variant: .info, icon: Image(systemSymbol: .exclamationmarkCircle), title: "This is important", message: .lorem(250))
                        }
                    }
                    .applyThemedCell()
                    .scrollClipDisabled()
                    rows
                }
                #if !os(macOS) && !os(watchOS)
                .listStyle(.grouped)
                #endif
                #if !os(tvOS) && !os(macOS)
                .scrollContentBackground(.hidden)
                #endif
                .background(theme.backgroundGradient)
                #if !os(tvOS) && !os(macOS) && !os(watchOS)
                    .navigationBarTitleDisplayMode(.inline)
                #endif
                #if !os(watchOS)
                .toolbar { toolbar }
                #endif
            }
        }

        private var insetGroupedList: some View {
            NavigationStack {
                List {
                    Header(mode: .insetGrouped) { headerContent }.applyThemedCell()
                    rows
                }
                #if !os(tvOS) && !os(macOS) && !os(watchOS)
                .listStyle(.insetGrouped)
                .scrollContentBackground(.hidden)
                .background(theme.backgroundGradient)
                .navigationBarTitleDisplayMode(.inline)
                #endif
                #if !os(watchOS)
                .toolbar { toolbar }
                #endif
            }
        }

        private var sidebarList: some View {
            NavigationStack {
                List {
                    Header(mode: .insetGrouped) { headerContent }.applyThemedCell()
                    rows
                }
                #if !os(tvOS) && !os(macOS) && !os(watchOS)
                .listStyle(.sidebar)
                .scrollContentBackground(.hidden)
                .background(theme.backgroundGradient)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar { toolbar }
                #endif
            }
        }

        #if !os(watchOS)
        @ToolbarContentBuilder private var toolbar: some ToolbarContent {
            ToolbarTitle(title: "Title")
            #if !os(macOS)
            ToolbarButton(placement: .navigationBarLeading, text: "Close", action: {})
            ToolbarButton(placement: .navigationBarTrailing, text: "Save", action: {})
            #endif
        }
        #endif
    }
}
#endif
