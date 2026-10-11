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

        @Test func `generate keeps an existing image`() async {
            let existing = Image(systemName: "star")
            let model = BarcodeGeneratorView.Model(code: "calder", generator: .qr)
            model.image = existing

            await model.generate()

            #expect(model.image == existing)
        }
    }
#endif
