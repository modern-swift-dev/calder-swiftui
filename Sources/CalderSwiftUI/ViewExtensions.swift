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

            /// Hides the shared glass background that the system draws behind toolbar items.
            ///
            /// The background is hidden only on iOS 26, macOS 26, and later. On earlier versions, and on
            /// tvOS, watchOS, and visionOS, the content is returned unchanged.
            ///
            /// - Parameter disable: Whether to hide the shared background. Defaults to `true`.
            /// - Returns: The toolbar content, with the shared background hidden when `disable` is `true`.
            func disableSharedBackground(_ disable: Bool = true) -> some ToolbarContent {
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

            /// The previous, misspelled name of ``disableSharedBackground(_:)``.
            @available(*, deprecated, renamed: "disableSharedBackground(_:)")
            func disableSharedbackground(disable: Bool) -> some ToolbarContent {
                disableSharedBackground(disable)
            }
        }

    #endif

#endif
