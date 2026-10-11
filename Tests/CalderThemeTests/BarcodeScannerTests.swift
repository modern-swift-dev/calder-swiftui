#if canImport(SwiftUI) || canImport(UIKit) || canImport(AppKit)
    #if os(iOS)
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
        }

        /// Hosts a ``BarcodeScanner`` in a window so SwiftUI drives its view controller.
        @MainActor private final class HostedBarcodeScanner {
            private let host: UIHostingController<BarcodeScanner>
            private let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 320, height: 480))

            init(state: BarcodeScanner.State) {
                host = UIHostingController(rootView: BarcodeScanner(result: .constant(nil), state: state))
                window.rootViewController = host
                window.makeKeyAndVisible()
                host.view.layoutIfNeeded()
            }

            var controller: BarcodeScannerViewController? {
                host.children.compactMap { $0 as? BarcodeScannerViewController }.first
            }

            func update(state: BarcodeScanner.State) {
                host.rootView = BarcodeScanner(result: .constant(nil), state: state)
                host.view.setNeedsLayout()
                host.view.layoutIfNeeded()
            }
        }
    #endif

#endif
