#if canImport(SwiftUI)
    #if os(iOS)
        import AVFoundation
        import CalderUIKit
        import SwiftUI

        /// A SwiftUI view that provides barcode and QR code scanning functionality.
        /// This view wraps `BarcodeScannerViewController` using `UIViewControllerRepresentable`.
        ///
        /// > Important: The host app must declare `NSCameraUsageDescription` in its `Info.plist`, with a message that
        /// > explains why the app uses the camera. Without it, the system terminates the app the first time the scanner
        /// > accesses the camera.
        public struct BarcodeScanner: UIViewControllerRepresentable {

            /// A code detected by the scanner.
            ///
            /// The scanner writes a result to its `result` binding once per scan; set the binding back to
            /// `nil` to scan again.
            public struct ScanResult: Equatable, Hashable, Sendable {
                /// The decoded string value of the code.
                public let payload: String
                /// The symbology of the code, such as `.qr` or `.ean13`.
                public let type: AVMetadataObject.ObjectType

                /// Creates a scan result.
                /// - Parameters:
                ///   - payload: The decoded string value of the code.
                ///   - type: The symbology of the code.
                public init(payload: String, type: AVMetadataObject.ObjectType) {
                    self.payload = payload
                    self.type = type
                }
            }

            /// Represents the different states of the barcode scanner.
            ///
            /// Changing the state passed to ``BarcodeScanner`` takes effect on the next SwiftUI update.
            public enum State {
                /// Initial state. The scanner starts scanning when it appears, as with ``scanning``.
                case pristine
                /// Scanner is actively scanning for codes. Switching to this state resumes detection and restarts a finished camera.
                case scanning
                /// Scanner is temporarily suspended but not stopped: no codes are reported, and a running camera keeps running.
                case suspended
                /// Scanner has finished and is no longer active: no codes are reported and the camera stops.
                case finished
            }

            public typealias UIViewControllerType = BarcodeScannerViewController

            /// A binding to the scan result containing the scanned string and its metadata object type.
            ///
            /// The scanner pauses after it writes a result. Set the binding back to `nil` to scan the next code.
            @Binding public var result: ScanResult?
            /// The current state of the scanner.
            public var state: State
            /// Optional array of supported barcode/QR code types. If nil, all available types are supported.
            public var supportedTypes: [AVMetadataObject.ObjectType]?
            /// Whether the torch is on while the camera runs.
            @Binding public var torch: Bool
            /// The camera's zoom factor, which pinching the preview changes.
            @Binding public var zoomFactor: CGFloat
            /// Receives every code a continuous scanner reads, or `nil` when the scanner writes to ``result``.
            private let onScan: (@MainActor (ScanResult) -> Void)?
            /// How long a continuous scanner suppresses a repeat of the same value, or `nil` when it isn't continuous.
            private let cooldown: Duration?
            /// Whether the scanner plays a haptic each time it reads a code.
            private let hapticFeedback: Bool
            /// Whether the scanner posts a VoiceOver announcement of each code it reads.
            private let announcesScans: Bool

            /// Initializes a new `BarcodeScanner` instance.
            /// - Parameters:
            ///   - result: A binding to store the scan result.
            ///   - state: The initial state of the scanner.
            ///   - supportedTypes: Optional array of supported code types. Defaults to nil (all types).
            ///   - torch: A binding that turns the torch on or off while the camera runs. Defaults to a torch that stays off.
            ///     A device without a torch ignores it; check ``BarcodeScannerViewController/isTorchAvailable`` to hide a torch button.
            ///   - zoomFactor: A binding to the camera's zoom factor, where `1` is no zoom, which is the default. Pinching the
            ///     preview updates it. The camera clamps it to the range it supports, and the pinch writes the clamped factor.
            ///   - hapticFeedback: Whether the scanner plays a haptic each time it reads a code, where the device has a haptic
            ///     engine. Defaults to `true`.
            ///   - announcesScans: Whether the scanner posts a VoiceOver announcement of the code each time it reads one.
            ///     Defaults to `true`.
            public init(
                result: Binding<ScanResult?>,
                state: State,
                supportedTypes: [AVMetadataObject.ObjectType]? = nil,
                torch: Binding<Bool> = .constant(false),
                zoomFactor: Binding<CGFloat> = .constant(1),
                hapticFeedback: Bool = true,
                announcesScans: Bool = true
            ) {
                self._result = result
                self.state = state
                self.supportedTypes = supportedTypes
                self._torch = torch
                self._zoomFactor = zoomFactor
                onScan = nil
                cooldown = nil
                self.hapticFeedback = hapticFeedback
                self.announcesScans = announcesScans
            }

            /// Initializes a continuous `BarcodeScanner` that reports every code it reads.
            ///
            /// The scanner keeps scanning after each code and calls `onScan` for each one, so it has no result to reset. It
            /// suppresses a repeat of the same value within `cooldown`, so the same item can be scanned again after the cooldown
            /// but a code held in front of the camera isn't reported over and over. Different codes are always reported.
            /// - Parameters:
            ///   - state: The initial state of the scanner.
            ///   - supportedTypes: Optional array of supported code types. Defaults to nil (all types).
            ///   - cooldown: How long to suppress a repeat of the same value, counted from when it was last reported. Defaults to
            ///     2 seconds.
            ///   - torch: A binding that turns the torch on or off while the camera runs. Defaults to a torch that stays off.
            ///   - zoomFactor: A binding to the camera's zoom factor, where `1` is no zoom, which is the default.
            ///   - hapticFeedback: Whether the scanner plays a haptic each time it reads a code, where the device has a haptic
            ///     engine. Defaults to `true`.
            ///   - announcesScans: Whether the scanner posts a VoiceOver announcement of the code each time it reads one.
            ///     Defaults to `true`.
            ///   - onScan: Called on the main actor with each code the scanner reads.
            public init(
                state: State,
                supportedTypes: [AVMetadataObject.ObjectType]? = nil,
                cooldown: Duration = .seconds(2),
                torch: Binding<Bool> = .constant(false),
                zoomFactor: Binding<CGFloat> = .constant(1),
                hapticFeedback: Bool = true,
                announcesScans: Bool = true,
                onScan: @escaping @MainActor (ScanResult) -> Void
            ) {
                self._result = .constant(nil)
                self.state = state
                self.supportedTypes = supportedTypes
                self._torch = torch
                self._zoomFactor = zoomFactor
                self.onScan = onScan
                self.cooldown = cooldown
                self.hapticFeedback = hapticFeedback
                self.announcesScans = announcesScans
            }

            /// Creates the underlying `BarcodeScannerViewController` instance.
            /// - Parameter context: The representable context containing the coordinator.
            /// - Returns: A configured `BarcodeScannerViewController` instance.
            public func makeUIViewController(context: Context) -> BarcodeScannerViewController {
                var model = BarcodeScannerViewController.defaultScannerModel
                model.isTorchOn = torch
                model.zoomFactor = zoomFactor
                model.repeatCooldown = cooldown
                model.providesHapticFeedback = hapticFeedback
                model.announcesScannedCode = announcesScans
                let viewController = BarcodeScannerViewController(supportedTypes: supportedTypes, scannerModel: model)
                viewController.themeDefinition = context.environment.themeDefinition
                viewController.callback = context.coordinator.handleScanResult
                viewController.onZoomFactorChange = { [coordinator = context.coordinator] factor in
                    coordinator.zoomFactor.wrappedValue = factor
                }
                return viewController
            }

            /// Updates the underlying `BarcodeScannerViewController` when the SwiftUI view's state changes.
            ///
            /// A changed ``state`` takes effect immediately: `.scanning` resumes detection, `.suspended` pauses it,
            /// and `.finished` stops the camera. Resetting ``result`` to `nil` after a scan resumes detection
            /// unless the state is `.suspended` or `.finished`. The coordinator writes scan results to the current
            /// ``result`` binding.
            /// - Parameters:
            ///   - uiViewController: The `BarcodeScannerViewController` to update.
            ///   - context: The representable context.
            public func updateUIViewController(_ uiViewController: BarcodeScannerViewController, context: Context) {
                context.coordinator.result = $result
                uiViewController.themeDefinition = context.environment.themeDefinition
                uiViewController.apply(state)
                uiViewController.isTorchOn = torch
                context.coordinator.zoomFactor = $zoomFactor
                context.coordinator.onScan = onScan
                uiViewController.zoomFactor = zoomFactor
                if result == nil {
                    uiViewController.resultDidReset()
                }
            }

            /// Creates the coordinator that acts as the bridge between SwiftUI and UIKit.
            /// - Returns: A new `Coordinator` instance.
            public func makeCoordinator() -> Coordinator {
                let coordinator = Coordinator(result: $result)
                coordinator.zoomFactor = $zoomFactor
                coordinator.onScan = onScan
                return coordinator
            }

            /// The coordinator class that handles scan results from the view controller.
            public class Coordinator: NSObject {

                /// A binding to update the scan result in the parent SwiftUI view. The scanner refreshes it on every update.
                var result: Binding<ScanResult?>

                /// A binding to the camera's zoom factor, which a pinch writes to. The scanner refreshes it on every update.
                var zoomFactor: Binding<CGFloat> = .constant(1)

                /// Receives every code when the scanner is continuous. The scanner refreshes it on every update.
                var onScan: (@MainActor (ScanResult) -> Void)?

                /// Initializes a new coordinator.
                /// - Parameter result: A binding to the scan result.
                public init(result: Binding<ScanResult?>) {
                    self.result = result
                }

                /// Handles the scan result from the barcode scanner view controller.
                /// - Parameters:
                ///   - code: The scanned code as a string.
                ///   - type: The type of the scanned code.
                func handleScanResult(_ code: String, _ type: AVMetadataObject.ObjectType) {
                    let scanned = ScanResult(payload: code, type: type)
                    if let onScan {
                        // The view controller reports codes on the main actor.
                        MainActor.assumeIsolated { onScan(scanned) }
                    } else {
                        result.wrappedValue = scanned
                    }
                }
            }

            /// Cleans up the `BarcodeScannerViewController` when the SwiftUI view is deallocated.
            /// - Parameters:
            ///   - uiViewController: The `BarcodeScannerViewController` to clean up.
            ///   - coordinator: The coordinator associated with the view controller.
            public static func dismantleUIViewController(_ uiViewController: BarcodeScannerViewController, coordinator: Coordinator) {
                uiViewController.stop() // Ensure the session is stopped when the SwiftUI view is removed.
            }
        }

    #endif
#endif
