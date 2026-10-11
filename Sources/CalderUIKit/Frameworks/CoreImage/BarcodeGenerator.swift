#if canImport(Darwin)
    #if canImport(CoreImage)
        import CoreImage
        import Foundation
        import SwiftUI

        #if canImport(UIKit)
            import UIKit
        #endif

        #if canImport(AppKit)
            import AppKit
        #endif

        /// A barcode symbology that Core Image can generate.
        public enum BarcodeGenerator: Sendable {
            case qr
            case code128
            case pdf417

            var filterName: String {
                switch self {
                    case .qr:
                        "CIQRCodeGenerator"
                    case .code128:
                        "CICode128BarcodeGenerator"
                    case .pdf417:
                        "CIPDF417BarcodeGenerator"
                }
            }

            var scale: CGFloat {
                switch self {
                    case .code128:
                        2.0
                    case .qr:
                        5.0
                    case .pdf417:
                        2.0
                }
            }

            var encoding: String.Encoding {
                switch self {
                    case .qr:
                        .utf8
                    case .code128,
                         .pdf417:
                        .ascii
                }
            }

            /// Creates a Core Image barcode for a payload.
            ///
            /// QR codes encode the payload as UTF-8. Code 128 and PDF417 barcodes encode it as ASCII.
            /// The barcode is scaled by a whole-number factor with nearest-neighbour sampling so bars stay sharp.
            /// - Parameters:
            ///   - barcode: The payload to encode.
            ///   - quietSpace: The margin around the barcode, for symbologies that support one.
            /// - Returns: The barcode image, or `nil` when the payload cannot be encoded.
            public func createCIImage(_ barcode: String, quietSpace: CGFloat? = nil) -> CIImage? {
                guard let filter = CIFilter(name: filterName), let data = barcode.data(using: encoding) else {
                    return nil
                }

                filter.setDefaults()

                if filter.responds(to: NSSelectorFromString("inputQuietSpace")),
                   let quietSpace {
                    filter.setValue(quietSpace, forKey: "inputQuietSpace")
                }
                filter.setValue(data, forKey: "inputMessage")

                guard let ciImage = filter.outputImage else {
                    return nil
                }

                if scale != 1 {
                    let transform = CGAffineTransform(scaleX: scale, y: scale)
                    return ciImage.samplingNearest().transformed(by: transform)
                }
                return ciImage
            }

            #if canImport(UIKit)
                public func createUIImage(barcode: String, quietSpace: CGFloat? = nil) -> UIImage? {
                    guard let ciImage = createCIImage(barcode, quietSpace: quietSpace) else {
                        return nil
                    }
                    return UIImage(ciImage: ciImage)
                }

                /// Creates a SwiftUI barcode image for a payload.
                ///
                /// The image uses nearest-neighbour interpolation so bars stay sharp when displayed at 2x or 3x.
                /// - Parameters:
                ///   - barcode: The payload to encode.
                ///   - quietSpace: The margin around the barcode, for symbologies that support one.
                /// - Returns: The barcode image, or `nil` when the payload cannot be encoded.
                public func createImage(barcode: String, quietSpace: CGFloat? = nil) -> Image? {
                    guard let ciImage = createCIImage(barcode, quietSpace: quietSpace), let data = CIImage.toPNG(image: ciImage), let uiImage = UIImage(data: data) else {
                        return nil
                    }
                    return Image(uiImage: uiImage).interpolation(.none)
                }
            #endif

            #if canImport(AppKit) && !targetEnvironment(macCatalyst)

                /// Creates a SwiftUI barcode image for a payload.
                ///
                /// The image uses nearest-neighbour interpolation so bars stay sharp when displayed at 2x or 3x.
                /// - Parameters:
                ///   - barcode: The payload to encode.
                ///   - quietSpace: The margin around the barcode, for symbologies that support one.
                /// - Returns: The barcode image, or `nil` when the payload cannot be encoded.
                public func createImage(barcode: String, quietSpace: CGFloat? = nil) -> Image? {
                    guard let ciImage = createCIImage(barcode, quietSpace: quietSpace), let data = CIImage.toPNG(image: ciImage), let uiImage = NSImage(data: data) else {
                        return nil
                    }
                    return Image(nsImage: uiImage).interpolation(.none)
                }
            #endif

        }
    #endif

#endif
