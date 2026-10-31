#if os(iOS) || os(macOS)
    import AVFoundation
    import CalderUIKit
    import Testing

    /// The helpers return the stored decision without prompting only once the user has decided, so these tests
    /// are skipped while the permission is undetermined: requesting it would show a prompt or terminate the process.
    struct AVCaptureDeviceExtTests {

        @Test(.enabled(if: AVCaptureDevice.authorizationStatus(for: .video) != .notDetermined))
        func `video access matches the authorization status`() async {
            let status = AVCaptureDevice.authorizationStatus(for: .video)
            let granted = await AVCaptureDevice.requestAccessForVideo()
            #expect(granted == (status == .authorized))
        }

        @Test(.enabled(if: AVCaptureDevice.authorizationStatus(for: .audio) != .notDetermined))
        func `audio access matches the authorization status`() async {
            let status = AVCaptureDevice.authorizationStatus(for: .audio)
            let granted = await AVCaptureDevice.requestAccessForAudio()
            #expect(granted == (status == .authorized))
        }

        @available(*, deprecated)
        @Test(.enabled(if: AVCaptureDevice.authorizationStatus(for: .audio) != .notDetermined))
        func `deprecated audio permission helper forwards to the access helper`() async {
            let renamed = await AVCaptureDevice.requestAccessForAudio()
            let deprecated = await AVCaptureDevice.requestPermissionForAudio()
            #expect(deprecated == renamed)
        }

        @Test(.enabled(if: AVCaptureDevice.authorizationStatus(for: .video) != .notDetermined))
        func `access for a media type matches the authorization status`() async {
            let status = AVCaptureDevice.authorizationStatus(for: .video)
            let granted = await AVCaptureDevice.requestAccessFor(type: .video)
            #expect(granted == (status == .authorized))
        }
    }
#endif
