#if canImport(SwiftUI)
import Foundation
#if canImport(SwiftUI)
import SwiftUI

public extension View {

    /// Erase any view to it's any view counterpart
    func eraseToAnyView() -> AnyView {
        AnyView(self)
    }

    func modify(@ViewBuilder _ modifier: (Self) -> some View) -> some View {
        modifier(self)
    }
}

public extension ToolbarContent {

    func modify(@ToolbarContentBuilder _ modifier: (Self) -> some ToolbarContent) -> some ToolbarContent {
        modifier(self)
    }

    func disableSharedbackground(disable: Bool) -> some ToolbarContent {
        #if !os(tvOS) && !os(watchOS) && !os(visionOS)
        modify {
            if disable, #available(iOS 26, macOS 26, *) {
                $0.sharedBackgroundVisibility(.hidden)
            } else {
                $0
            }
        }
        #else
        self
        #endif
    }
}

#endif

#endif
