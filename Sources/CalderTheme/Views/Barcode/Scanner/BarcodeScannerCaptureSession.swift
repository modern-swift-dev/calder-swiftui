#if canImport(UIKit) && canImport(Vision) && !os(visionOS) && !os(watchOS)
    import AVFoundation

    /// The capture-session operations that ``BarcodeScannerSessionController`` performs on its session queue.
    protocol BarcodeScannerCaptureSession: AnyObject, SendableMetatype {
        /// Whether the session is running.
        var isRunning: Bool { get }

        /// Starts the flow of data from the session's inputs to its outputs. This call blocks until the session starts.
        func startRunning()

        /// Stops the flow of data. This call blocks until the session stops.
        func stopRunning()
    }

    extension AVCaptureSession: BarcodeScannerCaptureSession {}
#endif
