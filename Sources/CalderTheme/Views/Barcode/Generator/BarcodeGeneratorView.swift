#if canImport(SwiftUI)
#if !os(watchOS)
import CalderSwiftUI
import CalderUIKit
import Combine
import Foundation
import Observation
import SFSafeSymbols
import SwiftUI

/// A SwiftUI view that displays a barcode (Code128, QR, PDF417) generated from a given string.
/// The barcode image is generated asynchronously.
public struct BarcodeGeneratorView: View {

    /// The observable model for `BarcodeGeneratorView` responsible for barcode image generation.
    @Observable public class Model: @unchecked Sendable {

        /// The generated barcode image, if available.
        public var image: Image?

        /// The string value to encode into the barcode.
        public let code: String

        /// The generator type (e.g., .code128, .qr, .pdf417) used to create the barcode image.
        public let generator: BarcodeGenerator

        /// Initializes a new `Model` with the given barcode string and generator type.
        /// - Parameters:
        ///   - code: The string value to encode into the barcode.
        ///   - generator: The `BarcodeGenerator` instance to use for image creation.
        public init(code: String, generator: BarcodeGenerator) {
            self.code = code
            self.generator = generator
        }

        /// Generates the barcode image asynchronously on the main actor.
        /// If successful, the `image` property will be updated.
        @MainActor public func generate() async {
            image = generator.createImage(barcode: code)
        }
    }

    /// The bindable model for the `BarcodeGeneratorView`.
    @Bindable var model: Model

    /// Initializes a new `BarcodeGeneratorView` with the given code string and barcode type.
    /// - Parameters:
    ///   - code: The string value to encode into the barcode.
    ///   - type: The `BarcodeGenerator` type (e.g., .code128, .qr, .pdf417) for the barcode.
    public init(code: String, type: BarcodeGenerator) {
        self.model = Model(code: code, generator: type)
    }

    /// The body of the `BarcodeGeneratorView` displaying either the generated image or a progress indicator.
    public var body: some View {
        if let image = model.image {
            image
        } else {
            ProgressView()
                .task {
                    await model.generate()
                }
        }
    }

}

#endif
#endif

#if canImport(SwiftUI)
#if !os(watchOS)
import CalderUIKit
import SnapshotPreviews
import SwiftUI

#if DEBUG
@MainActor enum BarcodeGeneratorViewPreviews: PreviewProvider, SnapshotProvider {
    static let defaultLayout: PreviewSnapshotLayout = .device

    static var snapshots: [PreviewSnapshot] {
        PreviewSnapshot("code128") {
            preview(type: .code128)
        }

        PreviewSnapshot("qr") {
            preview(type: .qr)
        }

        PreviewSnapshot("pdf417") {
            preview(type: .pdf417)
        }
    }

    private static func preview(type: BarcodeGenerator) -> some View {
        let barcode = "http://google.ca"
        let view = BarcodeGeneratorView(code: barcode, type: type)
        view.model.image = type.createImage(barcode: barcode)

        return VStack {
            view
            Spacer()
        }
    }
}
#endif
#endif
#endif
