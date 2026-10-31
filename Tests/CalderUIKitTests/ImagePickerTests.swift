#if canImport(Darwin)
    #if !os(macOS) && !os(tvOS) && !os(watchOS) && !os(visionOS)
        @testable import CalderUIKit
        import Foundation
        import Testing
        import UIKit

        @MainActor struct ImagePickerTests {

            private struct LoadFailure: Error, Equatable {}

            private final class FakePresenter: ImagePickerPresenting {
                var availableSources: Set<ImagePickerSource>
                var images: [UIImage]
                private(set) var requests: [(source: ImagePickerSource, limit: Int)] = []

                init(availableSources: Set<ImagePickerSource> = [.photoLibrary, .camera], images: [UIImage] = []) {
                    self.availableSources = availableSources
                    self.images = images
                }

                func isAvailable(_ source: ImagePickerSource) -> Bool {
                    availableSources.contains(source)
                }

                func presentPicker(source: ImagePickerSource, limit: Int, from _: UIViewController) async throws -> [UIImage] {
                    requests.append((source, limit))
                    return images
                }
            }

            private final class PresentingViewController: UIViewController {
                override var presentedViewController: UIViewController? {
                    UIViewController()
                }
            }

            // MARK: - pickImages

            @Test func `unavailable source throws a typed error`() async {
                let presenter = FakePresenter(availableSources: [.photoLibrary])
                await #expect(throws: ImagePickerError.sourceUnavailable(.camera)) {
                    try await UIViewController().pickImages(source: .camera, limit: 1, using: presenter)
                }
                #expect(presenter.requests.isEmpty)
            }

            @Test func `cancelling returns an empty array`() async throws {
                let presenter = FakePresenter(images: [])
                let images = try await UIViewController().pickImages(source: .photoLibrary, limit: 3, using: presenter)
                #expect(images.isEmpty)
            }

            @Test func `picked images are returned in order for the requested source`() async throws {
                let first = UIImage()
                let second = UIImage()
                let presenter = FakePresenter(images: [first, second])

                let images = try await UIViewController().pickImages(source: .photoLibrary, limit: 5, using: presenter)

                #expect(images.count == 2)
                #expect(images[0] === first)
                #expect(images[1] === second)
                #expect(presenter.requests.count == 1)
                #expect(presenter.requests.first?.source == .photoLibrary)
                #expect(presenter.requests.first?.limit == 5)
            }

            @Test func `results never exceed the limit`() async throws {
                let presenter = FakePresenter(images: [UIImage(), UIImage(), UIImage()])
                let images = try await UIViewController().pickImages(source: .photoLibrary, limit: 2, using: presenter)
                #expect(images.count == 2)
            }

            @Test func `a limit of zero or less means no limit`() async throws {
                let presenter = FakePresenter(images: [UIImage(), UIImage(), UIImage()])
                let unlimited = try await UIViewController().pickImages(source: .photoLibrary, limit: 0, using: presenter)
                let negative = try await UIViewController().pickImages(source: .photoLibrary, limit: -4, using: presenter)
                #expect(unlimited.count == 3)
                #expect(negative.count == 3)
                #expect(presenter.requests.map(\.limit) == [0, 0])
            }

            @Test func `presenting over another presentation throws instead of hanging`() async {
                let presenter = FakePresenter(images: [UIImage()])
                await #expect(throws: ImagePickerError.alreadyPresenting) {
                    try await PresentingViewController().pickImages(source: .photoLibrary, limit: 1, using: presenter)
                }
                #expect(presenter.requests.isEmpty)
            }

            // MARK: - Result mapping

            @Test func `mapping loads items in order and skips items without an image`() async throws {
                let images = [UIImage(), UIImage(), UIImage()]
                let result = try await ImagePickerResults.images(from: [0, 1, 2, 3], limit: 0) { index in
                    index < images.count ? images[index] : nil
                }
                #expect(result.count == 3)
                #expect(zip(result, images).allSatisfy { $0 === $1 })
            }

            @Test func `mapping stops at the limit`() async throws {
                var loaded: [Int] = []
                let result = try await ImagePickerResults.images(from: [0, 1, 2, 3], limit: 2) { index in
                    loaded.append(index)
                    return UIImage()
                }
                #expect(result.count == 2)
                #expect(loaded == [0, 1])
            }

            @Test func `mapping propagates a load failure`() async {
                await #expect(throws: LoadFailure()) {
                    try await ImagePickerResults.images(from: [0, 1], limit: 0) { index in
                        if index == 1 {
                            throw LoadFailure()
                        }
                        return UIImage()
                    }
                }
            }
        }
    #endif
#endif
