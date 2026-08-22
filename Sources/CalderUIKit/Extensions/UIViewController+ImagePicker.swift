#if canImport(Darwin)
#if !os(macOS) && !os(tvOS) && !os(watchOS) && !os(visionOS)
import Foundation
import UIKit

public extension UIViewController {
    /// Utility method that allows presenting the `UIImagePickerController` (Image Picker) from any `UIViewController`.
    /// It provides options to pick from the photo library or camera, and handles presentation as an action sheet on iPad.
    /// - Parameters:
    ///   - sender: The `UIView` that acts as the source for the popover presentation controller on iPad.
    ///   - allowEditing: A boolean indicating whether the user can edit the selected image. Defaults to `false`.
    ///   - canPickFromLibrary: A boolean indicating whether picking from the photo library is allowed. Defaults to `true`.
    ///   - buttonFileText: The title for the "Choose from Library" action button.
    ///   - buttonCameraText: The title for the "Take Photo or Video" action button.
    ///   - buttonCancelText: The title for the "Cancel" action button.
    func openImagePicker(
        sender: UIView,
        allowEditing: Bool = false,
        canPickFromLibrary: Bool = true,
        buttonFileText: String,
        buttonCameraText: String,
        buttonCancelText: String
    ) {
        let isPhotoLibraryAvailable = canPickFromLibrary && UIImagePickerController.isSourceTypeAvailable(.photoLibrary)
        let isCameraAvailable = UIImagePickerController.isSourceTypeAvailable(.camera)

        let openCamera = { [weak self] in
            let imagePicker = UIImagePickerController()
            imagePicker.sourceType = .camera
            imagePicker.allowsEditing = allowEditing
            imagePicker.delegate = self as? (any (UIImagePickerControllerDelegate & UINavigationControllerDelegate))
            self?.present(imagePicker, animated: true, completion: nil)
        }

        let openLibrary = { [weak self] in
            let imagePicker = UIImagePickerController()
            imagePicker.sourceType = .photoLibrary
            imagePicker.mediaTypes = UIImagePickerController.availableMediaTypes(for: imagePicker.sourceType) ?? []
            imagePicker.delegate = self as? (any (UIImagePickerControllerDelegate & UINavigationControllerDelegate))
            imagePicker.allowsEditing = allowEditing
            self?.present(imagePicker, animated: true, completion: nil)
        }

        if isCameraAvailable, isPhotoLibraryAvailable {
            let alert = UIAlertController(
                title: nil,
                message: nil,
                preferredStyle: UIAlertController.Style.actionSheet
            )

            let cameraAction = UIAlertAction(
                title: buttonCameraText,
                style: .default,
                handler: { _ in
                    openCamera()
                }
            )

            let photoLibraryAction = UIAlertAction(
                title: buttonFileText,
                style: .default,
                handler: { _ in
                    openLibrary()
                }
            )

            let defaultAction = UIAlertAction(
                title: buttonCancelText,
                style: .cancel,
                handler: nil
            )
            alert.addAction(cameraAction)
            alert.addAction(photoLibraryAction)
            alert.addAction(defaultAction)
            alert.popoverPresentationController?.sourceView = sender
            alert.popoverPresentationController?.sourceRect = CGRect(x: sender.frame.width / 2, y: 0, width: sender.frame.width, height: sender.frame.height)
            present(alert, animated: true, completion: nil)
        } else if isPhotoLibraryAvailable {
            openLibrary()
        } else if isCameraAvailable {
            openCamera()
        }
    }
}
#endif

#endif
