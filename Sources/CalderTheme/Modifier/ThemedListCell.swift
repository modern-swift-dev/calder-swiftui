#if canImport(SwiftUI)
import CalderUIKit
import Foundation
import SwiftUI

public struct ThemedListCell: ViewModifier {

    @Environment(\.theme) var theme

    let spacing: CGFloat

    public init(spacing: CGFloat = 1.0) {
        self.spacing = spacing
    }

    public func body(content: Content) -> some View {
        content
            .listRowBackground(theme.transparent)
        #if !os(tvOS) && !os(watchOS)
            .listRowSeparator(.hidden)
        #endif
            .listRowInsets(
                .init(
                    top: spacing,
                    leading: .small,
                    bottom: 0,
                    trailing: .small
                )
            )
    }
}

extension View {

    func applyThemedCell(spacing: CGFloat = 1.0) -> some View {
        modifier(ThemedListCell(spacing: spacing))
    }
}

#endif
