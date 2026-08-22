#if canImport(SwiftUI) || canImport(UIKit) || canImport(AppKit)
#if os(iOS) && !targetEnvironment(macCatalyst)
@testable import CalderTheme
import Testing
import UIKit
import Vision
import VisionKit

@Suite(.serialized)
@MainActor struct BarcodeSelectorViewControllerTests {

    @Test func `init sets defaults`() {
        let controller = BarcodeSelectoViewController()

        #expect(controller.modalPresentationStyle == .fullScreen)
        #expect(controller.highlightColor == .systemBlue)
        #expect(controller.scanDelegate == nil)
        #expect(controller.recognizedTypes == [.barcode(symbologies: [.qr])])
    }

    @Test func `availability flags can be read`() {
        _ = BarcodeSelectoViewController.isSupported
        _ = BarcodeSelectoViewController.isAvailable
    }
}
#endif

#endif
