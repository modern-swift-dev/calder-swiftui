#if canImport(SwiftUI) || canImport(UIKit) || canImport(AppKit)
#if canImport(UIKit) && canImport(Vision) && !os(visionOS)
import AVFoundation
import CalderStdLib
@testable import CalderTheme
import CalderUIKit
import Testing
import UIKit

@Suite(.serialized)
@MainActor struct BarcodeScannerViewTests {

    @Test func `model stores default values`() {
        let model = BarcodeScannerView.Model()

        #expect(model.gravity == .resizeAspect)
        #expect(model.crossHairImageScaleModel == .scaleToFill)
        #expect(model.backgroundColor == .black)
        #expect(model.backdropColor == .black)
        #expect(model.backdropOpacity == 0.5)
        #expect(model.scanRegionWidthRatio == 0.2)
        #expect(model.scanRegionImageTint == .gray)
        #expect(model.scanRegionImageActiveTint == .blue)
        #expect(model.scanRegionImageMargin == .xxxs)
    }

    @Test func `model stores custom values`() {
        let image = UIImage()
        let model = BarcodeScannerView.Model(
            gravity: .resizeAspectFill,
            crossHairImage: image,
            crossHairImageScaleModel: .center,
            backgroundColor: .red,
            backdropColor: .green,
            backdropOpacity: 0.75,
            scanRegionWidthRatio: 0.4,
            scanRegionImageTint: .yellow,
            scanRegionImageActiveTint: .purple,
            scanRegionImageMargin: 12
        )

        #expect(model.gravity == .resizeAspectFill)
        #expect(model.crossHairImage === image)
        #expect(model.crossHairImageScaleModel == .center)
        #expect(model.backgroundColor == .red)
        #expect(model.backdropColor == .green)
        #expect(model.backdropOpacity == 0.75)
        #expect(model.scanRegionWidthRatio == 0.4)
        #expect(model.scanRegionImageTint == .yellow)
        #expect(model.scanRegionImageActiveTint == .purple)
        #expect(model.scanRegionImageMargin == 12)
    }

    @Test func `init builds scan region image view and constraints`() {
        let model = BarcodeScannerView.Model(
            crossHairImage: UIImage(),
            backgroundColor: .red,
            scanRegionWidthRatio: 0.5,
            scanRegionImageTint: .yellow
        )
        let view = BarcodeScannerView(model: model)
        view.frame = CGRect(x: 0, y: 0, width: 200, height: 300)
        view.layoutIfNeeded()

        #expect(view.backgroundColor == .red)
        #expect(view.scanRegionImageView.accessibilityIdentifier == "scanRegionImageView")
        #expect(view.scanRegionImageView.tintColor == .yellow)
        #expect(view.scanRegionImageView.translatesAutoresizingMaskIntoConstraints == false)
        #expect(view.scanRegionImageView.superview === view)
        #expect(!view.isSuspended)
    }

    @Test func `layout without session sizes scan region`() {
        let view = BarcodeScannerView(model: .init(crossHairImage: UIImage(), scanRegionWidthRatio: 0.2))
        view.frame = CGRect(x: 0, y: 0, width: 200, height: 300)

        view.layoutIfNeeded()

        #expect(view.scanRegionImageView.frame.width == 40)
        #expect(view.scanRegionImageView.frame.height == 40)
    }

    @Test func `moving away stops without session`() {
        let view = BarcodeScannerView(model: .init(crossHairImage: UIImage()))

        view.willMove(toSuperview: nil)
        view.willMove(toWindow: nil)

        #expect(!view.isSuspended)
    }

    @Test func `suspend resume torch and stop are safe without session`() {
        let view = BarcodeScannerView(model: .init(crossHairImage: UIImage()))

        view.suspend()
        #expect(view.isSuspended)

        view.resume()
        #expect(!view.isSuspended)

        #expect(!view.isTorchAvailable())
        view.toggleTorch()
        view.resetLastScan()
        view.stop()

        #expect(!view.isSuspended)
    }

    @Test func `suspension suppresses callback delivery until resumed`() {
        let view = BarcodeScannerView(model: .init(crossHairImage: UIImage()))
        let delegate = BarcodeScannerViewTestDelegate()
        view.delegate = delegate

        view.suspend()
        view.deliverScannedCode("first", type: .qr, rect: .zero, path: UIBezierPath())
        #expect(delegate.scannedCodes.isEmpty)

        view.resume()
        view.deliverScannedCode("second", type: .qr, rect: .zero, path: UIBezierPath())
        #expect(delegate.scannedCodes == ["second"])
    }

    @Test func `delegate default layout callback is noop`() {
        let delegate = BarcodeScannerViewTestDelegate()

        delegate.onLayoutChanges(description: "layout")

        #expect(delegate.supportedObjectTypes(AVCaptureMetadataOutput()) == [.qr])
    }

    @Test func `remove UPC check digit keeps eleven digit value`() {
        let value = BarcodeScannerView.removeUPCCheckDigitIfPresent("81001211009")

        #expect(value == "81001211009")
    }

    @Test func `remove UPC check digit removes valid twelfth digit`() {
        let value = BarcodeScannerView.removeUPCCheckDigitIfPresent("810012110099")

        #expect(value == "81001211009")
    }

    @Test func `remove UPC check digit removes zero check digit`() {
        let value = BarcodeScannerView.removeUPCCheckDigitIfPresent("000000000000")

        #expect(value == "00000000000")
    }

    @Test func `remove UPC check digit keeps invalid twelfth digit`() {
        let value = BarcodeScannerView.removeUPCCheckDigitIfPresent("810012110098")

        #expect(value == "810012110098")
    }

    @Test func `remove UPC check digit keeps unsupported length`() {
        let value = BarcodeScannerView.removeUPCCheckDigitIfPresent("1234567890")

        #expect(value == "1234567890")
    }
}

private final class BarcodeScannerViewTestDelegate: BarcodeScannerViewDelegate {
    var scannedCodes: [String] = []

    func supportedObjectTypes(_: AVCaptureMetadataOutput) -> [AVMetadataObject.ObjectType] {
        [.qr]
    }

    func onCodeScanned(_ code: String, type _: AVMetadataObject.ObjectType, rect _: CGRect, path _: UIBezierPath) {
        scannedCodes.append(code)
    }
}
#endif

#endif
