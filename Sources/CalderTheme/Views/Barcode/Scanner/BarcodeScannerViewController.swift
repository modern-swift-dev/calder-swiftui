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
    private lazy var barcodeScanner: BarcodeScannerView = {
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

    /// Called just before the view appears.
    /// Resets the scanner and starts/resumes the scanning process.
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        start()
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
}

// MARK: QR Code Handling
extension BarcodeScannerViewController {

    /// Handles the scanned value from the barcode scanner.
    /// - Parameter value: A tuple containing the scanned code string and its object type.
    private func handle(_ value: (String, AVMetadataObject.ObjectType)?) {
        guard let value else {
            barcodeScanner.resetLastScan()
            barcodeScanner.resume()
            return
        }

        callback(value.0, value.1)
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
