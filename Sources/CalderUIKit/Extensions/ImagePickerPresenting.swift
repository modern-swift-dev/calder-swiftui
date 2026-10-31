#if canImport(Darwin)
    #if !os(macOS) && !os(tvOS) && !os(watchOS) && !os(visionOS)
        import UIKit

        /// Presents a picker and reports its images. A seam so tests can run `pickImages` without UI.
        @MainActor
        protocol ImagePickerPresenting {

            /// Whether the device can provide images from `source`.
            func isAvailable(_ source: ImagePickerSource) -> Bool

            /// Presents the picker for `source` over `viewController` and returns the picked images in order.
            /// Returns an empty array when the user cancels.
            func presentPicker(source: ImagePickerSource, limit: Int, from viewController: UIViewController) async throws -> [UIImage]
        }
    #endif

#endif
