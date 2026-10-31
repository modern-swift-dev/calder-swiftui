#if canImport(SwiftUI) || canImport(UIKit) || canImport(AppKit)
    #if os(iOS)
        import AVFoundation
        @testable import CalderTheme
        import SwiftUI
        import Testing
        import UIKit

        @Suite(.serialized)
        @MainActor struct BarcodeScannerZoomTests {
            private func makeView(zoom: CGFloat = 1) -> BarcodeScannerView {
                BarcodeScannerView(model: .init(crossHairImage: UIImage(), zoomFactor: zoom))
            }

            private func makeDevice(range: ClosedRange<CGFloat> = 1 ... 5) -> BarcodeScannerTorchTests.FakeCaptureDevice {
                let device = BarcodeScannerTorchTests.FakeCaptureDevice()
                device.minAvailableVideoZoomFactor = range.lowerBound
                device.maxAvailableVideoZoomFactor = range.upperBound
                return device
            }

            @Test func `zoom is off by default`() {
                #expect(BarcodeScannerView.Model().zoomFactor == 1)
                #expect(makeView().zoomFactor == 1)
            }

            @Test func `attaching a camera keeps the default zoom`() {
                let view = makeView()
                let device = makeDevice()

                view.attach(device)

                #expect(device.videoZoomFactor == 1)
                #expect(view.zoomFactor == 1)
            }

            @Test func `the initial zoom applies when the camera attaches`() {
                let view = makeView(zoom: 3)
                let device = makeDevice()

                view.attach(device)

                #expect(device.videoZoomFactor == 3)
                #expect(view.zoomFactor == 3)
            }

            @Test func `the zoom factor is clamped to the camera range`() {
                let view = makeView()
                let device = makeDevice(range: 1 ... 5)
                view.attach(device)

                view.setZoomFactor(10)
                #expect(device.videoZoomFactor == 5)
                #expect(view.zoomFactor == 5)

                view.setZoomFactor(0.2)
                #expect(device.videoZoomFactor == 1)
                #expect(view.zoomFactor == 1)

                view.setZoomFactor(2.5)
                #expect(device.videoZoomFactor == 2.5)
            }

            @Test func `a requested zoom outside the range is clamped when the camera attaches`() {
                let view = makeView(zoom: 9)
                let device = makeDevice(range: 1 ... 4)

                view.attach(device)

                #expect(device.videoZoomFactor == 4)
            }

            @Test func `the zoom range follows the camera`() {
                let view = makeView()
                #expect(view.zoomFactorRange == 1 ... 1)

                view.attach(makeDevice(range: 1 ... 6))
                #expect(view.zoomFactorRange == 1 ... 6)
            }

            @Test func `setting the zoom without a camera does nothing`() {
                let view = makeView()

                view.setZoomFactor(3)

                #expect(view.zoomFactor == 1)
            }

            @Test func `pinching scales the zoom from where it began and reports it`() {
                let view = makeView(zoom: 2)
                let device = makeDevice()
                view.attach(device)
                var reported: [CGFloat] = []
                view.onZoomFactorChange = { reported.append($0) }

                view.pinch(scale: 1, state: .began)
                view.pinch(scale: 1.5, state: .changed)
                view.pinch(scale: 2, state: .changed)
                view.pinch(scale: 2, state: .ended)

                #expect(device.videoZoomFactor == 4)
                #expect(reported == [3, 4])
            }

            @Test func `pinching reports the clamped zoom`() {
                let view = makeView()
                let device = makeDevice(range: 1 ... 3)
                view.attach(device)
                var reported: [CGFloat] = []
                view.onZoomFactorChange = { reported.append($0) }

                view.pinch(scale: 1, state: .began)
                view.pinch(scale: 10, state: .changed)
                view.pinch(scale: 0.01, state: .changed)

                #expect(reported == [3, 1])
            }

            @Test func `a pinch without a camera reports nothing`() {
                let view = makeView()
                var reported: [CGFloat] = []
                view.onZoomFactorChange = { reported.append($0) }

                view.pinch(scale: 1, state: .began)
                view.pinch(scale: 2, state: .changed)

                #expect(reported.isEmpty)
            }

            @Test func `the preview has a pinch recognizer`() {
                let view = makeView()

                #expect(view.gestureRecognizers?.contains { $0 is UIPinchGestureRecognizer } == true)
            }

            @Test func `the scanner follows its zoom binding`() throws {
                let host = HostedScanner(zoom: 1)
                let controller = try #require(host.controller)
                let device = makeDevice()
                controller.barcodeScanner.attach(device)

                host.zoom = 3

                #expect(device.videoZoomFactor == 3)
                #expect(controller.zoomFactor == 3)
            }

            @Test func `pinching the scanner updates the bound zoom`() throws {
                let host = HostedScanner(zoom: 1)
                let controller = try #require(host.controller)
                controller.barcodeScanner.attach(makeDevice())

                controller.barcodeScanner.pinch(scale: 1, state: .began)
                controller.barcodeScanner.pinch(scale: 2, state: .changed)

                #expect(host.zoom == 2)
            }

            @Test func `the scanner keeps the default zoom without a binding`() throws {
                let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 320, height: 480))
                let host = UIHostingController(rootView: BarcodeScanner(result: .constant(nil), state: .scanning))
                window.rootViewController = host
                window.makeKeyAndVisible()
                defer { window.isHidden = true }
                host.view.layoutIfNeeded()
                let controller = try #require(host.children.compactMap { $0 as? BarcodeScannerViewController }.first)
                let device = makeDevice()

                controller.barcodeScanner.attach(device)

                #expect(device.videoZoomFactor == 1)
            }

            /// Hosts a ``BarcodeScanner`` whose zoom binding the test changes.
            @MainActor private final class HostedScanner {
                private let host: UIHostingController<BarcodeScanner>
                private let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 320, height: 480))

                var zoom: CGFloat {
                    didSet {
                        render()
                    }
                }

                init(zoom: CGFloat) {
                    self.zoom = zoom
                    host = UIHostingController(rootView: BarcodeScanner(result: .constant(nil), state: .scanning))
                    window.rootViewController = host
                    window.makeKeyAndVisible()
                    render()
                }

                var controller: BarcodeScannerViewController? {
                    host.children.compactMap { $0 as? BarcodeScannerViewController }.first
                }

                private func render() {
                    let binding = Binding<CGFloat>(
                        get: { MainActor.assumeIsolated { self.zoom } },
                        set: { value in MainActor.assumeIsolated { self.zoom = value } }
                    )
                    host.rootView = BarcodeScanner(result: .constant(nil), state: .scanning, zoomFactor: binding)
                    host.view.setNeedsLayout()
                    host.view.layoutIfNeeded()
                }
            }
        }
    #endif

#endif
