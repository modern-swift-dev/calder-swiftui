#if canImport(SwiftUI)
#if os(iOS) && !targetEnvironment(macCatalyst)
import Foundation
import SwiftUI
import UIKit
import Vision
import VisionKit

/// A SwiftUI view that wraps `BarcodeSelectoViewController` to provide barcode scanning functionality using VisionKit's `DataScannerViewController`.
/// This view allows users to scan various barcode symbologies and receive the scanned value and its type.
public struct BarcodeSelector: UIViewControllerRepresentable {

    /// The color used to highlight detected barcodes in the scanner view. Defaults to `.blue`.
    public var highlightColor: Color = .blue

    /// The set of recognized data types that the scanner should look for.
    /// Defaults to `.barcode` with only `.qr` symbology.
    public var recognizedTypes: Set<DataScannerViewController.RecognizedDataType> = [
        .barcode(
            symbologies: [.qr]
        )
    ]

    /// A binding to a tuple containing the scanned barcode string and its symbology.
    /// This value will be `nil` if no code has been scanned or if the scanner is reset.
    @Binding var scannedCode: (String, VNBarcodeSymbology?)?

    /// Initializes a new `BarcodeSelector` instance.
    /// - Parameters:
    ///   - highlightColor: The color to use for highlighting detected barcodes.
    ///   - recognizedTypes: The set of data types to recognize.
    ///   - scannedCode: A binding to store the scanned barcode data.
    public init(
        highlightColor: Color = .blue,
        recognizedTypes: Set<DataScannerViewController.RecognizedDataType> = [.barcode(symbologies: [.qr])],
        scannedCode: Binding<(String, VNBarcodeSymbology?)?>
    ) {
        self.highlightColor = highlightColor
        self.recognizedTypes = recognizedTypes
        self._scannedCode = scannedCode
    }

    /// Creates the `BarcodeSelectoViewController` instance.
    /// - Parameter context: The context for creating the view controller.
    /// - Returns: An initialized `BarcodeSelectoViewController`.
    public func makeUIViewController(context: Context) -> BarcodeSelectoViewController {
        let vc = BarcodeSelectoViewController()
        vc.highlightColor = UIColor(highlightColor)
        vc.scanDelegate = context.coordinator
        return vc
    }

    /// Updates the `BarcodeSelectoViewController` when the SwiftUI view's configuration changes.
    /// - Parameters:
    ///   - vc: The `BarcodeSelectoViewController` to update.
    ///   - context: The context for updating the view controller.
    public func updateUIViewController(_ vc: BarcodeSelectoViewController, context: Context) {
        vc.highlightColor = UIColor(highlightColor)
        vc.scanDelegate = context.coordinator
        // It's a `let` constant in the UIViewController so it cannot be updated
        // dynamically, so we would need to recreate the VC or adjust how
        // recognizedTypes is handled if dynamic updates were needed.
        if scannedCode == nil {
            vc.start()
        } else {
            vc.stop()
        }
    }

    /// Dismantles the `BarcodeSelectoViewController` when the SwiftUI view is removed.
    /// - Parameters:
    ///   - vc: The view controller to dismantle.
    ///   - coordinator: The coordinator associated with the view controller.
    public static func dismantleUIViewController(_ vc: BarcodeSelectoViewController, coordinator: Coordinator) {
        vc.stop()
    }

    /// Creates the coordinator for the `BarcodeSelector`.
    /// - Returns: A new `Coordinator` instance.
    public func makeCoordinator() -> Coordinator {
        Coordinator(scannedCode: $scannedCode)
    }

    /// The coordinator class that conforms to `BarcodeSelectoViewControllerDelegate`
    /// to receive and handle barcode recognition events from the `BarcodeSelectoViewController`.
    public class Coordinator: NSObject, BarcodeSelectoViewControllerDelegate {

        /// A binding to the scanned barcode string and its symbology.
        @Binding var scannedCode: (String, VNBarcodeSymbology?)?

        /// Initializes a new coordinator.
        /// - Parameter scannedCode: A binding to the `scannedCode` property of the parent `BarcodeSelector` view.
        public init(scannedCode: Binding<(String, VNBarcodeSymbology?)?>) {
            self._scannedCode = scannedCode
        }

        /// Called when a barcode is recognized by the `DataScannerViewController`.
        /// - Parameters:
        ///   - dataScanner: The `BarcodeSelectoViewController` that recognized the barcode.
        ///   - result: A tuple containing the recognized barcode string and its symbology.
        public func onBarcodeRecognized(_ dataScanner: BarcodeSelectoViewController, result: (String, VNBarcodeSymbology?)) {
            self.scannedCode = result
            dataScanner.stop()
        }
    }
}
#endif

#endif
