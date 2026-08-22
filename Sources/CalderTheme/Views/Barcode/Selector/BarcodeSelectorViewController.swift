#if canImport(SwiftUI)
#if os(iOS) && !targetEnvironment(macCatalyst)
import CalderUIKit
import Combine
import os
import Vision
import VisionKit

/// A protocol that defines the delegate methods for `BarcodeSelectoViewController`.
@MainActor public protocol BarcodeSelectoViewControllerDelegate: AnyObject {
    /// Called when a barcode is successfully recognized by the scanner.
    /// - Parameters:
    ///   - dataScanner: The `BarcodeSelectoViewController` instance that recognized the barcode.
    ///   - result: A tuple containing the recognized barcode string and its symbology.
    func onBarcodeRecognized(_ dataScanner: BarcodeSelectoViewController, result: (String, VNBarcodeSymbology?))
}

/// A `UIViewController` that integrates `DataScannerViewController` from VisionKit to provide barcode scanning functionality.
/// It allows for customization of recognized data types and visual highlighting of detected items.
public class BarcodeSelectoViewController: UIViewController {

    /// The color used to highlight detected barcodes. Defaults to `.systemBlue`.
    public var highlightColor: UIColor = .systemBlue

    /// The delegate that receives barcode recognition events.
    public weak var scanDelegate: (any BarcodeSelectoViewControllerDelegate)?

    /// Initializes a new `BarcodeSelectoViewController` instance.
    public init() {
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .fullScreen
    }

    /// Initializes a new `BarcodeSelectoViewController` instance from a coder (unavailable).
    required init?(coder: NSCoder) {
        nil
    }

    /// A boolean indicating whether the `DataScannerViewController` is supported on the current device.
    static var isSupported: Bool {
        DataScannerViewController.isSupported
    }

    /// A boolean indicating whether the `DataScannerViewController` is available for use (e.g., camera access granted).
    static var isAvailable: Bool {
        DataScannerViewController.isAvailable
    }

    /// A dictionary to keep track of highlight views by their `RecognizedItem` UUID.
    private var highlightViewByUuid: [UUID: UIView] = [:]

    /// The underlying `DataScannerViewController` instance used for scanning.
    private lazy var scanner: DataScannerViewController = {
        let vc = DataScannerViewController(
            recognizedDataTypes: recognizedTypes,
            qualityLevel: .balanced,
            recognizesMultipleItems: true,
            isHighFrameRateTrackingEnabled: false,
            isPinchToZoomEnabled: true,
            isGuidanceEnabled: true,
            isHighlightingEnabled: false
        )
        vc.delegate = self
        return vc
    }()

    /// The set of recognized data types and symbologies the scanner should look for.
    /// Defaults to `.barcode` with only `.qr` symbology.
    public var recognizedTypes: Set<DataScannerViewController.RecognizedDataType> = [
        .barcode(
            symbologies: [.qr]
        )
    ]

    /// Called after the controller's view is loaded into memory.
    /// Configures the layout of the scanner view within the controller's view.
    override public func viewDidLoad() {
        super.viewDidLoad()
        addChildViewController(scanner, toContainerView: view)
        scanner.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate {
            scanner.view.pinned(to: view)
        }
    }

    /// Called just before the view appears. Starts the scanning process.
    /// - Parameter animated: If `true`, the view is being added to the window using an animation.
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        start()
    }

    /// Called just before the view disappears. Stops the scanning process.
    /// - Parameter animated: If `true`, the view is being removed from the window using an animation.
    override public func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stop()
    }

    /// Stops the barcode scanning session.
    public func stop() {
        scanner.stopScanning()
    }

    /// Starts the barcode scanning session.
    public func start() {
        do {
            try scanner.startScanning()
        } catch {
            os_log("%{public}@", log: .default, type: .error, String(describing: error))
        }
    }
}

// MARK: - DataScannerViewControllerDelegate
extension BarcodeSelectoViewController: DataScannerViewControllerDelegate {
    /// Called when the user taps on a recognized item in the scanner's overlay.
    /// If the tapped item is a barcode, its value is passed to the delegate.
    /// - Parameters:
    ///   - dataScanner: The data scanner view controller.
    ///   - item: The recognized item that was tapped.
    public func dataScanner(_ dataScanner: DataScannerViewController, didTapOn item: RecognizedItem) {
        switch item {
            case let .barcode(value):
                if let barcode = value.payloadStringValue {
                    scanDelegate?.onBarcodeRecognized(self, result: (barcode, value.observation.symbology))
                    dataScanner.stopScanning()
                }
            default:
                break
        }
    }

    /// Called when new items are added to the list of recognized items.
    /// Creates or updates highlight views for the newly added items.
    /// - Parameters:
    ///   - dataScanner: The data scanner view controller.
    ///   - addedItems: An array of recognized items that were newly added.
    ///   - allItems: An array of all currently recognized items.
    public func dataScanner(_ dataScanner: DataScannerViewController, didAdd addedItems: [RecognizedItem], allItems: [RecognizedItem]) {
        for item in addedItems {
            createOrUpdateHighlightView(for: item)
        }
    }

    /// Called when existing recognized items are updated (e.g., their bounds change).
    /// Updates the highlight views for the modified items.
    /// - Parameters:
    ///   - dataScanner: The data scanner view controller.
    ///   - updatedItems: An array of recognized items that were updated.
    ///   - allItems: An array of all currently recognized items.
    public func dataScanner(_ dataScanner: DataScannerViewController, didUpdate updatedItems: [RecognizedItem], allItems: [RecognizedItem]) {
        for item in updatedItems {
            createOrUpdateHighlightView(for: item)
        }
    }

    /// Called when recognized items are removed from the list.
    /// Removes the corresponding highlight views.
    /// - Parameters:
    ///   - dataScanner: The data scanner view controller.
    ///   - removedItems: An array of recognized items that were removed.
    ///   - allItems: An array of all currently recognized items.
    public func dataScanner(_ dataScanner: DataScannerViewController, didRemove removedItems: [RecognizedItem], allItems: [RecognizedItem]) {
        for item in removedItems {
            if let view = highlightViewByUuid.removeValue(forKey: item.id) {
                view.removeFromSuperview()
            }
        }
    }

    /// Creates a new highlight view for a recognized item or updates an existing one.
    /// - Parameter item: The `RecognizedItem` for which to create or update the highlight.
    private func createOrUpdateHighlightView(for item: RecognizedItem) {
        if let view = highlightViewByUuid[item.id] {
            view.frame = item.bounds.cgRect(padding: .small)
            highlightViewByUuid[item.id] = view
        } else {
            let highlightView = UIView()
            highlightView.layer.borderColor = highlightColor.cgColor
            highlightView.layer.borderWidth = 2.0
            highlightView.backgroundColor = highlightColor.withAlphaComponent(0.15)
            highlightView.frame = item.bounds.cgRect(padding: .small)
            scanner.overlayContainerView.addSubview(highlightView)
            highlightViewByUuid[item.id] = highlightView
        }
    }
}

// MARK: - RecognizedItem.Bounds Extension
extension RecognizedItem.Bounds {
    /// Calculates a `CGRect` from the recognized item's bounds with optional padding.
    /// - Parameter padding: The amount of padding to apply around the bounds. Defaults to `0`.
    /// - Returns: A `CGRect` representing the item's bounds with the specified padding.
    func cgRect(padding: CGFloat = 0) -> CGRect {
        // Calculate the origin (top-left corner)
        var origin = topLeft
        origin.x -= (padding / 2.0)
        origin.y -= (padding / 2.0)

        // Calculate the width and height
        let width = topRight.x - topLeft.x + padding
        let height = bottomLeft.y - topLeft.y + padding

        // Create and return the CGRect
        return CGRect(x: origin.x, y: origin.y, width: width, height: height)
    }
}
#endif

#endif
