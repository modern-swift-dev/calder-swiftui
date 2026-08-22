#if canImport(Darwin)
#if !os(watchOS)
import CoreImage
import Foundation
import os

#if canImport(UIKit)
import UIKit
#endif

// MARK: HEIF
public extension CIImage {

    /// Converts image `Data` to HEIF format.
    /// - Parameters:
    ///   - data: The input image data.
    /// - Returns: The HEIF image data, or `nil` if conversion fails.
    static func toHeif(data: Data) -> Data? {
        guard let image = CIImage(data: data, options: [.applyOrientationProperty: true]) else {
            return nil
        }
        return toHeif(image: image)
    }

    #if canImport(UIKit)
    /// Converts a `UIImage` to HEIF format.
    /// - Parameters:
    ///   - uiImage: The input `UIImage`.
    ///   - compression: The compression quality (0.0 to 1.0). Defaults to 0.9.
    /// - Returns: The HEIF image data, or `nil` if conversion fails.
    static func toHeif(uiImage: UIImage) -> Data? {
        if let data = uiImage.heicData() {
            return toHeif(data: data)
        }
        return nil
    }
    #endif

    /// Converts a `CIImage` to HEIF format.
    /// - Parameters:
    ///   - image: The input `CIImage`.
    /// - Returns: The HEIF image data, or `nil` if conversion fails.
    static func toHeif(image: CIImage) -> Data? {
        autoreleasepool {
            guard let colorSpace = CGColorSpace(name: CGColorSpace.sRGB) else {
                return nil
            }
            let context = CIContext()
            defer { context.clearCaches() }
            return context.heifRepresentation(of: image, format: .RGBAf, colorSpace: colorSpace, options: [:])
        }
    }

    /// Writes image `Data` to a HEIF file.
    /// - Parameters:
    ///   - data: The input image data.
    /// - Returns: The `URL` of the written HEIF file, or `nil` if writing fails.
    static func writeHeif(data: Data) -> URL? {
        guard let image = CIImage(data: data, options: [.applyOrientationProperty: true]) else {
            return nil
        }

        return writeHeif(image: image)
    }

    #if canImport(UIKit)
    /// Writes a `UIImage` to a HEIF file.
    /// - Parameters:
    ///   - uiImage: The input `UIImage`.
    /// - Returns: The `URL` of the written HEIF file, or `nil` if writing fails.
    static func writeHeif(uiImage: UIImage) -> URL? {
        if let data = toHeif(uiImage: uiImage) {
            return writeHeif(data: data)
        }
        return nil
    }

    /// Writes a `UIImage` with metadata to a HEIF file.
    /// - Parameters:
    ///   - image: The input `UIImage`.
    ///   - metadata: The image metadata as an `NSDictionary`.
    /// - Returns: The `URL` of the written HEIF file, or `nil` if writing fails.
    static func writeHeif(image: UIImage, metadata: NSDictionary) -> URL? {
        guard let image = CIImage(image: image, options: [
            .applyOrientationProperty: true,
            .properties: metadata
        ]) else {
            return nil
        }
        return writeHeif(image: image)
    }
    #endif

    /// Writes a `CIImage` to a HEIF file.
    /// - Parameters:
    ///   - image: The input `CIImage`.
    /// - Returns: The `URL` of the written HEIF file, or `nil` if writing fails.
    static func writeHeif(image: CIImage) -> URL? {
        guard let colorSpace = CGColorSpace(name: CGColorSpace.sRGB) else {
            return nil
        }
        return autoreleasepool {
            do {

                let fileUrl = URL.applicativeCacheDirectory.appendingPathComponent("\(UUID().uuidString).heif")
                let context = CIContext()
                defer { context.clearCaches() }
                try context.writeHEIFRepresentation(of: image, to: fileUrl, format: .RGBAf, colorSpace: colorSpace, options: [:])
                return fileUrl
            } catch {
                os_log("%{public}@", log: .default, type: .error, String(describing: error))
                return nil
            }
        }
    }
}

// MARK: PNGs
public extension CIImage {

    /// Converts image `Data` to PNG format.
    /// - Parameter data: The input image data.
    /// - Returns: The PNG image data, or `nil` if conversion fails.
    static func toPNG(data: Data) -> Data? {
        guard let image = CIImage(data: data, options: [.applyOrientationProperty: true]) else {
            return nil
        }
        return toPNG(image: image)
    }

    #if canImport(UIKit)
    /// Converts a `UIImage` to PNG format.
    /// - Parameter uiImage: The input `UIImage`.
    /// - Returns: The PNG image data, or `nil` if conversion fails.
    static func toPNG(uiImage: UIImage) -> Data? {
        uiImage.pngData()
    }

    /// Converts a `UIImage` with metadata to PNG format.
    /// - Parameters:
    ///   - image: The input `UIImage`.
    ///   - metadata: The image metadata as an `NSDictionary`.
    /// - Returns: The PNG image data, or `nil` if conversion fails.
    static func toPNG(image: UIImage, metadata: NSDictionary) -> Data? {
        guard let image = CIImage(image: image, options: [
            .applyOrientationProperty: true,
            .properties: metadata
        ]) else {
            return nil
        }
        return toPNG(image: image)
    }
    #endif

    /// Converts a `CIImage` to PNG format.
    /// - Parameter image: The input `CIImage`.
    /// - Returns: The PNG image data, or `nil` if conversion fails.
    static func toPNG(image: CIImage) -> Data? {
        autoreleasepool {
            guard let colorSpace = CGColorSpace(name: CGColorSpace.sRGB) else {
                return nil
            }
            let context = CIContext()
            defer { context.clearCaches() }
            return context.pngRepresentation(of: image, format: .RGBAf, colorSpace: colorSpace)
        }
    }

    /// Writes image `Data` to a PNG file.
    /// - Parameters:
    ///   - data: The input image data.
    /// - Throws: An error if writing fails.
    /// - Returns: The `URL` of the written PNG file, or `nil` if the `CIImage` cannot be created.
    static func writePNG(data: Data) throws -> URL? {
        guard let image = CIImage(data: data, options: [.applyOrientationProperty: true]) else {
            return nil
        }

        return try writePNG(image: image)
    }

    #if canImport(UIKit)
    /// Writes a `UIImage` to a PNG file.
    /// - Parameter uiImage: The input `UIImage`.
    /// - Throws: An error if writing fails.
    /// - Returns: The `URL` of the written PNG file.
    static func writePNG(uiImage: UIImage) throws -> URL {
        try autoreleasepool {
            let fileUrl = URL.applicativeCacheDirectory.appendingPathComponent("\(UUID().uuidString).png")
            try uiImage.pngData()?.write(to: fileUrl, options: .atomic)
            return fileUrl
        }
    }

    /// Writes a `UIImage` with metadata to a PNG file.
    /// - Parameters:
    ///   - image: The input `UIImage`.
    ///   - metadata: The image metadata as an `NSDictionary`.
    /// - Throws: An error if writing fails.
    /// - Returns: The `URL` of the written PNG file, or `nil` if the `CIImage` cannot be created.
    static func writePNG(image: UIImage, metadata: NSDictionary) throws -> URL? {
        guard let image = CIImage(image: image, options: [
            .applyOrientationProperty: true,
            .properties: metadata
        ]) else {
            return nil
        }
        return try writePNG(image: image)
    }
    #endif

    /// Writes a `CIImage` to a PNG file.
    /// - Parameters:
    ///   - image: The input `CIImage`.
    /// - Throws: An error if writing fails.
    /// - Returns: The `URL` of the written PNG file, or `nil` if the color space cannot be created.
    static func writePNG(image: CIImage) throws -> URL? {
        guard let colorSpace = CGColorSpace(name: CGColorSpace.sRGB) else {
            return nil
        }

        return try autoreleasepool {
            let fileUrl = URL.applicativeCacheDirectory.appendingPathComponent("\(UUID().uuidString).png")
            let context = CIContext()
            defer { context.clearCaches() }
            try context.writePNGRepresentation(of: image, to: fileUrl, format: .RGBAf, colorSpace: colorSpace)
            return fileUrl
        }
    }
}

// MARK: Jpeg
public extension CIImage {

    /// Converts image `Data` to JPEG format.
    /// - Parameters:
    ///   - data: The input image data.
    ///   - compression: The compression quality (0.0 to 1.0). Defaults to 0.9.
    /// - Returns: The JPEG image data, or `nil` if conversion fails.
    static func toJpeg(data: Data, compression: CGFloat = 0.9) -> Data? {
        guard let image = CIImage(data: data, options: [.applyOrientationProperty: true]) else {
            return nil
        }
        return toJpeg(image: image, compression: compression)
    }

    #if canImport(UIKit)
    /// Converts a `UIImage` to JPEG format.
    /// - Parameters:
    ///   - uiImage: The input `UIImage`.
    ///   - compression: The compression quality (0.0 to 1.0). Defaults to 0.9.
    /// - Returns: The JPEG image data, or `nil` if conversion fails.
    static func toJpeg(uiImage: UIImage, compression: CGFloat = 0.9) -> Data? {
        uiImage.jpegData(compressionQuality: compression)
    }

    /// Converts a `UIImage` with metadata to JPEG format.
    /// - Parameters:
    ///   - image: The input `UIImage`.
    ///   - metadata: The image metadata as an `NSDictionary`.
    ///   - compression: The compression quality (0.0 to 1.0). Defaults to 0.9.
    /// - Returns: The JPEG image data, or `nil` if conversion fails.
    static func toJpeg(image: UIImage, metadata: NSDictionary, compression: CGFloat = 0.9) -> Data? {
        guard let image = CIImage(image: image, options: [
            .applyOrientationProperty: true,
            .properties: metadata
        ]) else {
            return nil
        }
        return toJpeg(image: image, compression: compression)
    }
    #endif

    /// Converts a `CIImage` to JPEG format.
    /// - Parameters:
    ///   - image: The input `CIImage`.
    ///   - compression: The compression quality (0.0 to 1.0). Defaults to 0.9.
    /// - Returns: The JPEG image data, or `nil` if conversion fails.
    static func toJpeg(image: CIImage, compression: CGFloat = 0.9) -> Data? {
        guard let colorSpace = CGColorSpace(name: CGColorSpace.sRGB) else {
            return nil
        }
        return autoreleasepool {
            let context = CIContext()
            defer { context.clearCaches() }
            return context.jpegRepresentation(of: image, colorSpace: colorSpace, options: [
                CIImageRepresentationOption(rawValue: kCGImageDestinationLossyCompressionQuality as String): compression
            ])
        }
    }

    /// Writes image `Data` to a JPEG file.
    /// - Parameters:
    ///   - data: The input image data.
    ///   - compression: The compression quality (0.0 to 1.0). Defaults to 0.9.
    /// - Throws: An error if writing fails.
    /// - Returns: The `URL` of the written JPEG file, or `nil` if the `CIImage` cannot be created.
    static func writeJpeg(data: Data, compression: CGFloat = 0.9) throws -> URL? {
        guard let image = CIImage(data: data, options: [.applyOrientationProperty: true]) else {
            return nil
        }

        return try writeJpeg(image: image, compression: compression)
    }

    #if canImport(UIKit)
    /// Writes a `UIImage` to a JPEG file.
    /// - Parameters:
    ///   - uiImage: The input `UIImage`.
    ///   - compression: The compression quality (0.0 to 1.0). Defaults to 0.9.
    /// - Throws: An error if writing fails.
    /// - Returns: The `URL` of the written JPEG file.
    static func writeJpeg(uiImage: UIImage, compression: CGFloat = 0.9) throws -> URL {
        try autoreleasepool {
            let fileUrl = URL.applicativeCacheDirectory.appendingPathComponent("\(UUID().uuidString).jpg")
            try uiImage.jpegData(compressionQuality: compression)?.write(to: fileUrl, options: .atomic)
            return fileUrl
        }
    }

    /// Writes a `UIImage` with metadata to a JPEG file.
    /// - Parameters:
    ///   - image: The input `UIImage`.
    ///   - metadata: The image metadata as an `NSDictionary`.
    ///   - compression: The compression quality (0.0 to 1.0). Defaults to 0.9.
    /// - Throws: An error if writing fails.
    /// - Returns: The `URL` of the written JPEG file, or `nil` if the `CIImage` cannot be created.
    static func writeJpeg(image: UIImage, metadata: NSDictionary, compression: CGFloat = 0.9) throws -> URL? {
        guard let image = CIImage(image: image, options: [
            .applyOrientationProperty: true,
            .properties: metadata
        ]) else {
            return nil
        }
        return try writeJpeg(image: image, compression: compression)
    }
    #endif

    /// Writes a `CIImage` to a JPEG file.
    /// - Parameters:
    ///   - image: The input `CIImage`.
    ///   - compression: The compression quality (0.0 to 1.0). Defaults to 0.9.
    /// - Throws: An error if writing fails.
    /// - Returns: The `URL` of the written JPEG file, or `nil` if the color space cannot be created.
    static func writeJpeg(image: CIImage, compression: CGFloat = 0.9) throws -> URL? {
        guard let colorSpace = CGColorSpace(name: CGColorSpace.sRGB) else {
            return nil
        }

        return try autoreleasepool {

            let fileUrl = URL.applicativeCacheDirectory.appendingPathComponent("\(UUID().uuidString).jpg")
            let context = CIContext()
            defer { context.clearCaches() }
            try context.writeJPEGRepresentation(of: image, to: fileUrl, colorSpace: colorSpace, options: [
                CIImageRepresentationOption(rawValue: kCGImageDestinationLossyCompressionQuality as String): compression
            ])
            return fileUrl

        }
    }
}
#endif

#endif
