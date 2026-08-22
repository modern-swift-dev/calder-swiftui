#if canImport(Darwin)
#if os(iOS)
import AVFoundation
import Foundation

public extension AVCaptureDevice {

    /// Request the permission to the user
    /// - parameter type: The type of media to access
    /// - returns: A future with the user's permission.
    static func requestAccessFor(type: AVMediaType) async -> Bool {
        switch AVCaptureDevice.authorizationStatus(for: type) {
            case .authorized:
                return true
            case .denied,
                 .restricted:
                return false
            case .notDetermined:
                return await AVCaptureDevice.requestAccess(for: type)
            @unknown default:
                return false
        }
    }

    /// Request the permission to the user
    /// - returns: A future with the user's permission.
    static func requestAccessForVideo() async -> Bool {
        await requestAccessFor(type: .video)
    }

    /// Request the permission to the user
    /// - returns: A future with the user's permission.
    static func requestPermissionForAudio() async -> Bool {
        await requestAccessFor(type: .audio)
    }
}
#endif

#endif
