#if canImport(Darwin)
    #if canImport(UIKit) && !os(watchOS)
        import Accelerate
        import CoreGraphics
        import CoreImage
        import Foundation
        import UIKit

        // MARK: - Base64
        public extension UIImage {
            /// Returns the PNG data representation of the image as a Base64 encoded `Data` object.
            /// - Returns: A base64 encoded `Data` representation of this `UIImage`, or `nil` if the PNG data cannot be generated.
            func base64() -> Data? {
                pngData()?.base64EncodedData(options: .lineLength64Characters)
            }

            /// Returns the PNG data representation of the image as a Base64 encoded `String`.
            /// - Returns: A base64 string representation of this `UIImage`, or `nil` if the PNG data cannot be generated.
            func base64String() -> String? {
                pngData()?.base64EncodedString(options: .lineLength64Characters)
            }

            /// Returns a URL representing this picture as a Base64 encoded PNG data URL.
            ///
            /// The Base64 payload contains no line breaks.
            /// - Returns: A `URL` with a `data:` scheme representing this picture as a Base64 encoded PNG, or `nil` if the PNG data cannot be generated.
            func base64URLPng() -> URL? {
                guard let data = pngData() else {
                    return nil
                }
                return URL(string: "data:image/png;base64,\(data.base64EncodedString())")
            }

            /// Returns a URL representing this picture as a Base64 encoded JPEG data URL.
            ///
            /// The image is encoded as JPEG at maximum quality (compression quality `1.0`). The Base64 payload
            /// contains no line breaks.
            /// - Returns: A `URL` with a `data:` scheme representing this picture as a Base64 encoded JPEG, or `nil` if the JPEG data cannot be generated.
            func base64URLJpg() -> URL? {
                guard let data = jpegData(compressionQuality: 1.0) else {
                    return nil
                }
                return URL(string: "data:image/jpeg;base64,\(data.base64EncodedString())")
            }
        }

    #endif

#endif
