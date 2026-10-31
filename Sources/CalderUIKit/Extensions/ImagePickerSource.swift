#if canImport(Darwin)
    #if !os(macOS) && !os(tvOS) && !os(watchOS) && !os(visionOS)

        /// Where ``UIKit/UIViewController/pickImages(source:limit:)`` gets its images from.
        public enum ImagePickerSource: Sendable, Hashable {

            /// The user's photo library, through `PHPickerViewController`. No photo-library permission is needed.
            case photoLibrary

            /// The camera, through `UIImagePickerController`. The app needs an `NSCameraUsageDescription`.
            case camera
        }
    #endif

#endif
