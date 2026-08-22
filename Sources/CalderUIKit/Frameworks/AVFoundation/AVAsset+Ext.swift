#if canImport(Darwin)
import AVFoundation
import CalderStdLib
import Combine
import Foundation

#if os(iOS) || targetEnvironment(macCatalyst) || os(tvOS) || os(visionOS)
import UIKit
#endif

#if canImport(AppKit) && !targetEnvironment(macCatalyst)
import AppKit
#endif

public extension AVAsset {

    /// Error type for generating thumbnail out of a video
    enum ThumbnailError: Swift.Error {
        case underlying(any Error)
        case failed
    }

    #if os(iOS) || targetEnvironment(macCatalyst) || os(tvOS) || os(visionOS)
    /// Generate a thumbnail out of a video
    /// - parameter url: The URL of the video
    /// - parameter time: The time for the shot. Usually 0
    /// - returns: A future UIImage
    static func thumbnail(url: URL, at time: CMTime = .zero) async throws -> UIImage {

        try await withCheckedThrowingContinuation { continuation in
            let asset = AVURLAsset(url: url)
            let generator = AVAssetImageGenerator(asset: asset)
            generator.appliesPreferredTrackTransform = true
            generator.generateCGImagesAsynchronously(forTimes: [NSValue(time: time)]) { _, image, _, _, error in

                if let error {
                    continuation.resume(throwing: ThumbnailError.underlying(error))
                    return
                }

                if let image {
                    return continuation.resume(returning: UIImage(cgImage: image))
                }

                continuation.resume(throwing: ThumbnailError.failed)
            }
        }
    }

    /// Generate a thumbnail out of a video
    /// - parameter url: The URL of the video
    /// - parameter time: The time for the shot. Usually 0
    /// - returns: A future with PNG Data
    static func thumbnailData(url: URL, at time: CMTime = .zero) async throws -> Data? {
        try await thumbnail(url: url, at: time).pngData()
    }

    #endif

    #if canImport(AppKit) && !targetEnvironment(macCatalyst)

    /// Generate a thumbnail out of a video
    /// - parameter url: The URL of the video
    /// - parameter time: The time for the shot. Usually 0
    /// - returns: A future with an NSImage
    static func thumbnail(url: URL, at time: CMTime = .zero) async throws -> NSImage {

        try await withCheckedThrowingContinuation { continuation in

            let asset = AVURLAsset(url: url)
            let generator = AVAssetImageGenerator(asset: asset)
            generator.appliesPreferredTrackTransform = true
            generator.generateCGImagesAsynchronously(forTimes: [NSValue(time: time)]) { _, image, _, _, error in

                if let error {
                    continuation.resume(throwing: ThumbnailError.underlying(error))
                    return
                }

                if let image {
                    let data = NSImage(cgImage: image, size: NSSize(image.width.cgf, image.height.cgf))
                    return continuation.resume(returning: data)
                }

                continuation.resume(throwing: ThumbnailError.failed)
            }
        }
    }

    /// Generate a thumbnail out of a video
    /// - parameter url: The URL of the video
    /// - parameter time: The time for the shot. Usually 0
    /// - returns: A future with an TIFF Data representation
    static func thumbnailData(url: URL, at time: CMTime = .zero) async throws -> Data? {
        try await thumbnail(url: url, at: time).tiffRepresentation
    }
    #endif

}

#endif
