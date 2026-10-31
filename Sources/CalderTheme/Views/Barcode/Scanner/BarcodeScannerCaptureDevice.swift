#if canImport(UIKit) && canImport(Vision) && !os(visionOS) && !os(watchOS)
    import AVFoundation

    /// The camera controls that ``BarcodeScannerView`` drives while it scans.
    ///
    /// `AVCaptureDevice` conforms to it. A test supplies its own conformance, because camera hardware isn't available
    /// there.
    @MainActor protocol BarcodeScannerCaptureDevice: AnyObject {
        /// Whether the camera has a torch.
        var hasTorch: Bool { get }

        /// Whether the torch can be turned on right now, for example not while the device is too hot.
        var isTorchAvailable: Bool { get }

        /// Whether the torch is on.
        var isTorchActive: Bool { get }

        /// Turns the torch on or off.
        /// - Parameter on: `true` to turn the torch on, `false` to turn it off.
        /// - Throws: An error when the camera can't be locked for configuration.
        func setTorch(on: Bool) throws

        /// The smallest zoom factor the camera supports.
        var minAvailableVideoZoomFactor: CGFloat { get }

        /// The largest zoom factor the camera supports.
        var maxAvailableVideoZoomFactor: CGFloat { get }

        /// The camera's current zoom factor.
        var videoZoomFactor: CGFloat { get }

        /// Sets the camera's zoom factor.
        /// - Parameter factor: A zoom factor within the camera's supported range.
        /// - Throws: An error when the camera can't be locked for configuration.
        func setVideoZoomFactor(_ factor: CGFloat) throws
    }

    extension AVCaptureDevice: @MainActor BarcodeScannerCaptureDevice {
        /// The torch level the scanner uses, which is dim enough to avoid glare on glossy codes.
        static let scannerTorchLevel: Float = 0.25

        func setTorch(on: Bool) throws {
            try lockForConfiguration()
            defer { unlockForConfiguration() }
            if on {
                try setTorchModeOn(level: Self.scannerTorchLevel)
            } else {
                torchMode = .off
            }
        }

        func setVideoZoomFactor(_ factor: CGFloat) throws {
            try lockForConfiguration()
            defer { unlockForConfiguration() }
            videoZoomFactor = factor
        }
    }
#endif
