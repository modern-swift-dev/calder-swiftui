#if canImport(UIKit) && canImport(Vision) && !os(visionOS) && !os(watchOS)
    import Dispatch

    /// Runs every configuration, start, and stop step of a capture session on one serial queue.
    ///
    /// `AVCaptureSession.startRunning()` and `stopRunning()` block, so they must not run on the main thread.
    /// Routing them through a single serial queue also keeps their order: a stop submitted after a start
    /// always runs after that start, so quickly presenting and dismissing the scanner leaves the camera off.
    ///
    /// The session is touched only from blocks submitted to `queue`. That invariant is what makes the
    /// unchecked `Sendable` conformance sound; never read or mutate `session` outside ``perform(_:)``.
    final class BarcodeScannerSessionController<Session: BarcodeScannerCaptureSession>: @unchecked Sendable {
        /// The session confined to `queue`.
        private let session: Session

        /// The serial queue that owns `session`.
        private let queue: DispatchQueue

        /// Creates a controller that owns `session`.
        /// - Parameters:
        ///   - session: The session to control. The caller must not use it afterwards except to attach a preview layer.
        ///   - queue: A serial queue. Every block that touches `session` runs on it.
        init(session: Session, queue: DispatchQueue) {
            self.session = session
            self.queue = queue
        }

        /// Submits `work` to the session queue and returns immediately.
        /// - Parameter work: A block that receives the session on the session queue.
        func perform(_ work: @escaping @Sendable (Session) -> Void) {
            queue.async {
                work(self.session)
            }
        }

        /// Starts the session on the session queue unless it is already running. Returns immediately.
        func startRunning() {
            perform { session in
                guard !session.isRunning else {
                    return
                }
                session.startRunning()
            }
        }

        /// Stops the session on the session queue if it is running. Returns immediately without blocking the caller.
        func stopRunning() {
            perform { session in
                guard session.isRunning else {
                    return
                }
                session.stopRunning()
            }
        }
    }
#endif
