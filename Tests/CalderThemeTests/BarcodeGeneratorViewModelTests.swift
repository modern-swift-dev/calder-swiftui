#if canImport(SwiftUI) && !os(watchOS)
    import CalderTheme
    import CalderUIKit
    import SwiftUI
    import Testing

    @MainActor struct BarcodeGeneratorViewModelTests {

        @Test func `generate stores the barcode image`() async {
            let model = BarcodeGeneratorView.Model(code: "calder", generator: .qr)

            await model.generate()

            #expect(model.image != nil)
        }

        @Test func `generate reports a failure for an unencodable payload`() async {
            let model = BarcodeGeneratorView.Model(code: "Café", generator: .code128)

            await model.generate()

            #expect(model.image == nil)
            #expect(model.generationFailed)
        }

        @Test func `generate encodes a non-ASCII QR payload`() async {
            let model = BarcodeGeneratorView.Model(code: "Café", generator: .qr)

            await model.generate()

            #expect(model.image != nil)
            #expect(!model.generationFailed)
        }

        @Test func `generate keeps an existing image`() async {
            let existing = Image(systemName: "star")
            let model = BarcodeGeneratorView.Model(code: "calder", generator: .qr)
            model.image = existing

            await model.generate()

            #expect(model.image == existing)
        }
    }
#endif
