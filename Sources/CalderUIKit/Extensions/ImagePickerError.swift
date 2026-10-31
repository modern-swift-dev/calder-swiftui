#if canImport(Darwin)
    #if !os(macOS) && !os(tvOS) && !os(watchOS) && !os(visionOS)

        /// The reasons ``UIKit/UIViewController/pickImages(source:limit:)`` can't present a picker.
        public enum ImagePickerError: Error, Sendable, Equatable {

            /// The requested source isn't available on this device, such as the camera on a simulator.
            case sourceUnavailable(ImagePickerSource)

            /// The view controller is already presenting another view controller, so the picker can't be shown.
            case alreadyPresenting
        }
    #endif

#endif
