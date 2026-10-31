#if canImport(Darwin)
    #if !os(macOS) && !os(tvOS) && !os(watchOS) && !os(visionOS)
        import Foundation
        import PhotosUI
        import UIKit

        /// Presents `PHPickerViewController` for the photo library and `UIImagePickerController` for the camera.
        @MainActor
        struct SystemImagePickerPresenter: ImagePickerPresenting {

            func isAvailable(_ source: ImagePickerSource) -> Bool {
                switch source {
                    case .photoLibrary:
                        true
                    case .camera:
                        UIImagePickerController.isSourceTypeAvailable(.camera)
                }
            }

            func presentPicker(source: ImagePickerSource, limit: Int, from viewController: UIViewController) async throws -> [UIImage] {
                let session = Session()
                switch source {
                    case .photoLibrary:
                        var configuration = PHPickerConfiguration()
                        configuration.filter = .images
                        configuration.selectionLimit = limit
                        let picker = PHPickerViewController(configuration: configuration)
                        picker.delegate = session
                        await session.run(picker, from: viewController)
                    case .camera:
                        let picker = UIImagePickerController()
                        picker.sourceType = .camera
                        picker.delegate = session
                        await session.run(picker, from: viewController)
                }
                switch session.selection {
                    case .cancelled:
                        return []
                    case let .photo(image):
                        return [image]
                    case let .providers(providers):
                        return try await ImagePickerResults.images(from: providers, limit: limit, load: Self.loadImage)
                }
            }

            private static func loadImage(from provider: NSItemProvider) async throws -> UIImage? {
                guard provider.canLoadObject(ofClass: UIImage.self) else {
                    return nil
                }
                return try await withCheckedThrowingContinuation { continuation in
                    provider.loadObject(ofClass: UIImage.self) { object, error in
                        if let error {
                            continuation.resume(throwing: error)
                        } else {
                            continuation.resume(returning: object as? UIImage)
                        }
                    }
                }
            }

            /// Owns one presentation and acts as the picker's delegate. The delegate properties are weak, so the
            /// caller keeps the session alive while it awaits `run(_:from:)`.
            @MainActor
            private final class Session: NSObject, PHPickerViewControllerDelegate, UIImagePickerControllerDelegate,
                UINavigationControllerDelegate, UIAdaptivePresentationControllerDelegate {

                /// What the user picked. Kept here, rather than passed through the continuation, because
                /// `NSItemProvider` isn't `Sendable`.
                enum Selection {
                    case cancelled
                    case photo(UIImage)
                    case providers([NSItemProvider])
                }

                private(set) var selection = Selection.cancelled

                private var continuation: CheckedContinuation<Void, Never>?

                func run(_ picker: UIViewController, from presenter: UIViewController) async {
                    await withCheckedContinuation { continuation in
                        self.continuation = continuation
                        picker.presentationController?.delegate = self
                        presenter.present(picker, animated: true)
                    }
                }

                private func finish(_ selection: Selection, dismissing picker: UIViewController?) {
                    guard let continuation else {
                        return
                    }
                    self.continuation = nil
                    self.selection = selection
                    guard let picker else {
                        continuation.resume()
                        return
                    }
                    picker.dismiss(animated: true) {
                        continuation.resume()
                    }
                }

                func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
                    finish(results.isEmpty ? .cancelled : .providers(results.map(\.itemProvider)), dismissing: picker)
                }

                func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
                    if let image = info[.originalImage] as? UIImage {
                        finish(.photo(image), dismissing: picker)
                    } else {
                        finish(.cancelled, dismissing: picker)
                    }
                }

                func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
                    finish(.cancelled, dismissing: picker)
                }

                func presentationControllerDidDismiss(_: UIPresentationController) {
                    finish(.cancelled, dismissing: nil)
                }
            }
        }
    #endif

#endif
