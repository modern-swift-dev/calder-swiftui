#if canImport(SwiftUI)
    #if canImport(UIKit) && canImport(Vision) && !os(visionOS) && !os(watchOS)
        import AVFoundation
        import AVKit
        import CalderStdLib
        import CalderUIKit
        import Foundation
        import os
        import SFSafeSymbols
        import UIKit
        import Vision

        /// The Delegate for the scanner view.
        ///
        /// The delegate is main-actor isolated, except for ``supportedObjectTypes(_:)``, which the scanner
        /// calls on its capture-session queue while it configures the session.
        @MainActor public protocol BarcodeScannerViewDelegate: AnyObject, Sendable {
            /// Return the list of supported object type for scanning (defaults to all)
            ///
            /// The scanner calls this method on its capture-session queue, after it adds `output` to the session.
            /// - Parameter output: The `AVCaptureMetadataOutput` instance.
            /// - Returns: An array of `AVMetadataObject.ObjectType` that the delegate wants to scan.
            nonisolated func supportedObjectTypes(_ output: AVCaptureMetadataOutput) -> [AVMetadataObject.ObjectType]

            /// Called on the main actor when a new code has been scanned by the view.
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

            /// The serial queue that runs every configuration, start, and stop step of this view's capture sessions.
            private let sessionQueue = DispatchQueue(label: "dev.modern-swift.calder.barcode-scanner.session")
            /// The serial queue on which the metadata output delivers detected codes, kept apart from the blocking session work.
            private let metadataQueue = DispatchQueue(label: "dev.modern-swift.calder.barcode-scanner.metadata")
            /// The controller that owns the running `AVCaptureSession`, or `nil` when the scanner is stopped.
            private var sessionController: BarcodeScannerSessionController<AVCaptureSession>?
            /// The `AVCaptureDevice` representing the camera.
            private var avDevice: AVCaptureDevice?
            /// The `AVCaptureVideoPreviewLayer` displaying the camera feed.
            private var avVideoPreviewLayer: AVCaptureVideoPreviewLayer?

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

            /// The main-actor task that updates the `rectOfInterest` when the input format changes while the scanner runs.
            private var inputFormatObservation: Task<Void, Never>?

            /// Initializes a new `BarcodeScannerView` with the specified model.
            /// - Parameter model: The view model containing configuration for the scanner.
            public init(model: Model) {
                self.model = model
                super.init(frame: .zero)
                buildSubviews()
                buildConstraints()
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

            /// Updates the `rectOfInterest` on the main actor each time an input format description changes, until cancelled.
            private func observeInputFormatChanges() {
                inputFormatObservation?.cancel()
                inputFormatObservation = Task { [weak self] in
                    for await _ in NotificationCenter.default.notifications(named: AVCaptureInput.Port.formatDescriptionDidChangeNotification) {
                        self?.updateRectOfInterest()
                    }
                }
            }

            /// Updates the `rectOfInterest` for the `AVCaptureMetadataOutput` based on the scan region.
            ///
            /// The rectangle is converted on the main actor, where the preview layer lives, and applied on the session queue.
            private func updateRectOfInterest() {
                guard let sessionController, let avVideoPreviewLayer else {
                    return
                }

                let rectOfInterest = avVideoPreviewLayer.metadataOutputRectConverted(fromLayerRect: calculateNonConvertedRectOfInterest())
                sessionController.perform { session in
                    for case let output as AVCaptureMetadataOutput in session.outputs {
                        output.rectOfInterest = rectOfInterest
                    }
                }
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
            ///
            /// The session is configured and started on the view's serial session queue, so this method returns
            /// without waiting for the camera.
            func start() {
                guard sessionController == nil else {
                    return
                }

                guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
                    return
                }

                let session = AVCaptureSession()
                let controller = BarcodeScannerSessionController(session: session, queue: sessionQueue)
                sessionController = controller

                let layer = AVCaptureVideoPreviewLayer(session: session)
                layer.bounds = bounds
                layer.position = CGPoint(x: bounds.midX, y: bounds.midY)
                layer.backgroundColor = model.backgroundColor.cgColor
                layer.videoGravity = model.gravity
                layer.frame = bounds
                avVideoPreviewLayer = layer
                avDevice = device

                let deviceID = device.uniqueID
                let typesProvider = delegate
                let metadataQueue = metadataQueue
                controller.perform { [weak self] session in
                    guard let self else {
                        return
                    }
                    Self.configure(
                        session,
                        deviceID: deviceID,
                        metadataObjectsDelegate: self,
                        metadataQueue: metadataQueue,
                        typesProvider: typesProvider
                    )
                }

                self.layer.insertSublayer(layer, at: 0)
                self.updateRectOfInterest()
                observeInputFormatChanges()

                controller.startRunning()
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
            ///
            /// The session stops on the view's serial session queue after any pending configuration or start,
            /// so this method never blocks the main thread.
            func stop() {
                inputFormatObservation?.cancel()
                inputFormatObservation = nil
                avVideoPreviewLayer?.removeFromSuperlayer()
                avVideoPreviewLayer = nil
                sessionController?.stopRunning()
                sessionController = nil
                avDevice = nil
            }
        }

        // MARK: - Session Configuration

        extension BarcodeScannerView {
            /// Configures the camera device, input, and metadata output of `session`. Runs on the session queue.
            /// - Parameters:
            ///   - session: The session to configure.
            ///   - deviceID: The unique identifier of the camera to capture from.
            ///   - metadataObjectsDelegate: The object that receives detected metadata objects.
            ///   - metadataQueue: The serial queue on which `metadataObjectsDelegate` receives metadata objects.
            ///   - typesProvider: The delegate that selects the metadata object types to detect, if any.
            private nonisolated static func configure(
                _ session: AVCaptureSession,
                deviceID: String,
                metadataObjectsDelegate: any AVCaptureMetadataOutputObjectsDelegate,
                metadataQueue: DispatchQueue,
                typesProvider: (any BarcodeScannerViewDelegate)?
            ) {
                guard let device = AVCaptureDevice(uniqueID: deviceID) else {
                    return
                }

                do {
                    try device.lockForConfiguration()
                    device.videoZoomFactor = device.minAvailableVideoZoomFactor
                    if device.isLowLightBoostSupported {
                        device.automaticallyEnablesLowLightBoostWhenAvailable = true
                    }
                    device.unlockForConfiguration()
                } catch {
                    os_log("%{public}@", log: .default, type: .error, String(describing: error))
                }

                session.beginConfiguration()
                defer {
                    session.commitConfiguration()
                }

                let input: AVCaptureDeviceInput
                do {
                    input = try AVCaptureDeviceInput(device: device)
                } catch {
                    os_log("%{public}@", log: .default, type: .error, String(describing: error))
                    return
                }
                guard session.canAddInput(input) else {
                    os_log("The barcode scanner session cannot add its camera input.", log: .default, type: .error)
                    return
                }
                session.addInput(input)

                let output = AVCaptureMetadataOutput()
                guard session.canAddOutput(output) else {
                    os_log("The barcode scanner session cannot add its metadata output.", log: .default, type: .error)
                    return
                }
                session.addOutput(output)
                output.setMetadataObjectsDelegate(metadataObjectsDelegate, queue: metadataQueue)

                let available = output.availableMetadataObjectTypes
                let requested = typesProvider?.supportedObjectTypes(output) ?? available
                let supported = supportedMetadataObjectTypes(requested: requested, available: available)
                if supported.count < requested.count {
                    let unsupported = requested.filter { !supported.contains($0) }.map(\.rawValue)
                    os_log("Ignoring unsupported barcode types: %{public}@", log: .default, type: .error, unsupported.joined(separator: ", "))
                }
                output.metadataObjectTypes = supported
            }

            /// Returns the requested metadata object types that the output can detect, in their requested order.
            ///
            /// Assigning an unavailable type to `AVCaptureMetadataOutput.metadataObjectTypes` raises an exception,
            /// so unsupported types are dropped instead.
            /// - Parameters:
            ///   - requested: The types the scanner was asked to detect.
            ///   - available: The output's `availableMetadataObjectTypes`.
            /// - Returns: The requested types that are also available.
            nonisolated static func supportedMetadataObjectTypes(
                requested: [AVMetadataObject.ObjectType],
                available: [AVMetadataObject.ObjectType]
            ) -> [AVMetadataObject.ObjectType] {
                requested.filter(available.contains)
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
            }
        }

        // MARK: - AVCaptureMetadataOutputObjectsDelegate

        extension BarcodeScannerView: AVCaptureMetadataOutputObjectsDelegate {
            /// Called on the scanner's metadata queue when the capture output receives new metadata objects.
            ///
            /// The first machine-readable code is reduced to sendable values and handed to the main actor.
            /// - Parameters:
            ///   - output: The metadata output object that produced the new metadata objects.
            ///   - metadataObjects: An array of `AVMetadataObject` instances.
            ///   - connection: The `AVCaptureConnection` from which the metadata objects were captured.
            public nonisolated func metadataOutput(
                _ output: AVCaptureMetadataOutput,
                didOutput metadataObjects: [AVMetadataObject],
                from _: AVCaptureConnection
            ) {
                guard let codeObject = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
                      let code = codeObject.stringValue else {
                    return
                }

                let type = codeObject.type
                let corners = codeObject.corners
                Task { @MainActor [weak self] in
                    self?.handleDetectedCode(code, type: type, corners: corners)
                }
            }

            /// Handles a code detected by the capture session.
            /// - Parameters:
            ///   - code: The string value of the detected code.
            ///   - type: The type of the detected code.
            ///   - corners: The corners of the detected code in capture-device coordinates.
            private func handleDetectedCode(_ code: String, type: AVMetadataObject.ObjectType, corners: [CGPoint]) {
                guard !isSuspended else {
                    return
                }

                scanRegionImageView.tintColor = model.scanRegionImageActiveTint

                if let avVideoPreviewLayer, lastScanValue != code {
                    let points = corners.map { avVideoPreviewLayer.layerPointConverted(fromCaptureDevicePoint: $0) }
                    lastScanValue = code
                    deliverScannedCode(
                        code,
                        type: type,
                        rect: Self.boundingRect(of: points),
                        path: Self.cutOutPath(in: avVideoPreviewLayer.bounds, around: points)
                    )
                }

                scanRegionImageView.tintColor = model.scanRegionImageTint
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
                BarcodeScannerView.boundingRect(of: corners.map { layer.layerPointConverted(fromCaptureDevicePoint: $0) })
            }

            /// Returns a `UIBezierPath` representing the boundaries of the detected object within the given preview layer.
            /// - Parameter layer: The `AVCaptureVideoPreviewLayer` displaying the video.
            /// - Returns: The `UIBezierPath` of the detected object.
            func path(for layer: AVCaptureVideoPreviewLayer) -> UIBezierPath {
                BarcodeScannerView.cutOutPath(in: layer.bounds, around: corners.map { layer.layerPointConverted(fromCaptureDevicePoint: $0) })
            }
        }

        // MARK: - Code Geometry

        extension BarcodeScannerView {
            /// Returns the smallest rectangle that contains `points`, or `.zero` when there are none.
            /// - Parameter points: The corners of a detected code in layer coordinates.
            /// - Returns: The bounding rectangle of `points`.
            nonisolated static func boundingRect(of points: [CGPoint]) -> CGRect {
                let minX: CGFloat = points.min { param1, param2 in param1.x < param2.x }.map(\.x) ?? 0.0
                let minY: CGFloat = points.min { param1, param2 in param1.y < param2.y }.map(\.y) ?? 0.0
                let maxX: CGFloat = points.max { param1, param2 in param1.x < param2.x }.map(\.x) ?? 0.0
                let maxY: CGFloat = points.max { param1, param2 in param1.y < param2.y }.map(\.y) ?? 0.0
                return CGRect(x: minX, y: minY, width: maxX - minX, height: maxY - minY)
            }

            /// Returns a path made of `bounds` followed by the closed polygon through `points`.
            /// - Parameters:
            ///   - bounds: The bounds of the preview layer.
            ///   - points: The corners of a detected code in layer coordinates.
            /// - Returns: The combined path.
            nonisolated static func cutOutPath(in bounds: CGRect, around points: [CGPoint]) -> UIBezierPath {
                let path = UIBezierPath(rect: bounds)
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

    #endif

#endif
