#if canImport(SwiftUI)
    @testable import CalderTheme
    import CalderUIKit
    import Foundation
    import SwiftUI
    import Testing

    @Suite(.serialized)
    @MainActor struct BarcodeLocalizationTests {
        @Test(arguments: [
            ("barcodeScanner.permissionDenied.title", "Camera access is off"),
            ("barcodeScanner.permissionDenied.message", "Allow camera access in Settings to scan codes."),
            ("barcodeScanner.permissionDenied.openSettings", "Open Settings"),
            ("barcodeScanner.unsupported.title", "Scanning unavailable"),
            ("barcodeScanner.unsupported.message", "This device cannot scan codes with its camera."),
            ("barcodeGenerator.generationFailed", "Unable to generate barcode")
        ])
        func `barcode messages come from the package string catalog`(key: String, expected: String) {
            #expect(Bundle.module.localizedString(forKey: key, value: nil, table: nil) == expected)
        }

        #if os(iOS)
            @Test(arguments: [
                (BarcodeScannerUnavailableView.Reason.permissionDenied, "Camera access is off, Allow camera access in Settings to scan codes."),
                (.unsupported, "Scanning unavailable, This device cannot scan codes with its camera.")
            ])
            func `unavailable view shows its message`(reason: BarcodeScannerUnavailableView.Reason, expected: String) {
                let labels = AccessibilityTree.elements(of: BarcodeScannerUnavailableView(reason: reason)).compactMap(\.label)

                #expect(labels.contains { $0.hasSuffix(expected) })
            }

            @Test func `failed generator shows its message`() async {
                let model = BarcodeGeneratorView.Model(code: "Café", generator: .code128)
                await model.generate()

                let labels = AccessibilityTree.elements(of: BarcodeGeneratorView(model: model)).compactMap(\.label)

                #expect(labels.contains("Unable to generate barcode"))
            }
        #endif
    }
#endif
