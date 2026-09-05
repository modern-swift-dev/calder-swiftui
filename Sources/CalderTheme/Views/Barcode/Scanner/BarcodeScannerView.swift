#if canImport(SwiftUI)
#if canImport(UIKit) && canImport(Vision) && !os(visionOS)
import AVFoundation
import AVKit
import CalderStdLib
import CalderUIKit
import Combine
import Foundation
import os
import SFSafeSymbols
import UIKit
import Vision

/// The Delegate for the scanner view
public protocol BarcodeScannerViewDelegate: AnyObject {
    /// Return the list of supported object type for scanning (defaults to all)
    /// - Parameter output: The `AVCaptureMetadataOutput` instance.
    /// - Returns: An array of `AVMetadataObject.ObjectType` that the delegate wants to scan.
    func supportedObjectTypes(_ output: AVCaptureMetadataOutput) -> [AVMetadataObject.ObjectType]

    /// Called when a new code has been scanned by the view.
    /// - Parameters:
    ///   - code: The string value of the scanned code.
    ///   - type: The `AVMetadataObject.ObjectType` of the scanned code.
    ///   - rect: The `CGRect` in the preview layer that encloses the scanned code.
    ///   - path: The `UIBezierPath` representing the boundaries of the scanned code in the preview layer.
    func onCodeScanned(_ code: String, type: AVMetadataObject.ObjectType, rect: CGRect, path: UIBezierPath)
}

public extension BarcodeScannerViewDelegate {
    /// Called when the layout of the scanner view changes.
    /// - Parameter description: A description of the layout change (currently not used in implementation).
    func onLayoutChanges(description _: String) {}
}

/// A reusable scanner view to scan for barcode or qr code
public class BarcodeScannerView: UIView {

    /// Requests camera permission from the user.
    /// - Returns: `true` if permission is granted, `false` otherwise.
    public static func requestPermission() async -> Bool {
        await AVCaptureDevice.requestAccess(for: .video)
    }

    /// The View Model for the scanner view
    public struct Model {
        /// Initializes a new `BarcodeScannerView.Model`.
        /// - Parameters:
        ///   - gravity: The video gravity for the preview layer. Defaults to `.resizeAspect`.
        ///   - crossHairImage: The image used for the scan region crosshair. Defaults to a system viewfinder symbol.
        ///   - crossHairImageScaleModel: The content mode for the crosshair image. Defaults to `.scaleToFill`.
        ///   - backgroundColor: The background color of the view. Defaults to `.black`.
        ///   - backdropColor: The color of the overlay outside the scan region. Defaults to `.azur`.
        ///   - backdropOpacity: The opacity of the backdrop overlay. Defaults to `1.0`.
        ///   - scanRegionWidthRatio: The width ratio of the scan region relative to the parent view's width. Defaults to `0.2`.
        ///   - scanRegionImageTint: The tint color of the crosshair image when inactive. Defaults to `.orage`.
        ///   - scanRegionImageActiveTint: The tint color of the crosshair image when active (code detected). Defaults to `.azur`.
        ///   - scanRegionImageMargin: The margin applied to the scan region image to define the `rectOfInterest`. Defaults to `.xxxs`.
        public init(
            gravity: AVLayerVideoGravity = .resizeAspect,
            crossHairImage: UIImage = .init(
                systemSymbol: .viewfinder,
                withConfiguration: UIImage.SymbolConfiguration(weight: .ultraLight)
            ),
            crossHairImageScaleModel: UIView.ContentMode = .scaleToFill,
            backgroundColor: UIColor = UIColor.black,
            backdropColor: UIColor = UIColor.black,
            backdropOpacity: CGFloat = 0.5,
            scanRegionWidthRatio: CGFloat = 0.2,
            scanRegionImageTint: UIColor = UIColor.gray,
            scanRegionImageActiveTint: UIColor = UIColor.blue,
            scanRegionImageMargin: CGFloat = .xxxs
        ) {
            self.gravity = gravity
            self.crossHairImage = crossHairImage
            self.crossHairImageScaleModel = crossHairImageScaleModel
            self.backgroundColor = backgroundColor
            self.backdropColor = backdropColor
            self.backdropOpacity = backdropOpacity
            self.scanRegionWidthRatio = scanRegionWidthRatio
            self.scanRegionImageTint = scanRegionImageTint
            self.scanRegionImageActiveTint = scanRegionImageActiveTint
            self.scanRegionImageMargin = scanRegionImageMargin
        }

        /// The Video Gravity for the `AVCaptureVideoPreviewLayer`.
        var gravity: AVLayerVideoGravity

        /// The Crosshair Image displayed in the center of the scan region.
        var crossHairImage: UIImage

        /// The content mode for the `crossHairImage`.
        var crossHairImageScaleModel: UIView.ContentMode

        /// The background color of the `BarcodeScannerView`.
        var backgroundColor: UIColor

        /// The color of the opaque backdrop overlay outside the scan region.
        var backdropColor: UIColor

        /// The opacity of the backdrop overlay.
        var backdropOpacity: CGFloat

        /// The width ratio of the scan region compared to its parent view's width.
        var scanRegionWidthRatio: CGFloat

        /// The tint color of the scan region image when no code is actively being scanned.
        var scanRegionImageTint: UIColor

        /// The tint color of the scan region image when a code is actively being scanned.
        var scanRegionImageActiveTint: UIColor

        /// The margin applied to the scan region image to define the `rectOfInterest` for `AVCaptureMetadataOutput`.
        var scanRegionImageMargin: CGFloat
    }

    /// The Delegate that receives scan events and provides supported object types.
    public weak var delegate: (any BarcodeScannerViewDelegate)?

    /// A boolean indicating whether the barcode scanning is currently suspended.
    public private(set) var isSuspended: Bool = false

    /// The Last Known Scan Value to prevent spamming the same code in rapid burst
    private var lastScanValue = ""

    /// The Model of this view containing configuration options.
    private var model: Model

    /// The `AVCaptureSession` managing the video capture.
    private var avSession: AVCaptureSession?
    /// The `AVCaptureDevice` representing the camera.
    private var avDevice: AVCaptureDevice?
    /// The `AVCaptureVideoPreviewLayer` displaying the camera feed.
    private var avVideoPreviewLayer: AVCaptureVideoPreviewLayer?
    /// The `AVCaptureDeviceInput` for the camera device.
    private var avInput: AVCaptureDeviceInput?
    /// The `AVCaptureMetadataOutput` for detecting metadata objects (barcodes/QR codes).
    private var avOutput: AVCaptureMetadataOutput?

    /// The `UIImageView` displaying the crosshair image for the scan region.
    public private(set) lazy var scanRegionImageView: UIImageView = {
        let scanRegionImageView = UIImageView(image: model.crossHairImage)
        scanRegionImageView.accessibilityIdentifier = "scanRegionImageView"
        scanRegionImageView.contentMode = .scaleToFill
        scanRegionImageView.translatesAutoresizingMaskIntoConstraints = false
        scanRegionImageView.tintColor = model.scanRegionImageTint
        return scanRegionImageView
    }()

    /// The `CAShapeLayer` used for the transparent overlay around the scan region.
    private var scanRegionImageShape: CAShapeLayer?

    /// A set of `AnyCancellable` to store Combine subscriptions.
    private var cancellables = Set<AnyCancellable>()

    /// Initializes a new `BarcodeScannerView` with the specified model.
    /// - Parameter model: The view model containing configuration for the scanner.
    public init(model: Model) {
        self.model = model
        super.init(frame: .zero)
        buildSubviews()
        buildConstraints()

        NotificationCenter.default.publisher(for: AVCaptureInput.Port.formatDescriptionDidChangeNotification)
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] _ in
                self?.onInputFormatChanged()
            })
            .store(in: &cancellables)
    }

    override public func willMove(toWindow newWindow: UIWindow?) {
        if newWindow == nil {
            stop()
        }
    }

    override public func willMove(toSuperview newSuperview: UIView?) {
        if newSuperview == nil {
            stop()
        }
    }

    /// Initializes a new `BarcodeScannerView` from a coder (unavailable).
    @available(*, unavailable) public required init?(coder _: NSCoder) {
        fatalError()
    }

    /// Called when the input format description changes, updating the `rectOfInterest`.
    @objc private func onInputFormatChanged() {
        updateRectOfInterest()
    }

    /// Updates the `rectOfInterest` for the `AVCaptureMetadataOutput` based on the scan region.
    private func updateRectOfInterest() {
        guard let avOutput, let avVideoPreviewLayer else {
            return
        }

        let rectOfInterest = calculateNonConvertedRectOfInterest()
        avOutput.rectOfInterest = avVideoPreviewLayer.metadataOutputRectConverted(fromLayerRect: rectOfInterest)
    }
}

// MARK: - Layout

extension BarcodeScannerView {
    /// Builds and configures the initial subviews of the scanner view.
    private func buildSubviews() {
        backgroundColor = model.backgroundColor
    }

    /// Configures the Auto Layout constraints for the subviews.
    private func buildConstraints() {
        addSubview(scanRegionImageView)
        NSLayoutConstraint.activate {
            scanRegionImageView.widthAnchor.eq(widthAnchor, multiplier: model.scanRegionWidthRatio, constant: 0)
            scanRegionImageView.heightAnchor.eq(widthAnchor, multiplier: model.scanRegionWidthRatio, constant: 0)
            scanRegionImageView.centerXAnchor.eq(centerXAnchor)
            scanRegionImageView.centerYAnchor.eq(centerYAnchor)
        }
    }

    /// When the view needs to layout it's subviews (after a layout changes),
    /// we need to resize the layers and the shape of the scanning region accordingly.
    override public func layoutSubviews() {
        super.layoutSubviews()
        configureVideoOrientation()
        configureLayersAndShape()
        updateRectOfInterest()
    }
}

// MARK: - Last Known Scan

public extension BarcodeScannerView {
    /// Resets the last known scanned value, allowing the same code to be scanned again immediately.
    func resetLastScan() {
        lastScanValue = ""
    }
}

// MARK: - Torch

public extension BarcodeScannerView {
    /// Returns `true` if the device has a torch and it is available for use.
    /// - Returns: `true` if torch is available, `false` otherwise.
    func isTorchAvailable() -> Bool {
        guard let device = avDevice, device.hasTorch, device.isTorchAvailable else {
            return false
        }
        return true
    }

    /// Toggles the torch (flashlight) on or off.
    /// If the torch is off, it will be turned on with a default level (0.25).
    /// If the torch is on, it will be turned off.
    func toggleTorch() {
        guard let device = avDevice, device.hasTorch, device.isTorchAvailable else {
            return
        }
        do {
            try device.lockForConfiguration()
            if !device.isTorchActive {
                try device.setTorchModeOn(level: 0.25)
            } else {
                device.torchMode = .off
            }
            device.unlockForConfiguration()
        } catch {
            os_log("%{public}@", log: .default, type: .error, String(describing: error))
        }
    }
}

// MARK: - State

public extension BarcodeScannerView {
    /// Initializes and starts the barcode scanning session.
    /// This method should be called when the view is ready to capture video.
    func start() {
        guard avSession == nil else {
            return
        }

        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
            return
        }

        do {
            try device.lockForConfiguration()
            device.videoZoomFactor = device.minAvailableVideoZoomFactor
            if device.isLowLightBoostEnabled {
                device.automaticallyEnablesLowLightBoostWhenAvailable = true
            }
            device.unlockForConfiguration()
        } catch {
            os_log("%{public}@", log: .default, type: .error, String(describing: error))
        }

        let session = AVCaptureSession()
        avSession = session

        let layer = AVCaptureVideoPreviewLayer(session: session)
        layer.bounds = bounds
        layer.position = CGPoint(x: bounds.midX, y: bounds.midY)
        layer.backgroundColor = model.backgroundColor.cgColor
        layer.videoGravity = model.gravity
        layer.frame = bounds
        avVideoPreviewLayer = layer
        avDevice = device

        do {
            session.beginConfiguration()
            let input = try AVCaptureDeviceInput(device: device)
            session.addInput(input)
            avInput = input

            let output = AVCaptureMetadataOutput()
            output.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            session.addOutput(output)
            output.metadataObjectTypes = delegate?.supportedObjectTypes(output) ?? output.availableMetadataObjectTypes
            avOutput = output

            session.commitConfiguration()
        } catch {
            os_log("%{public}@", log: .default, type: .error, String(describing: error))
            session.commitConfiguration()
        }

        self.layer.insertSublayer(layer, at: 0)
        self.updateRectOfInterest()

        DispatchQueue.global(qos: .background).async { [session] in
            session.startRunning()
        }

    }

    /// Suspends the barcode scanning process. When suspended, the delegate will not receive new scanned codes.
    func suspend() {
        isSuspended = true
    }

    /// Resumes the barcode scanning process after being suspended.
    func resume() {
        isSuspended = false
    }

    /// Stops the video capture session and tears down related AVFoundation objects.
    /// This makes the view completely unusable until `start()` is called again.
    func stop() {
        avVideoPreviewLayer?.removeFromSuperlayer()
        avVideoPreviewLayer = nil
        avSession?.stopRunning()
        avSession = nil
        avDevice = nil
        avInput = nil
        avOutput = nil
    }
}

// MARK: - Orientation

public extension BarcodeScannerView {
    /// Configures the video orientation of the `AVCaptureVideoPreviewLayer`
    /// to match the current interface orientation of the device.
    func configureVideoOrientation() {
        #if !os(tvOS)
        if #available(iOS 18, *) {
            if let videoLayer = avVideoPreviewLayer, let connection = videoLayer.connection {
                let angle: CGFloat = videoAngleFrom(orientation: UIDevice.current.orientation)
                if connection.isVideoRotationAngleSupported(angle) {
                    connection.videoRotationAngle = angle
                }
            }

        } else {
            if let orientation = self.window?.windowScene?.interfaceOrientation {
                switch orientation {
                    case .portrait:
                        avVideoPreviewLayer?.connection?.videoOrientation = .portrait
                    case .landscapeLeft:
                        avVideoPreviewLayer?.connection?.videoOrientation = .landscapeLeft
                    case .landscapeRight:
                        avVideoPreviewLayer?.connection?.videoOrientation = .landscapeRight
                    case .portraitUpsideDown:
                        avVideoPreviewLayer?.connection?.videoOrientation = .portraitUpsideDown
                    case .unknown:
                        avVideoPreviewLayer?.connection?.videoOrientation = .portrait
                    @unknown default:
                        avVideoPreviewLayer?.connection?.videoOrientation = .portrait
                }
            }
        }
        #endif
    }

    #if !os(tvOS)
    /// Translate the Device orientation to the correct video capture orientation
    private func videoAngleFrom(orientation: UIDeviceOrientation) -> CGFloat {
        switch orientation {
            case .portrait:
                0.0
            case .landscapeLeft:
                -90.0
            case .landscapeRight:
                90.0
            case .portraitUpsideDown:
                180.0
            default:
                0.0
        }
    }
    #endif

}

// MARK: - Layers & Overlay

public extension BarcodeScannerView {

    /// Calculates the `CGRect` of the region of interest for scanning, relative to the view's bounds,
    /// without converting it to the metadata output's coordinate system.
    /// - Returns: The non-converted `CGRect` representing the scan region.
    private func calculateNonConvertedRectOfInterest() -> CGRect {
        let positionAdj = model.scanRegionImageMargin
        let sizeAdj: CGFloat = positionAdj * 2.0
        return CGRect(
            x: bounds.midX - (scanRegionImageView.frame.size.width / 2.0) - positionAdj,
            y: scanRegionImageView.frame.minY - positionAdj,
            width: scanRegionImageView.frame.size.width + sizeAdj,
            height: scanRegionImageView.frame.size.height + sizeAdj
        )
    }

    /// Configures the bounds, frame, and position of the video preview layer and
    /// creates or updates the transparent overlay masking the non-scan region.
    private func configureLayersAndShape() {
        if let layer = avVideoPreviewLayer {
            layer.bounds = bounds
            layer.frame = frame
            layer.position = CGPoint(x: bounds.midX, y: bounds.midY)
        }
        createOrUpdateTransparentOverlay()
    }

    /// Creates or updates a `CAShapeLayer` overlay that visually masks the area
    /// outside the defined scan region, making it semi-transparent.
    private func createOrUpdateTransparentOverlay() {
        guard let videoLayer = avVideoPreviewLayer else {
            return
        }

        let rectOfInterest = calculateNonConvertedRectOfInterest()

        let path = UIBezierPath(rect: CGRect(origin: .zero, size: bounds.size))
        let rectangularPath = UIBezierPath(rect: rectOfInterest)
        path.append(rectangularPath)
        path.usesEvenOddFillRule = true

        guard scanRegionImageShape == nil else {
            scanRegionImageShape?.bounds = bounds
            scanRegionImageShape?.frame = frame
            scanRegionImageShape?.position = CGPoint(x: bounds.midX, y: bounds.midY)
            scanRegionImageShape?.path = path.cgPath
            scanRegionImageShape?.setNeedsDisplay()
            return
        }

        let fillLayer = CAShapeLayer()
        fillLayer.bounds = bounds
        fillLayer.frame = frame
        fillLayer.position = CGPoint(x: bounds.midX, y: bounds.midY)
        fillLayer.path = path.cgPath
        fillLayer.fillRule = .evenOdd
        fillLayer.fillColor = model.backdropColor.cgColor
        fillLayer.opacity = Float(model.backdropOpacity)
        layer.insertSublayer(fillLayer, above: videoLayer)
        scanRegionImageShape = fillLayer
        avOutput?.rectOfInterest = videoLayer.metadataOutputRectConverted(fromLayerRect: rectOfInterest)
    }
}

// MARK: - AVCaptureMetadataOutputObjectsDelegate

extension BarcodeScannerView: @preconcurrency AVCaptureMetadataOutputObjectsDelegate {
    /// Called when the capture output receives new metadata objects.
    /// - Parameters:
    ///   - output: The metadata output object that produced the new metadata objects.
    ///   - metadataObjects: An array of `AVMetadataObject` instances.
    ///   - connection: The `AVCaptureConnection` from which the metadata objects were captured.
    public func metadataOutput(
        _ output: AVCaptureMetadataOutput,
        didOutput metadataObjects: [AVMetadataObject],
        from _: AVCaptureConnection
    ) {
        guard !isSuspended else {
            return
        }

        if let codeObject = metadataObjects.first {

            self.scanRegionImageView.tintColor = self.model.scanRegionImageActiveTint

            guard let avVideoPreviewLayer = self.avVideoPreviewLayer,
                  let transformedObject = avVideoPreviewLayer.transformedMetadataObject(for: codeObject) as? AVMetadataMachineReadableCodeObject,
                  let code = transformedObject.stringValue else {
                return
            }

            let type = transformedObject.type
            if self.lastScanValue != code {
                let rect = transformedObject.rect(in: avVideoPreviewLayer)
                let path = transformedObject.path(for: avVideoPreviewLayer)
                self.lastScanValue = code

                DispatchQueue.main.async { [weak self] in
                    self?.deliverScannedCode(code, type: type, rect: rect, path: path)
                }
            }
        }

        self.scanRegionImageView.tintColor = self.model.scanRegionImageTint
    }

    /// Delivers a recognized code only while scanning is active, including queued callbacks.
    func deliverScannedCode(_ code: String, type: AVMetadataObject.ObjectType, rect: CGRect, path: UIBezierPath) {
        guard !isSuspended else {
            return
        }
        delegate?.onCodeScanned(code, type: type, rect: rect, path: path)
    }
}

public extension AVMetadataMachineReadableCodeObject {

    /// Returns the bounding rectangle for the specified metadata object within the given preview layer.
    /// - Parameter layer: The `AVCaptureVideoPreviewLayer` displaying the video.
    /// - Returns: The `CGRect` of the detected object in the preview layer's coordinates.
    func rect(in layer: AVCaptureVideoPreviewLayer) -> CGRect {
        let points = corners.map { layer.layerPointConverted(fromCaptureDevicePoint: $0) }
        let minX: CGFloat = points.min { param1, param2 in param1.x < param2.x }.map(\.x) ?? 0.0
        let minY: CGFloat = points.min { param1, param2 in param1.y < param2.y }.map(\.y) ?? 0.0
        let maxX: CGFloat = points.max { param1, param2 in param1.x < param2.x }.map(\.x) ?? 0.0
        let maxY: CGFloat = points.max { param1, param2 in param1.y < param2.y }.map(\.y) ?? 0.0
        return CGRect(x: minX, y: minY, width: maxX - minX, height: maxY - minY)
    }

    /// Returns a `UIBezierPath` representing the boundaries of the detected object within the given preview layer.
    /// - Parameter layer: The `AVCaptureVideoPreviewLayer` displaying the video.
    /// - Returns: The `UIBezierPath` of the detected object.
    func path(for layer: AVCaptureVideoPreviewLayer) -> UIBezierPath {
        let points = corners.map { layer.layerPointConverted(fromCaptureDevicePoint: $0) }
        let path = UIBezierPath(rect: layer.bounds)
        for (x, point) in points.enumerated() {
            if x == 0 {
                path.move(to: point)
            } else {
                path.addLine(to: point)
            }
        }
        path.close()
        return path
    }
}

// MARK: - Check Digit for UPC-A
public extension BarcodeScannerView {

    /**
     * Try & Detect the presence of UPC-A check-digit, and remove it.
     *
     * Algorithm for calculating the check-digit is as-follows:
     * - Take all the digits in odd positions, add them and multiply by three;
     * - Take all the digits in even positions (except for the last one) and add to the number you got above;
     * - Divide that number by 10 and take the reminder;
     * - If the reminder is not 0, subtract it from 10.
     * - That's it.
     *
     * Exemple for barcode 810012110099:
     * The digits in odd positions are: 8, 0, 1, 1, 0, 9, their sum is 19, multiplied by 3 it is 57;
     * The digits in even positions (except the last one) are: 1, 0, 2, 1, 0, their sum is 4, added to the number above it is 61;
     * Dividing 61 by 10 gives us 1 as a reminder;
     * It is not zero, so subtracting it from 10 to get the check digit: 9.
     *
     * - Parameter value: The UPC-A barcode string to process.
     * - Returns: The UPC-A barcode string with the check-digit removed if present and valid.
     */
    static func removeUPCCheckDigitIfPresent(_ value: String) -> String {
        if value.count == 11 {
            return value
        }

        if value.count == 12 {
            var totalEven = 0
            for x in stride(from: 0, to: value.count, by: 2) {
                totalEven += Int(value.substr(start: x, len: 1)) ?? 0
            }
            totalEven *= 3

            var totalOdd = 0
            for x in stride(from: 1, to: value.count - 1, by: 2) {
                totalOdd += Int(value.substr(start: x, len: 1)) ?? 0
            }

            var checkDigit = ((totalOdd + totalEven) % 10)
            if checkDigit > 0 {
                checkDigit = 10 - checkDigit
            }

            let lastDigit = value.last?.int ?? 0
            if checkDigit == lastDigit {
                return value.substr(start: 0, len: value.count - 1)
            }
            return value

        }
        return value
    }
}

extension AVCaptureSession: @unchecked @retroactive Sendable {}
extension AVCaptureVideoPreviewLayer: @unchecked @retroactive Sendable {}
#endif

#endif
