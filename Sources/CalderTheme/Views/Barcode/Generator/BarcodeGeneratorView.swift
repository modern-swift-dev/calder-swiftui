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
        ///
        /// The barcode image is generated off the main thread the first time the view appears and is kept
        /// across parent view updates. A new image is generated only when `code` or `type` changes.
        public struct BarcodeGeneratorView: View {

            /// The observable model for `BarcodeGeneratorView` responsible for barcode image generation.
            ///
            /// The model is main-actor isolated; image generation itself runs off the main thread.
            @MainActor @Observable public class Model {

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

                /// Generates the barcode image off the main thread and stores it in `image`.
                ///
                /// Does nothing when an image is already available.
                public func generate() async {
                    guard image == nil else {
                        return
                    }
                    image = await Self.makeImage(code: code, generator: generator)
                }

                @concurrent private nonisolated static func makeImage(code: String, generator: BarcodeGenerator) async -> Image? {
                    generator.createImage(barcode: code)
                }
            }

            private struct GenerationKey: Equatable {
                let code: String
                let generator: BarcodeGenerator

                init(_ model: Model) {
                    code = model.code
                    generator = model.generator
                }
            }

            @State private var model: Model
            private let latestModel: Model

            /// Initializes a new `BarcodeGeneratorView` with the given code string and barcode type.
            /// - Parameters:
            ///   - code: The string value to encode into the barcode.
            ///   - type: The `BarcodeGenerator` type (e.g., .code128, .qr, .pdf417) for the barcode.
            public init(code: String, type: BarcodeGenerator) {
                self.init(model: Model(code: code, generator: type))
            }

            init(model: Model) {
                _model = State(initialValue: model)
                latestModel = model
            }

            /// The body of the `BarcodeGeneratorView` displaying either the generated image or a progress indicator.
            public var body: some View {
                Group {
                    if let image = model.image {
                        image
                    } else {
                        ProgressView()
                    }
                }
                .task(id: GenerationKey(latestModel)) {
                    if GenerationKey(model) != GenerationKey(latestModel) {
                        model = latestModel
                    }
                    await model.generate()
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
                    let model = BarcodeGeneratorView.Model(code: barcode, generator: type)
                    model.image = type.createImage(barcode: barcode)

                    return VStack {
                        BarcodeGeneratorView(model: model)
                        Spacer()
                    }
                }
            }
        #endif
    #endif
#endif
