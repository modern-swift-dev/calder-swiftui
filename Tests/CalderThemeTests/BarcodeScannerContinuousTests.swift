#if canImport(SwiftUI) || canImport(UIKit) || canImport(AppKit)
    #if os(iOS)
        import AVFoundation
        @testable import CalderTheme
        import SwiftUI
        import Testing
        import UIKit

        @Suite(.serialized)
        @MainActor struct BarcodeScannerContinuousTests {
            /// A scanner view whose clock the test controls.
            private final class Clock {
                var now = ContinuousClock.now
            }

            private func makeView(cooldown: Duration?, clock: Clock) -> BarcodeScannerView {
                let view = BarcodeScannerView(model: .init(crossHairImage: UIImage(), repeatCooldown: cooldown))
                view.now = { clock.now }
                return view
            }

            @Test func `single result mode is the default`() {
                #expect(BarcodeScannerView.Model().repeatCooldown == nil)
            }

            @Test func `single result mode suppresses a repeated value until reset`() {
                let clock = Clock()
                let view = makeView(cooldown: nil, clock: clock)

                #expect(view.shouldDeliver("a"))
                clock.now += .seconds(60)
                #expect(!view.shouldDeliver("a"))
                #expect(view.shouldDeliver("b"))

                view.resetLastScan()
                #expect(view.shouldDeliver("b"))
            }

            @Test func `continuous mode reports distinct codes and suppresses repeats within the cooldown`() {
                let clock = Clock()
                let view = makeView(cooldown: .seconds(2), clock: clock)

                #expect(view.shouldDeliver("a"))
                clock.now += .seconds(1)
                #expect(!view.shouldDeliver("a"))
                #expect(view.shouldDeliver("b"))
                clock.now += .seconds(1)
                #expect(view.shouldDeliver("a"))
                #expect(!view.shouldDeliver("b"))
                clock.now += .seconds(1)
                #expect(view.shouldDeliver("b"))
            }

            @Test func `resetting the last scan clears the cooldown`() {
                let clock = Clock()
                let view = makeView(cooldown: .seconds(2), clock: clock)
                #expect(view.shouldDeliver("a"))

                view.resetLastScan()

                #expect(view.shouldDeliver("a"))
            }

            @Test func `the controller keeps delivering codes in continuous mode`() {
                var model = BarcodeScannerViewController.defaultScannerModel
                model.repeatCooldown = .seconds(2)
                let controller = BarcodeScannerViewController(scannerModel: model)
                var delivered: [String] = []
                controller.callback = { code, _ in delivered.append(code) }

                controller.barcodeScanner.deliverScannedCode("first", type: .qr, rect: .zero, path: UIBezierPath())
                controller.barcodeScanner.deliverScannedCode("second", type: .ean13, rect: .zero, path: UIBezierPath())

                #expect(delivered == ["first", "second"])
                #expect(!controller.barcodeScanner.isSuspended)
            }

            @Test func `the controller still delivers one code at a time by default`() {
                let controller = BarcodeScannerViewController()
                var delivered: [String] = []
                controller.callback = { code, _ in delivered.append(code) }

                controller.barcodeScanner.deliverScannedCode("first", type: .qr, rect: .zero, path: UIBezierPath())
                controller.barcodeScanner.deliverScannedCode("second", type: .qr, rect: .zero, path: UIBezierPath())

                #expect(delivered == ["first"])
                #expect(controller.barcodeScanner.isSuspended)
            }

            @Test func `the SwiftUI scanner reports every code through onScan`() throws {
                var scanned: [BarcodeScanner.ScanResult] = []
                let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 320, height: 480))
                let host = UIHostingController(rootView: BarcodeScanner(state: .scanning, cooldown: .seconds(5)) { scanned.append($0) })
                window.rootViewController = host
                window.makeKeyAndVisible()
                defer { window.isHidden = true }
                host.view.layoutIfNeeded()
                let controller = try #require(host.children.compactMap { $0 as? BarcodeScannerViewController }.first)

                controller.barcodeScanner.deliverScannedCode("first", type: .qr, rect: .zero, path: UIBezierPath())
                controller.barcodeScanner.deliverScannedCode("second", type: .ean13, rect: .zero, path: UIBezierPath())

                #expect(scanned == [.init(payload: "first", type: .qr), .init(payload: "second", type: .ean13)])
                #expect(!controller.barcodeScanner.isSuspended)
            }

            @Test func `the SwiftUI scanner passes its cooldown to the scanner view`() throws {
                let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 320, height: 480))
                let host = UIHostingController(rootView: BarcodeScanner(state: .scanning, cooldown: .seconds(5)) { _ in })
                window.rootViewController = host
                window.makeKeyAndVisible()
                defer { window.isHidden = true }
                host.view.layoutIfNeeded()
                let controller = try #require(host.children.compactMap { $0 as? BarcodeScannerViewController }.first)
                let clock = Clock()
                controller.barcodeScanner.now = { clock.now }

                #expect(controller.barcodeScanner.shouldDeliver("a"))
                clock.now += .seconds(4)
                #expect(!controller.barcodeScanner.shouldDeliver("a"))
                clock.now += .seconds(1)
                #expect(controller.barcodeScanner.shouldDeliver("a"))
            }

            @Test func `the SwiftUI scanner defaults the cooldown to two seconds`() throws {
                let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 320, height: 480))
                let host = UIHostingController(rootView: BarcodeScanner(state: .scanning) { _ in })
                window.rootViewController = host
                window.makeKeyAndVisible()
                defer { window.isHidden = true }
                host.view.layoutIfNeeded()
                let controller = try #require(host.children.compactMap { $0 as? BarcodeScannerViewController }.first)
                let clock = Clock()
                controller.barcodeScanner.now = { clock.now }

                #expect(controller.barcodeScanner.shouldDeliver("a"))
                clock.now += .seconds(1)
                #expect(!controller.barcodeScanner.shouldDeliver("a"))
                clock.now += .seconds(1)
                #expect(controller.barcodeScanner.shouldDeliver("a"))
            }
        }
    #endif

#endif
