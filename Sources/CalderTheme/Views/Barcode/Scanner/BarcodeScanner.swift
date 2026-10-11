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

            /// Initializes a new `BarcodeScanner` instance.
            /// - Parameters:
            ///   - result: A binding to store the scan result.
            ///   - state: The initial state of the scanner.
            ///   - supportedTypes: Optional array of supported code types. Defaults to nil (all types).
            public init(
                result: Binding<ScanResult?>,
                state: State,
                supportedTypes: [AVMetadataObject.ObjectType]? = nil
            ) {
                self._result = result
                self.state = state
                self.supportedTypes = supportedTypes
            }

            /// Creates the underlying `BarcodeScannerViewController` instance.
            /// - Parameter context: The representable context containing the coordinator.
            /// - Returns: A configured `BarcodeScannerViewController` instance.
            public func makeUIViewController(context: Context) -> BarcodeScannerViewController {
                let viewController = BarcodeScannerViewController(supportedTypes: supportedTypes)
                viewController.themeDefinition = context.environment.themeDefinition
                viewController.callback = context.coordinator.handleScanResult
                return viewController
            }

            /// Updates the underlying `BarcodeScannerViewController` when the SwiftUI view's state changes.
            ///
            /// A changed ``state`` takes effect immediately: `.scanning` resumes detection, `.suspended` pauses it,
            /// and `.finished` stops the camera. Resetting ``result`` to `nil` after a scan resumes detection
            /// unless the state is `.suspended` or `.finished`.
            /// - Parameters:
            ///   - uiViewController: The `BarcodeScannerViewController` to update.
            ///   - context: The representable context.
            public func updateUIViewController(_ uiViewController: BarcodeScannerViewController, context: Context) {
                uiViewController.themeDefinition = context.environment.themeDefinition
                uiViewController.apply(state)
                if result == nil {
                    uiViewController.resultDidReset()
                }
            }

            /// Creates the coordinator that acts as the bridge between SwiftUI and UIKit.
            /// - Returns: A new `Coordinator` instance.
            public func makeCoordinator() -> Coordinator {
                Coordinator(result: $result)
            }

            /// The coordinator class that handles scan results from the view controller.
            public class Coordinator: NSObject {

                /// A binding to update the scan result in the parent SwiftUI view.
                @Binding var result: ScanResult?

                /// Initializes a new coordinator.
                /// - Parameter result: A binding to the scan result.
                public init(result: Binding<ScanResult?>) {
                    self._result = result
                }

                /// Handles the scan result from the barcode scanner view controller.
                /// - Parameters:
                ///   - code: The scanned code as a string.
                ///   - type: The type of the scanned code.
                func handleScanResult(_ code: String, _ type: AVMetadataObject.ObjectType) {
                    result = .init(payload: code, type: type)
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
