#if canImport(Darwin)
    #if os(iOS) || os(macOS)
        import AVFoundation
        import Foundation

        public extension AVCaptureDevice {

            /// Request the permission to the user
            /// - parameter type: The type of media to access
            /// - returns: A future with the user's permission.
            static func requestAccessFor(type: AVMediaType) async -> Bool {
                switch AVCaptureDevice.authorizationStatus(for: type) {
                    case .authorized:
                        true
                    case .denied,
                         .restricted:
                        false
                    case .notDetermined:
                        await AVCaptureDevice.requestAccess(for: type)
                    @unknown default:
                        false
                }
            }

            /// Request the permission to the user
            /// - returns: A future with the user's permission.
            static func requestAccessForVideo() async -> Bool {
                await requestAccessFor(type: .video)
            }

            /// Request the permission to the user
            /// - returns: A future with the user's permission.
            static func requestAccessForAudio() async -> Bool {
                await requestAccessFor(type: .audio)
            }

            /// Request the permission to the user
            ///
            /// Deprecated for consistency with ``requestAccessForVideo()`` and ``requestAccessFor(type:)``.
            /// - returns: A future with the user's permission.
            @available(*, deprecated, renamed: "requestAccessForAudio()")
            static func requestPermissionForAudio() async -> Bool {
                await requestAccessForAudio()
            }
        }
    #endif

#endif
