#if canImport(SwiftUI)
    #if os(iOS)
        import AVFoundation
        import CalderUIKit
        import Foundation
        import SwiftUI

        public class BarcodeScannerViewController: UIViewController {

            public let supportedTypes: [AVMetadataObject.ObjectType]?
            public var callback: (String, AVMetadataObject.ObjectType) -> Void = { _, _ in }

            /// The theme used by the message shown when the scanner cannot use the camera.
            public var themeDefinition = ThemeDefinition() {
                didSet {
                    updateUnavailableMessage()
                }
            }

            /// The camera-permission checks performed before the camera starts.
            var cameraAccess = BarcodeScannerCameraAccess.live

            /// Why the scanner currently shows a message instead of the camera feed, if it does.
            private(set) var unavailableReason: BarcodeScannerUnavailableView.Reason?

            /// The hosting controller that displays the message for ``unavailableReason``.
            private var unavailableHost: UIHostingController<AnyView>?

            /// The pending camera-permission prompt, if any.
            private var accessRequest: Task<Void, Never>?

            /// Creates a scanner view controller.
            ///
            /// The scanner asks for camera access when it first appears. When access is denied or restricted, it shows a
            /// message with a button that opens Settings, and starts scanning when the app becomes active with access granted.
            /// - Parameter supportedTypes: The metadata object types to detect, or `nil` for every available type.
            public init(supportedTypes: [AVMetadataObject.ObjectType]? = nil) {
                self.supportedTypes = supportedTypes
                super.init(nibName: nil, bundle: nil)
                NotificationCenter.default.addObserver(
                    self,
                    selector: #selector(applicationDidBecomeActive),
                    name: UIApplication.didBecomeActiveNotification,
                    object: nil
                )
            }

            public required init?(coder: NSCoder) {
                nil
            }

            /// The barcode scanner view responsible for capturing QR codes.
            lazy var barcodeScanner: BarcodeScannerView = {
                let view = BarcodeScannerView(model: .init(backgroundColor: UIColor.black, scanRegionWidthRatio: 0.4))
                view.translatesAutoresizingMaskIntoConstraints = false
                view.delegate = self
                return view
            }()

            /// Called after the controller's view is loaded into memory.
            /// Configures the layout of subviews and sets up gesture recognizers and navigation items.
            override public func viewDidLoad() {
                super.viewDidLoad()
                view.addSubview(barcodeScanner)
                NSLayoutConstraint.activate {
                    barcodeScanner.pinned(to: view)
                }
            }

            /// The scanner state most recently applied with ``apply(_:)``.
            private(set) var state: BarcodeScanner.State = .pristine

            /// Whether a delivered code is waiting for ``resultDidReset()`` before detection resumes.
            private var isAwaitingResultReset = false

            /// Called just before the view appears.
            /// Resets the scanner and starts/resumes the scanning process, unless the applied state is
            /// `.suspended` (the camera starts but detection stays paused) or `.finished` (nothing starts).
            override public func viewWillAppear(_ animated: Bool) {
                super.viewWillAppear(animated)
                switch state {
                    case .pristine,
                         .scanning:
                        start()
                    case .suspended:
                        startCameraIfPermitted()
                    case .finished:
                        break
                }
            }

            /// Called just before the view disappears.
            /// Suspends the scanning process.
            override public func viewWillDisappear(_ animated: Bool) {
                super.viewWillDisappear(animated)
                barcodeScanner.suspend()
            }

            /// Start scanning
            ///
            /// The camera starts once camera access is granted; the user is prompted when access is undetermined.
            public func start() {
                barcodeScanner.resetLastScan()
                startCameraIfPermitted()
                barcodeScanner.resume()
            }

            /// Stop scanning
            public func stop() {
                barcodeScanner.stop()
            }

            /// Applies a scanner state when it differs from the current one.
            ///
            /// `.scanning` starts the camera if needed and resumes detection, `.suspended` pauses detection while
            /// the camera keeps running, and `.finished` pauses detection and stops the camera. `.pristine` changes nothing.
            /// - Parameter newState: The state to apply.
            func apply(_ newState: BarcodeScanner.State) {
                guard newState != state else {
                    return
                }
                state = newState

                switch newState {
                    case .pristine:
                        break
                    case .scanning:
                        start()
                    case .suspended:
                        barcodeScanner.suspend()
                    case .finished:
                        barcodeScanner.suspend()
                        stop()
                }
            }
        }

        // MARK: Camera Access

        extension BarcodeScannerViewController {
            /// Starts the camera when access is granted, prompts when it is undetermined, and otherwise shows the
            /// permission-denied message.
            private func startCameraIfPermitted() {
                switch cameraAccess.authorizationStatus() {
                    case .authorized:
                        showUnavailableMessage(nil)
                        barcodeScanner.start()
                    case .notDetermined:
                        requestCameraAccess()
                    case .denied,
                         .restricted:
                        showUnavailableMessage(.permissionDenied)
                    @unknown default:
                        showUnavailableMessage(.permissionDenied)
                }
            }

            /// Prompts for camera access once, then starts the camera if the view is still on screen, or shows the
            /// permission-denied message.
            private func requestCameraAccess() {
                guard accessRequest == nil else {
                    return
                }
                let requestAccess = cameraAccess.requestAccess
                accessRequest = Task { [weak self] in
                    let isGranted = await requestAccess()
                    guard let self else {
                        return
                    }
                    accessRequest = nil
                    guard state != .finished else {
                        return
                    }
                    if isGranted {
                        showUnavailableMessage(nil)
                        // If the view left the screen during the prompt, the camera starts when it next appears.
                        if viewIfLoaded?.window != nil {
                            barcodeScanner.start()
                        }
                    } else {
                        showUnavailableMessage(.permissionDenied)
                    }
                }
            }

            /// Retries the camera when the app becomes active while the permission-denied message is visible,
            /// so access granted in Settings resumes scanning.
            @objc private func applicationDidBecomeActive() {
                guard unavailableReason == .permissionDenied, viewIfLoaded?.window != nil, state != .finished else {
                    return
                }
                startCameraIfPermitted()
            }

            /// Shows the message for `reason` over the camera feed, or removes it when `reason` is `nil`.
            /// - Parameter reason: Why the scanner cannot scan, or `nil` when it can.
            private func showUnavailableMessage(_ reason: BarcodeScannerUnavailableView.Reason?) {
                guard reason != unavailableReason else {
                    return
                }
                unavailableReason = reason
                if reason != nil {
                    barcodeScanner.stop()
                }
                updateUnavailableMessage()
            }

            /// Adds, updates, or removes the hosted message so it matches ``unavailableReason`` and ``themeDefinition``.
            private func updateUnavailableMessage() {
                guard let unavailableReason else {
                    unavailableHost?.removeViewAndControllerFromParentViewController()
                    unavailableHost = nil
                    return
                }

                let message = AnyView(
                    BarcodeScannerUnavailableView(reason: unavailableReason) { [weak self] in
                        self?.openSettings()
                    }
                    .environment(\.themeDefinition, themeDefinition)
                )
                if let unavailableHost {
                    unavailableHost.rootView = message
                    return
                }

                let host = UIHostingController(rootView: message)
                addChildViewController(host, toContainerView: view)
                host.view.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate {
                    host.view.pinned(to: view)
                }
                unavailableHost = host
            }

            /// Opens the app's page in the Settings app.
            private func openSettings() {
                guard let url = URL(string: UIApplication.openSettingsURLString) else {
                    return
                }
                view.window?.windowScene?.open(url, options: nil)
            }
        }

        // MARK: QR Code Handling
        extension BarcodeScannerViewController {

            /// Handles the scanned value from the barcode scanner.
            /// - Parameter value: A tuple containing the scanned code string and its object type.
            private func handle(_ value: (String, AVMetadataObject.ObjectType)) {
                isAwaitingResultReset = true
                callback(value.0, value.1)
            }

            /// Resumes detection after the caller clears a delivered result.
            ///
            /// Does nothing unless a code was delivered since the last reset, or when the applied state is
            /// `.suspended` or `.finished`. The same code can be scanned again after a reset.
            func resultDidReset() {
                guard isAwaitingResultReset else {
                    return
                }
                isAwaitingResultReset = false

                guard state == .pristine || state == .scanning else {
                    return
                }
                barcodeScanner.resetLastScan()
                barcodeScanner.resume()
            }
        }

        // MARK: BarcodeScannerViewDelegate
        extension BarcodeScannerViewController: BarcodeScannerViewDelegate {
            /// Specifies the metadata object types supported by the scanner.
            /// - Parameter output: The `AVCaptureMetadataOutput` instance.
            /// - Returns: An array containing `.qr` (QR code) as the only supported type.
            public nonisolated func supportedObjectTypes(_ output: AVCaptureMetadataOutput) -> [AVMetadataObject.ObjectType] {
                supportedTypes ?? output.availableMetadataObjectTypes
            }

            /// Called when a QR code is successfully scanned.
            /// Suspends the scanner before processing the scanned code, so only one code is delivered per scan.
            /// - Parameters:
            ///   - code: The string value of the scanned code.
            ///   - type: The `AVMetadataObject.ObjectType` of the scanned code.
            ///   - rect: The `CGRect` in the preview layer that encloses the scanned code.
            ///   - path: The `UIBezierPath` representing the boundaries of the scanned code.
            public func onCodeScanned(_ code: String, type: AVMetadataObject.ObjectType, rect: CGRect, path: UIBezierPath) {
                barcodeScanner.suspend()
                handle((code, type))
            }

        }
    #endif

#endif
