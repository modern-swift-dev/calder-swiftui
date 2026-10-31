#if canImport(Darwin)
    #if !os(macOS) && !os(tvOS) && !os(watchOS) && !os(visionOS)
        import Foundation
        import UIKit

        @MainActor
        public extension UIViewController {

            /// Presents an image picker and returns the images the user picks.
            ///
            /// The photo library uses `PHPickerViewController`, limited to images, so the app needs no
            /// photo-library permission. The camera uses `UIImagePickerController` and returns one photo; the app
            /// needs an `NSCameraUsageDescription`. The caller doesn't implement any delegate.
            ///
            /// The call suspends until the user finishes or cancels. Cancelling the surrounding task doesn't
            /// dismiss the picker.
            /// - Parameters:
            ///   - source: Where to get images from.
            ///   - limit: The most images to return. Defaults to `1`; zero or less means no limit. The camera always
            ///     returns at most one image.
            /// - Returns: The picked images in selection order, or an empty array when the user cancels.
            /// - Throws: ``ImagePickerError/sourceUnavailable(_:)`` when `source` isn't available on this device,
            ///   ``ImagePickerError/alreadyPresenting`` when this view controller is already presenting another one, or
            ///   the error from loading a picked image.
            func pickImages(source: ImagePickerSource, limit: Int = 1) async throws -> [UIImage] {
                try await pickImages(source: source, limit: limit, using: SystemImagePickerPresenter())
            }
        }

        @MainActor
        extension UIViewController {

            func pickImages(source: ImagePickerSource, limit: Int, using presenter: some ImagePickerPresenting) async throws -> [UIImage] {
                guard presenter.isAvailable(source) else {
                    throw ImagePickerError.sourceUnavailable(source)
                }
                guard presentedViewController == nil else {
                    throw ImagePickerError.alreadyPresenting
                }
                let limit = max(limit, 0)
                let images = try await presenter.presentPicker(source: source, limit: limit, from: self)
                return limit > 0 ? Array(images.prefix(limit)) : images
            }
        }
    #endif

#endif
