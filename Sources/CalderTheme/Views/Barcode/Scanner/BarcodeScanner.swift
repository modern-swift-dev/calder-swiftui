#if canImport(SwiftUI)
#if os(iOS)
import AVFoundation
import CalderUIKit
import SwiftUI

/// A SwiftUI view that provides barcode and QR code scanning functionality.
/// This view wraps `BarcodeScannerViewController` using `UIViewControllerRepresentable`.
public struct BarcodeScanner: UIViewControllerRepresentable {

    public struct ScanResult: Equatable, Hashable {
        public let payload: String
        public let type: AVMetadataObject.ObjectType

        public init(payload: String, type: AVMetadataObject.ObjectType) {
            self.payload = payload
            self.type = type
        }
    }

    /// Represents the different states of the barcode scanner.
    public enum State {
        /// Initial state - scanner is not active.
        case pristine
        /// Scanner is actively scanning for codes.
        case scanning
        /// Scanner is temporarily suspended but not stopped.
        case suspended
        /// Scanner has finished and is no longer active.
        case finished
    }

    public typealias UIViewControllerType = BarcodeScannerViewController

    /// A binding to the scan result containing the scanned string and its metadata object type.
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
        viewController.callback = context.coordinator.handleScanResult
        return viewController
    }

    /// Updates the underlying `BarcodeScannerViewController` when the SwiftUI view's state changes.
    /// - Parameters:
    ///   - uiViewController: The `BarcodeScannerViewController` to update.
    ///   - context: The representable context.
    public func updateUIViewController(_ uiViewController: BarcodeScannerViewController, context: Context) {
        // State management is handled by the view controller's lifecycle methods
        // Additional state updates can be added here if needed
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
