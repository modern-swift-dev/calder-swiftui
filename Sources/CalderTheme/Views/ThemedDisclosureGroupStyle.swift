#if canImport(SwiftUI)
#if !os(watchOS) && !os(tvOS)
import CalderSwiftUI
import CalderUIKit
import Foundation
import SFSafeSymbols
import SwiftUI

/// A custom `DisclosureGroupStyle` that uses theme fonts and icons,
/// with a rotating chevron indicator for expand/collapse.
///
/// This style applies specific theming to the disclosure group's label and indicator,
/// ensuring consistency with the application's overall design. The chevron rotates 90 degrees
/// when the group is expanded, providing a clear visual cue to the user.
///
/// - Note: This style relies on `Environment(\.theme)` for its styling properties.
public struct ThemedDisclosureGroupStyle: DisclosureGroupStyle {

    @Environment(\.theme) private var theme

    /// Initializes a new instance of `ThemedDisclosureGroupStyle`.
    public init() {}

    /// Creates a view that represents the body of a disclosure group.
    ///
    /// - Parameter configuration: The configuration of the disclosure group,
    ///   providing access to its label, content, and `isExpanded` state.
    /// - Returns: A view that displays the themed disclosure group.
    public func makeBody(configuration: Configuration) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Button(action: {
                configuration.isExpanded.toggle()
            }, label: {
                HStack(alignment: .center, spacing: 0) {
                    configuration.label
                        .multilineTextAlignment(.leading)
                        .foregroundStyle(theme.text1)
                        .font(.title3)

                    Spacer()

                    Image(systemSymbol: .chevronRight)
                        .imageScale(.medium)
                        .rotationEffect(configuration.isExpanded ? .degrees(90) : .zero)
                        .foregroundStyle(theme.text1)
                        .flipsForRightToLeftLayoutDirection(true)
                        .font(.body)
                }
                .padding(EdgeInsets(
                    top: .xs,
                    leading: 0,
                    bottom: .xs,
                    trailing: .small
                ))
                .contentShape(Rectangle())
                .clipShape(Rectangle())
            })
            .buttonStyle(.plain)

            if configuration.isExpanded {
                configuration.content
            }
        }
    }
}

#endif

#endif

#if DEBUG
#if canImport(SwiftUI)
#if !os(watchOS) && !os(tvOS)
import CalderSwiftUI
import CalderUIKit
import SnapshotPreviews
import SwiftUI

@MainActor enum ThemedDisclosureGroupStylePreviews: PreviewProvider, SnapshotProvider {
    static let defaultLayout: PreviewSnapshotLayout = .device

    @SnapshotBuilder static var snapshots: [PreviewSnapshot] {
        PreviewSnapshot("expanded") {
            ThemedDisclosureGroupStylePreviewHost()
        }
    }

    private struct ThemedDisclosureGroupStylePreviewHost: View {
        @Environment(\.theme) private var theme
        @State private var isExpanded = true

        var body: some View {
            List {
                DisclosureGroup("Disclosure Group", isExpanded: $isExpanded) {
                    HStack {
                        Text("This is the content of the disclosure group.")
                            .foregroundStyle(theme.text1)
                            .font(.body)

                        Spacer()
                    }
                    .padding(.xs)
                }
                .disclosureGroupStyle(ThemedDisclosureGroupStyle())
                .applyThemedCell()
            }
            #if !os(macOS)
            .listStyle(.insetGrouped)
            .scrollContentBackground(.hidden)
            .background(theme.backgroundGradient)
            #endif
        }
    }
}
#endif
#endif
#endif
