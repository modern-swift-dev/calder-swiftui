#if canImport(SwiftUI)
    #if os(iOS)
        import AVFoundation
        import CalderUIKit
        import Foundation
        import SwiftUI

        public class BarcodeScannerViewController: UIViewController {

            public let supportedTypes: [AVMetadataObject.ObjectType]?
            public var callback: (String, AVMetadataObject.ObjectType) -> Void = { _, _ in }

            public init(supportedTypes: [AVMetadataObject.ObjectType]? = nil) {
                self.supportedTypes = supportedTypes
                super.init(nibName: nil, bundle: nil)
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
                        barcodeScanner.start()
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
            public func start() {
                barcodeScanner.resetLastScan()
                barcodeScanner.start()
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
            /// Suspends the scanner and processes the scanned code.
            /// - Parameters:
            ///   - code: The string value of the scanned code.
            ///   - type: The `AVMetadataObject.ObjectType` of the scanned code.
            ///   - rect: The `CGRect` in the preview layer that encloses the scanned code.
            ///   - path: The `UIBezierPath` representing the boundaries of the scanned code.
            public nonisolated func onCodeScanned(_ code: String, type: AVMetadataObject.ObjectType, rect: CGRect, path: UIBezierPath) {
                Task { @MainActor [weak self] in
                    self?.barcodeScanner.suspend()
                    self?.handle((code, type))
                }
            }

        }
    #endif

#endif
