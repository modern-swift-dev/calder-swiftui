#if canImport(SwiftUI)
    #if os(iOS)
        import AVFoundation

        /// The camera-permission checks that ``BarcodeScannerViewController`` performs before it starts the camera.
        struct BarcodeScannerCameraAccess: Sendable {
            /// Returns the app's current camera authorization status.
            var authorizationStatus: @MainActor @Sendable () -> AVAuthorizationStatus

            /// Prompts the user for camera access and returns whether it was granted.
            var requestAccess: @MainActor @Sendable () async -> Bool

            /// Camera access backed by `AVCaptureDevice`.
            static let live = BarcodeScannerCameraAccess(
                authorizationStatus: { AVCaptureDevice.authorizationStatus(for: .video) },
                requestAccess: { await AVCaptureDevice.requestAccess(for: .video) }
            )
        }
    #endif
#endif
