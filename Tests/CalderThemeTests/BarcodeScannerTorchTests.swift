#if canImport(SwiftUI) || canImport(UIKit) || canImport(AppKit)
    #if os(iOS)
        import AVFoundation
        @testable import CalderTheme
        import SwiftUI
        import Testing
        import UIKit

        @Suite(.serialized)
        @MainActor struct BarcodeScannerTorchTests {
            /// A camera whose torch the test can observe.
            @MainActor final class FakeCaptureDevice: BarcodeScannerCaptureDevice {
                var hasTorch: Bool
                var isTorchAvailable: Bool
                private(set) var isTorchActive = false
                private(set) var torchChanges = 0
                var minAvailableVideoZoomFactor: CGFloat = 1
                var maxAvailableVideoZoomFactor: CGFloat = 1
                private(set) var videoZoomFactor: CGFloat = 1

                init(hasTorch: Bool = true, isTorchAvailable: Bool = true) {
                    self.hasTorch = hasTorch
                    self.isTorchAvailable = isTorchAvailable
                }

                func setTorch(on: Bool) throws {
                    torchChanges += 1
                    isTorchActive = on
                }

                func setVideoZoomFactor(_ factor: CGFloat) throws {
                    videoZoomFactor = factor
                }
            }

            private func makeView(torch: Bool = false) -> BarcodeScannerView {
                BarcodeScannerView(model: .init(crossHairImage: UIImage(), isTorchOn: torch))
            }

            @Test func `the torch is off by default`() {
                let model = BarcodeScannerView.Model()

                #expect(!model.isTorchOn)
            }

            @Test func `a model can ask for the torch`() {
                #expect(BarcodeScannerView.Model(isTorchOn: true).isTorchOn)
            }

            @Test func `the torch follows the option on a camera with a torch`() {
                let view = makeView()
                let device = FakeCaptureDevice()
                view.attach(device)

                view.setTorch(true)
                #expect(device.isTorchActive)
                #expect(view.isTorchOn)

                view.setTorch(false)
                #expect(!device.isTorchActive)
                #expect(!view.isTorchOn)
            }

            @Test func `the initial torch option applies when the camera attaches`() {
                let view = makeView(torch: true)
                let device = FakeCaptureDevice()

                view.attach(device)

                #expect(device.isTorchActive)
            }

            @Test func `the torch option set before the camera attaches applies later`() {
                let view = makeView()
                view.setTorch(true)
                let device = FakeCaptureDevice()

                view.attach(device)

                #expect(device.isTorchActive)
            }

            @Test(arguments: [(false, true), (true, false)])
            func `a camera without a usable torch ignores the option`(hasTorch: Bool, isAvailable: Bool) {
                let view = makeView()
                let device = FakeCaptureDevice(hasTorch: hasTorch, isTorchAvailable: isAvailable)
                view.attach(device)

                view.setTorch(true)

                #expect(!device.isTorchActive)
                #expect(device.torchChanges == 0)
                #expect(!view.isTorchAvailable())
            }

            @Test func `setting the torch without a camera does nothing`() {
                let view = makeView()

                view.setTorch(true)
                view.setTorch(false)

                #expect(!view.isTorchAvailable())
            }

            @Test func `the torch availability follows the camera`() {
                let view = makeView()
                #expect(!view.isTorchAvailable())

                view.attach(FakeCaptureDevice())
                #expect(view.isTorchAvailable())
            }

            @Test func `toggling the torch flips it`() {
                let view = makeView()
                let device = FakeCaptureDevice()
                view.attach(device)

                view.toggleTorch()
                #expect(device.isTorchActive)

                view.toggleTorch()
                #expect(!device.isTorchActive)
            }

            @Test func `torch availability can be queried without a scanner`() {
                _ = BarcodeScannerViewController.isTorchAvailable
            }

            @Test func `the scanner follows its torch binding`() throws {
                let host = HostedScanner(torch: true)
                let controller = try #require(host.controller)
                let device = FakeCaptureDevice()
                controller.barcodeScanner.attach(device)
                #expect(device.isTorchActive)

                host.torch = false
                #expect(!device.isTorchActive)

                host.torch = true
                #expect(device.isTorchActive)
            }

            @Test func `the scanner keeps the torch off by default`() throws {
                let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 320, height: 480))
                let host = UIHostingController(rootView: BarcodeScanner(result: .constant(nil), state: .scanning))
                window.rootViewController = host
                window.makeKeyAndVisible()
                defer { window.isHidden = true }
                host.view.layoutIfNeeded()
                let controller = try #require(host.children.compactMap { $0 as? BarcodeScannerViewController }.first)
                let device = FakeCaptureDevice()

                controller.barcodeScanner.attach(device)

                #expect(!device.isTorchActive)
            }

            /// Hosts a ``BarcodeScanner`` whose torch binding the test changes.
            @MainActor private final class HostedScanner {
                private let host: UIHostingController<BarcodeScanner>
                private let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 320, height: 480))

                var torch: Bool {
                    didSet {
                        render()
                    }
                }

                init(torch: Bool) {
                    self.torch = torch
                    host = UIHostingController(rootView: BarcodeScanner(result: .constant(nil), state: .scanning))
                    window.rootViewController = host
                    window.makeKeyAndVisible()
                    render()
                }

                var controller: BarcodeScannerViewController? {
                    host.children.compactMap { $0 as? BarcodeScannerViewController }.first
                }

                private func render() {
                    let binding = Binding<Bool>(
                        get: { MainActor.assumeIsolated { self.torch } },
                        set: { value in MainActor.assumeIsolated { self.torch = value } }
                    )
                    host.rootView = BarcodeScanner(result: .constant(nil), state: .scanning, torch: binding)
                    host.view.setNeedsLayout()
                    host.view.layoutIfNeeded()
                }
            }
        }
    #endif

#endif
