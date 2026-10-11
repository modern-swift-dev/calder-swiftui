#if canImport(SwiftUI) || canImport(UIKit) || canImport(AppKit)
    #if os(iOS)
        import AVFoundation
        @testable import CalderTheme
        import Testing
        import UIKit

        @Suite(.serialized)
        @MainActor struct BarcodeScannerViewControllerTests {

            @Test func `only the first of several codes in frame is delivered`() {
                let controller = BarcodeScannerViewController()
                var delivered: [String] = []
                controller.callback = { code, _ in delivered.append(code) }

                controller.barcodeScanner.deliverScannedCode("first", type: .qr, rect: .zero, path: UIBezierPath())
                controller.barcodeScanner.deliverScannedCode("second", type: .qr, rect: .zero, path: UIBezierPath())

                #expect(delivered == ["first"])
                #expect(controller.barcodeScanner.isSuspended)
            }
        }
    #endif

#endif
