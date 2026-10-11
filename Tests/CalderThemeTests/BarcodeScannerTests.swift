#if canImport(SwiftUI) || canImport(UIKit) || canImport(AppKit)
    #if os(iOS)
        import AVFoundation
        @testable import CalderTheme
        import SwiftUI
        import Testing
        import UIKit

        @Suite(.serialized)
        @MainActor struct BarcodeScannerTests {

            @Test func `suspended state pauses detection`() throws {
                let host = HostedBarcodeScanner(state: .scanning)
                let controller = try #require(host.controller)

                host.update(state: .suspended)

                #expect(controller.barcodeScanner.isSuspended)
            }

            @Test func `scanning state resumes detection`() throws {
                let host = HostedBarcodeScanner(state: .suspended)
                let controller = try #require(host.controller)
                #expect(controller.barcodeScanner.isSuspended)

                host.update(state: .scanning)

                #expect(!controller.barcodeScanner.isSuspended)
            }

            @Test func `finished state stops detection`() throws {
                let host = HostedBarcodeScanner(state: .scanning)
                let controller = try #require(host.controller)

                host.update(state: .finished)

                #expect(controller.barcodeScanner.isSuspended)
            }

            @Test func `finished scanner restarts when scanning again`() throws {
                let host = HostedBarcodeScanner(state: .finished)
                let controller = try #require(host.controller)
                #expect(controller.barcodeScanner.isSuspended)

                host.update(state: .scanning)

                #expect(!controller.barcodeScanner.isSuspended)
            }

            @Test func `resetting the result allows a second scan`() async throws {
                let host = HostedBarcodeScanner(state: .scanning)
                let controller = try #require(host.controller)

                controller.barcodeScanner.deliverScannedCode("first", type: .qr, rect: .zero, path: UIBezierPath())
                try await host.waitForResult()
                #expect(host.result?.payload == "first")
                #expect(controller.barcodeScanner.isSuspended)

                host.result = nil

                #expect(!controller.barcodeScanner.isSuspended)
                controller.barcodeScanner.deliverScannedCode("second", type: .ean13, rect: .zero, path: UIBezierPath())
                try await host.waitForResult()
                #expect(host.result == BarcodeScanner.ScanResult(payload: "second", type: .ean13))
            }

            @Test func `resetting the result while suspended keeps detection paused`() async throws {
                let host = HostedBarcodeScanner(state: .scanning)
                let controller = try #require(host.controller)
                controller.barcodeScanner.deliverScannedCode("first", type: .qr, rect: .zero, path: UIBezierPath())
                try await host.waitForResult()

                host.update(state: .suspended)
                host.result = nil

                #expect(controller.barcodeScanner.isSuspended)
            }

            /// Hosts a ``BarcodeScanner`` in a window so SwiftUI drives its view controller.
            @MainActor private final class HostedBarcodeScanner {
                private let host: UIHostingController<BarcodeScanner>
                private let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 320, height: 480))
                private var state: BarcodeScanner.State

                /// The value of the scanner's `result` binding. Setting it re-renders the scanner, as a SwiftUI state change would.
                var result: BarcodeScanner.ScanResult? {
                    didSet {
                        render()
                    }
                }

                init(state: BarcodeScanner.State) {
                    self.state = state
                    host = UIHostingController(rootView: BarcodeScanner(result: .constant(nil), state: state))
                    window.rootViewController = host
                    window.makeKeyAndVisible()
                    render()
                }

                var controller: BarcodeScannerViewController? {
                    host.children.compactMap { $0 as? BarcodeScannerViewController }.first
                }

                func update(state: BarcodeScanner.State) {
                    self.state = state
                    render()
                }

                /// Waits for the scanner to write a result to its binding.
                func waitForResult() async throws {
                    for _ in 0 ..< 100 where result == nil {
                        try await Task.sleep(for: .milliseconds(10))
                    }
                    try #require(result != nil)
                }

                private func render() {
                    let binding = Binding<BarcodeScanner.ScanResult?>(
                        get: { MainActor.assumeIsolated { self.result } },
                        set: { value in MainActor.assumeIsolated { self.result = value } }
                    )
                    host.rootView = BarcodeScanner(result: binding, state: state)
                    host.view.setNeedsLayout()
                    host.view.layoutIfNeeded()
                }
            }
        }
    #endif

#endif
