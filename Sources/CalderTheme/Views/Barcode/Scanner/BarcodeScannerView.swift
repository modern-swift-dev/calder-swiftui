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
                ///   - isTorchOn: Whether the torch is on while the camera runs. Defaults to `false`. A camera without a torch ignores it.
                ///   - zoomFactor: The camera's zoom factor, clamped to the range the camera supports. Defaults to `1`, which is no zoom.
                ///   - repeatCooldown: How long to suppress a repeat of the same value, which makes the scanner continuous: it keeps
                ///     reporting codes, and reports the same value again once the cooldown has passed. Defaults to `nil`, which reports
                ///     a value once until ``resetLastScan()``.
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
                    scanRegionImageMargin: CGFloat = .xxxs,
                    isTorchOn: Bool = false,
                    zoomFactor: CGFloat = 1,
                    repeatCooldown: Duration? = nil
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
                    self.isTorchOn = isTorchOn
                    self.zoomFactor = zoomFactor
                    self.repeatCooldown = repeatCooldown
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

                /// Whether the torch is on while the camera runs. A camera without a torch ignores it.
                var isTorchOn: Bool

                /// The camera's zoom factor, clamped to the range the camera supports.
                var zoomFactor: CGFloat

                /// How long to suppress a repeat of the same value in continuous scanning, or `nil` to report a value once.
                var repeatCooldown: Duration?
            }

            /// The Delegate that receives scan events and provides supported object types.
            public weak var delegate: (any BarcodeScannerViewDelegate)?

            /// A boolean indicating whether the barcode scanning is currently suspended.
            public private(set) var isSuspended: Bool = false

            /// The Last Known Scan Value to prevent spamming the same code in rapid burst
            private var lastScanValue = ""

            /// Suppresses repeats of a value while the scanner is continuous, or `nil` when it reports a value once.
            private var cooldown: BarcodeScanCooldown?

            /// The clock that times the cooldown. A test replaces it.
            var now: () -> ContinuousClock.Instant = { .now }

            /// Whether the torch should be on while the camera runs.
            private var desiredTorch: Bool

            /// The zoom factor the camera should have while it runs, before clamping to its range.
            private var desiredZoom: CGFloat

            /// The zoom factor when the current pinch began, or `nil` between pinches.
            private var pinchStartZoom: CGFloat?

            /// Called with the new zoom factor, already clamped to the camera's range, each time a pinch changes it.
            public var onZoomFactorChange: ((CGFloat) -> Void)?

            /// The Model of this view containing configuration options.
            private var model: Model

            /// The serial queue that runs every configuration, start, and stop step of this view's capture sessions.
            private let sessionQueue = DispatchQueue(label: "dev.modern-swift.calder.barcode-scanner.session")
            /// The serial queue on which the metadata output delivers detected codes, kept apart from the blocking session work.
            private let metadataQueue = DispatchQueue(label: "dev.modern-swift.calder.barcode-scanner.metadata")
            /// The controller that owns the running `AVCaptureSession`, or `nil` when the scanner is stopped.
            private var sessionController: BarcodeScannerSessionController<AVCaptureSession>?
            /// The camera the scanner drives, once it starts.
            private var avDevice: (any BarcodeScannerCaptureDevice)?
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

            /// How long the active scan-region tint stays visible after the latest detection.
            static let activeTintDuration: Duration = .milliseconds(300)

            /// The pending task that restores the inactive scan-region tint.
            private var tintReset: Task<Void, Never>?

            /// Provides the preview rotation angle for the running camera.
            private var rotationCoordinator: AVCaptureDevice.RotationCoordinator?

            /// Observes ``rotationCoordinator`` to rotate the preview when the interface orientation changes.
            private var rotationObservation: NSKeyValueObservation?

            /// Initializes a new `BarcodeScannerView` with the specified model.
            /// - Parameter model: The view model containing configuration for the scanner.
            public init(model: Model) {
                self.model = model
                desiredTorch = model.isTorchOn
                desiredZoom = model.zoomFactor
                cooldown = model.repeatCooldown.map { BarcodeScanCooldown(duration: $0) }
                super.init(frame: .zero)
                #if !os(tvOS)
                    addGestureRecognizer(UIPinchGestureRecognizer(target: self, action: #selector(handlePinch)))
                #endif
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
            ///
            /// A continuous scanner forgets every value it reported, so each is reported again on its next detection.
            func resetLastScan() {
                lastScanValue = ""
                cooldown?.reset()
            }
        }

        // MARK: - Torch

        public extension BarcodeScannerView {
            /// Whether the torch is on, or will be on once the camera starts.
            ///
            /// This is the requested state set by ``setTorch(_:)``, the model, or ``toggleTorch()``. It stays `true` on a
            /// camera without a torch, which ignores it.
            internal(set) var isTorchOn: Bool {
                get { desiredTorch }
                set { desiredTorch = newValue }
            }

            /// Returns `true` if the device has a torch and it is available for use.
            /// - Returns: `true` if torch is available, `false` otherwise.
            func isTorchAvailable() -> Bool {
                guard let device = avDevice, device.hasTorch, device.isTorchAvailable else {
                    return false
                }
                return true
            }

            /// Turns the torch (flashlight) on or off.
            ///
            /// The torch follows `isOn` while the camera runs and again each time the camera starts. A device without a
            /// torch, or with an unavailable one, ignores the request.
            /// - Parameter isOn: `true` to turn the torch on, `false` to turn it off.
            func setTorch(_ isOn: Bool) {
                desiredTorch = isOn
                applyTorch()
            }

            /// Toggles the torch (flashlight) on or off.
            /// If the torch is off, it will be turned on with a default level (0.25).
            /// If the torch is on, it will be turned off.
            func toggleTorch() {
                guard let device = avDevice, device.hasTorch, device.isTorchAvailable else {
                    return
                }
                setTorch(!device.isTorchActive)
            }
        }

        extension BarcodeScannerView {
            /// Makes the camera's torch match ``isTorchOn`` when it can.
            private func applyTorch() {
                guard let device = avDevice, device.hasTorch, device.isTorchAvailable, device.isTorchActive != desiredTorch else {
                    return
                }
                do {
                    try device.setTorch(on: desiredTorch)
                } catch {
                    os_log("%{public}@", log: .default, type: .error, String(describing: error))
                }
            }

            /// Starts driving `device`: applies the requested torch state to it.
            /// - Parameter device: The camera the scanner just started.
            func attach(_ device: any BarcodeScannerCaptureDevice) {
                avDevice = device
                applyTorch()
                applyZoom()
            }
        }

        // MARK: - Zoom

        public extension BarcodeScannerView {
            /// The range of zoom factors the camera supports, or `1 ... 1` before the camera starts.
            var zoomFactorRange: ClosedRange<CGFloat> {
                guard let device = avDevice else {
                    return 1 ... 1
                }
                return device.minAvailableVideoZoomFactor ... max(device.minAvailableVideoZoomFactor, device.maxAvailableVideoZoomFactor)
            }

            /// The camera's zoom factor, clamped to ``zoomFactorRange``.
            ///
            /// The requested factor applies again each time the camera starts.
            var zoomFactor: CGFloat {
                zoomFactorRange.clampedValue(desiredZoom)
            }

            /// Zooms the camera.
            ///
            /// The factor is clamped to ``zoomFactorRange``. Before the camera starts, the request applies once it does.
            /// - Parameter factor: The zoom factor, where `1` is no zoom.
            func setZoomFactor(_ factor: CGFloat) {
                desiredZoom = avDevice == nil ? factor : zoomFactorRange.clampedValue(factor)
                applyZoom()
            }
        }

        extension BarcodeScannerView {
            /// Makes the camera's zoom match ``zoomFactor`` when it can.
            func applyZoom() {
                guard let device = avDevice, device.videoZoomFactor != zoomFactor else {
                    return
                }
                do {
                    try device.setVideoZoomFactor(zoomFactor)
                } catch {
                    os_log("%{public}@", log: .default, type: .error, String(describing: error))
                }
            }

            /// Handles a change of the pinch gesture on the preview.
            /// - Parameters:
            ///   - scale: The gesture's scale relative to where it began.
            ///   - state: The gesture's state.
            func pinch(scale: CGFloat, state: UIGestureRecognizer.State) {
                switch state {
                    case .began:
                        pinchStartZoom = zoomFactor
                    case .changed:
                        guard avDevice != nil, let pinchStartZoom else {
                            return
                        }
                        setZoomFactor(pinchStartZoom * scale)
                        onZoomFactorChange?(zoomFactor)
                    default:
                        pinchStartZoom = nil
                }
            }

            #if !os(tvOS)
                @objc private func handlePinch(_ recognizer: UIPinchGestureRecognizer) {
                    pinch(scale: recognizer.scale, state: recognizer.state)
                }
            #endif
        }

        // MARK: - State

        public extension BarcodeScannerView {
            /// Initializes and starts the barcode scanning session.
            /// This method should be called when the view is ready to capture video.
            ///
            /// The session is configured and started on the view's serial session queue, so this method returns
            /// without waiting for the camera.
            func start() {
                guard sessionController == nil, let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
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
                attach(device)

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
                    // The preview connection exists only once the input is added, so rotate it after configuration.
                    Task { @MainActor in
                        self.configureVideoOrientation()
                        // Configuration resets the camera's zoom, so apply the requested zoom afterwards.
                        self.applyZoom()
                    }
                }

                self.layer.insertSublayer(layer, at: 0)
                self.updateRectOfInterest()
                observeInputFormatChanges()
                observeRotation(of: device, previewLayer: layer)

                controller.startRunning()
            }

            /// Rotates the preview whenever the rotation coordinator for `device` and `previewLayer` reports a new angle.
            /// - Parameters:
            ///   - device: The camera that feeds the preview.
            ///   - previewLayer: The layer that displays the preview.
            private func observeRotation(of device: AVCaptureDevice, previewLayer: AVCaptureVideoPreviewLayer) {
                let coordinator = AVCaptureDevice.RotationCoordinator(device: device, previewLayer: previewLayer)
                rotationCoordinator = coordinator
                rotationObservation = coordinator.observe(\.videoRotationAngleForHorizonLevelPreview) { @Sendable [weak self] _, _ in
                    Task { @MainActor in
                        self?.configureVideoOrientation()
                    }
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
            ///
            /// The session stops on the view's serial session queue after any pending configuration or start,
            /// so this method never blocks the main thread.
            func stop() {
                inputFormatObservation?.cancel()
                inputFormatObservation = nil
                rotationObservation?.invalidate()
                rotationObservation = nil
                rotationCoordinator = nil
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
            /// Rotates the `AVCaptureVideoPreviewLayer` so the preview stays level with the horizon in the current
            /// interface orientation.
            ///
            /// The angle comes from `AVCaptureDevice.RotationCoordinator`, which derives it from the camera and the
            /// preview layer's interface orientation rather than from `UIDevice.orientation`.
            func configureVideoOrientation() {
                guard let rotationCoordinator, let connection = avVideoPreviewLayer?.connection else {
                    return
                }
                let angle = rotationCoordinator.videoRotationAngleForHorizonLevelPreview
                if connection.isVideoRotationAngleSupported(angle) {
                    connection.videoRotationAngle = angle
                }
            }
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
            func handleDetectedCode(_ code: String, type: AVMetadataObject.ObjectType, corners: [CGPoint]) {
                guard !isSuspended else {
                    return
                }

                showActiveTint()

                guard let avVideoPreviewLayer, shouldDeliver(code) else {
                    return
                }
                let points = corners.map { avVideoPreviewLayer.layerPointConverted(fromCaptureDevicePoint: $0) }
                deliverScannedCode(
                    code,
                    type: type,
                    rect: Self.boundingRect(of: points),
                    path: Self.cutOutPath(in: avVideoPreviewLayer.bounds, around: points)
                )
            }

            /// Returns whether to deliver a detection of `code`, and records it when it does.
            ///
            /// A single-result scanner delivers a value once until ``resetLastScan()``. A continuous scanner delivers it again
            /// once its cooldown has passed.
            /// - Parameter code: The detected value.
            /// - Returns: `true` if the detection is new.
            func shouldDeliver(_ code: String) -> Bool {
                if cooldown != nil {
                    return cooldown?.shouldReport(code, at: now()) ?? false
                }
                guard lastScanValue != code else {
                    return false
                }
                lastScanValue = code
                return true
            }

            /// Shows the active scan-region tint, then restores the inactive tint once no code has been detected
            /// for ``activeTintDuration``.
            private func showActiveTint() {
                scanRegionImageView.tintColor = model.scanRegionImageActiveTint
                tintReset?.cancel()
                tintReset = Task { @MainActor [weak self] in
                    try? await Task.sleep(for: Self.activeTintDuration)
                    guard !Task.isCancelled, let self else {
                        return
                    }
                    scanRegionImageView.tintColor = model.scanRegionImageTint
                }
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

            /// Returns a cut-out path for the detected object within the given preview layer.
            ///
            /// The path starts with the full bounds of `layer` and then adds the object's outline. Filled with the even-odd
            /// rule (`usesEvenOddFillRule` or `CAShapeLayerFillRule.evenOdd`), it covers the preview everywhere except the
            /// detected object, which makes it suitable for a dimming overlay that leaves the code visible.
            /// - Parameter layer: The `AVCaptureVideoPreviewLayer` displaying the video.
            /// - Returns: The full-preview path with the object's outline cut out.
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
                let xs = points.map(\.x)
                let ys = points.map(\.y)
                let minX = xs.min() ?? 0.0
                let minY = ys.min() ?? 0.0
                let maxX = xs.max() ?? 0.0
                let maxY = ys.max() ?? 0.0
                return CGRect(x: minX, y: minY, width: maxX - minX, height: maxY - minY)
            }

            /// Returns a path made of `bounds` followed by the closed polygon through `points`.
            ///
            /// Filled with the even-odd rule, the path covers `bounds` except the polygon: an intentional cut-out.
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
             * - Returns: The UPC-A barcode string with the check-digit removed if present and valid. Values that aren't 12 ASCII digits are returned unchanged.
             */
            static func removeUPCCheckDigitIfPresent(_ value: String) -> String {
                if value.count == 11 {
                    return value
                }

                let digits = value.compactMap { $0.isASCII ? $0.wholeNumberValue : nil }
                if digits.count == 12, value.count == 12 {
                    let totalEven = stride(from: 0, to: 12, by: 2).reduce(0) { $0 + digits[$1] } * 3
                    let totalOdd = stride(from: 1, to: 11, by: 2).reduce(0) { $0 + digits[$1] }
                    let checkDigit = (10 - (totalOdd + totalEven) % 10) % 10

                    if checkDigit == digits[11] {
                        return String(value.dropLast())
                    }
                }
                return value
            }
        }

    #endif

#endif
