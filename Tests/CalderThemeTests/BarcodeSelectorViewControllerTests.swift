#if canImport(SwiftUI) || canImport(UIKit) || canImport(AppKit)
    #if os(iOS) && !targetEnvironment(macCatalyst)
        @testable import CalderTheme
        import SwiftUI
        import Testing
        import UIKit
        import Vision
        import VisionKit

        @Suite(.serialized)
        @MainActor struct BarcodeSelectorViewControllerTests {

            @Test func `init sets defaults`() {
                let controller = BarcodeSelectorViewController()

                #expect(controller.modalPresentationStyle == .fullScreen)
                #expect(controller.highlightColor == .systemBlue)
                #expect(controller.scanDelegate == nil)
                #expect(controller.recognizedTypes == [.barcode(symbologies: [.qr])])
            }

            @Test func `availability flags can be read`() {
                _ = BarcodeSelectorViewController.isSupported
                _ = BarcodeSelectorViewController.isAvailable
            }

            @Test func `unsupported device shows the unsupported message instead of the scanner`() {
                let controller = BarcodeSelectorViewController()
                controller.isScannerSupported = false

                controller.loadViewIfNeeded()

                #expect(controller.unavailableReason == .unsupported)
                #expect(!controller.children.contains { $0 is DataScannerViewController })
            }

            @Test func `selector passes recognized types to its view controller`() throws {
                let types: Set<DataScannerViewController.RecognizedDataType> = [.barcode(symbologies: [.ean13])]
                let selector = BarcodeSelector(recognizedTypes: types, scannedCode: .constant(nil))

                let controller = try #require(hostedController(for: selector))

                #expect(barcodeSymbologies(in: controller.recognizedTypes) == [.ean13])
            }

            @available(*, deprecated)
            @Test func `deprecated BarcodeSelecto names alias the selector controller and delegate`() {
                final class Delegate: BarcodeSelectoViewControllerDelegate {
                    var recognized: [String] = []

                    func onBarcodeRecognized(_ dataScanner: BarcodeSelectoViewController, result: (String, VNBarcodeSymbology?)) {
                        recognized.append(result.0)
                    }
                }

                let delegate = Delegate()
                let controller: BarcodeSelectorViewController = BarcodeSelectoViewController()
                controller.scanDelegate = delegate

                controller.scanDelegate?.onBarcodeRecognized(controller, result: ("123", .qr))

                #expect(delegate.recognized == ["123"])
            }

            /// `RecognizedDataType` equality ignores barcode symbologies, so read them through reflection.
            private func barcodeSymbologies(in types: Set<DataScannerViewController.RecognizedDataType>) -> Set<VNBarcodeSymbology> {
                Set(types.flatMap { type in
                    Mirror(reflecting: type).children.first { $0.label == "barcodeSymbologies" }?.value as? [VNBarcodeSymbology] ?? []
                })
            }

            private func hostedController(for selector: BarcodeSelector) -> BarcodeSelectorViewController? {
                let host = UIHostingController(rootView: selector)
                let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 320, height: 480))
                window.rootViewController = host
                window.makeKeyAndVisible()
                host.view.layoutIfNeeded()
                defer {
                    window.isHidden = true
                }
                return host.children.compactMap { $0 as? BarcodeSelectorViewController }.first
            }
        }
    #endif

#endif
