#if canImport(SwiftUI) || canImport(UIKit) || canImport(AppKit)
    #if canImport(UIKit) && canImport(Vision) && !os(visionOS) && !os(watchOS)
        @testable import CalderTheme
        import Dispatch
        import Synchronization
        import Testing

        struct BarcodeScannerSessionControllerTests {

            @Test func `configuration start and stop run in submission order`() async {
                let session = FakeCaptureSession()
                let controller = BarcodeScannerSessionController(session: session, queue: DispatchQueue(label: "test.session"))

                controller.perform { $0.record(.configure) }
                controller.startRunning()
                controller.stopRunning()
                await controller.drain()

                #expect(session.events == [.configure, .start, .stop])
                #expect(!session.isRunning)
            }

            @Test func `rapid start and stop leaves the session stopped`() async {
                let session = FakeCaptureSession()
                let controller = BarcodeScannerSessionController(session: session, queue: DispatchQueue(label: "test.session"))

                for _ in 0 ..< 5 {
                    controller.startRunning()
                    controller.stopRunning()
                }
                await controller.drain()

                #expect(!session.isRunning)
                #expect(session.events == Array(repeating: [FakeCaptureSession.Event.start, .stop], count: 5).flatMap(\.self))
            }

            @Test func `stopping returns while the session queue is busy`() async {
                let queue = DispatchQueue(label: "test.session")
                let session = FakeCaptureSession()
                let controller = BarcodeScannerSessionController(session: session, queue: queue)
                let gate = DispatchSemaphore(value: 0)
                queue.async { gate.wait() }

                controller.startRunning()
                controller.stopRunning()

                #expect(session.events.isEmpty)
                gate.signal()
                await controller.drain()
                #expect(session.events == [.start, .stop])
                #expect(!session.isRunning)
            }

            @Test func `starting a running session does not start it again`() async {
                let session = FakeCaptureSession()
                let controller = BarcodeScannerSessionController(session: session, queue: DispatchQueue(label: "test.session"))

                controller.startRunning()
                controller.startRunning()
                controller.stopRunning()
                controller.stopRunning()
                await controller.drain()

                #expect(session.events == [.start, .stop])
            }

            private final class FakeCaptureSession: BarcodeScannerCaptureSession, Sendable {
                enum Event: Equatable, Sendable {
                    case configure
                    case start
                    case stop
                }

                private let state = Mutex<(isRunning: Bool, events: [Event])>((false, []))

                var isRunning: Bool {
                    state.withLock(\.isRunning)
                }

                var events: [Event] {
                    state.withLock(\.events)
                }

                func record(_ event: Event) {
                    state.withLock { $0.events.append(event) }
                }

                func startRunning() {
                    state.withLock {
                        $0.isRunning = true
                        $0.events.append(.start)
                    }
                }

                func stopRunning() {
                    state.withLock {
                        $0.isRunning = false
                        $0.events.append(.stop)
                    }
                }
            }

        }

        private extension BarcodeScannerSessionController {
            /// Waits until every block submitted before this call has run.
            func drain() async {
                await withCheckedContinuation { continuation in
                    perform { _ in continuation.resume() }
                }
            }
        }
    #endif

#endif
