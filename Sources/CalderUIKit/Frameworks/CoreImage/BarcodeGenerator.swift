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

public enum BarcodeGenerator {
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
                1.5
            case .qr:
                5.0
            case .pdf417:
                2.0
        }
    }

    public func createCIImage(_ barcode: String, quietSpace: CGFloat? = nil) -> CIImage? {
        guard let filter = CIFilter(name: filterName), let data = barcode.data(using: .ascii) else {
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
            return ciImage.transformed(by: transform)
        }
        return filter.outputImage
    }

    #if canImport(UIKit)
    public func createUIImage(barcode: String, quietSpace: CGFloat? = nil) -> UIImage? {
        guard let ciImage = createCIImage(barcode, quietSpace: quietSpace) else {
            return nil
        }
        return UIImage(ciImage: ciImage)
    }

    public func createImage(barcode: String, quietSpace: CGFloat? = nil) -> Image? {
        guard let ciImage = createCIImage(barcode, quietSpace: quietSpace), let data = CIImage.toPNG(image: ciImage), let uiImage = UIImage(data: data) else {
            return nil
        }
        return Image(uiImage: uiImage)
    }
    #endif

    #if canImport(AppKit) && !targetEnvironment(macCatalyst)

    public func createImage(barcode: String, quietSpace: CGFloat? = nil) -> Image? {
        guard let ciImage = createCIImage(barcode, quietSpace: quietSpace), let data = CIImage.toPNG(image: ciImage), let uiImage = NSImage(data: data) else {
            return nil
        }
        return Image(nsImage: uiImage)
    }
    #endif

}
#endif

#endif
