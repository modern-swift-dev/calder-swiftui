#if canImport(SwiftUI) || canImport(UIKit) || canImport(AppKit)
    #if os(iOS)
        import AVFoundation
        @testable import CalderTheme
        import SwiftUI
        import Testing
        import UIKit

        @Suite(.serialized)
        @MainActor struct BarcodeScannerFeedbackTests {
            /// Records the feedback a scanner gives.
            @MainActor private final class Recorder {
                var hapticCount = 0
                var announcements: [String] = []

                var feedback: BarcodeScannerFeedback {
                    BarcodeScannerFeedback(
                        haptic: { self.hapticCount += 1 },
                        announce: { self.announcements.append($0) }
                    )
                }
            }

            private func makeView(haptic: Bool = true, announce: Bool = true, recorder: Recorder) -> BarcodeScannerView {
                let view = BarcodeScannerView(model: .init(crossHairImage: UIImage(), providesHapticFeedback: haptic, announcesScannedCode: announce))
                view.feedback = recorder.feedback
                return view
            }

            private func deliver(_ code: String, in view: BarcodeScannerView) {
                view.deliverScannedCode(code, type: .qr, rect: .zero, path: UIBezierPath())
            }

            @Test func `feedback is on by default`() {
                let model = BarcodeScannerView.Model()

                #expect(model.providesHapticFeedback)
                #expect(model.announcesScannedCode)
            }

            @Test func `a scan plays a haptic and announces the code`() {
                let recorder = Recorder()
                let view = makeView(recorder: recorder)

                deliver("4006381333931", in: view)

                #expect(recorder.hapticCount == 1)
                #expect(recorder.announcements == ["Scanned 4006381333931"])
            }

            @Test func `every scan gives feedback`() {
                let recorder = Recorder()
                let view = makeView(recorder: recorder)

                deliver("a", in: view)
                deliver("b", in: view)

                #expect(recorder.hapticCount == 2)
                #expect(recorder.announcements == ["Scanned a", "Scanned b"])
            }

            @Test func `the haptic can be turned off`() {
                let recorder = Recorder()
                let view = makeView(haptic: false, recorder: recorder)

                deliver("a", in: view)

                #expect(recorder.hapticCount == 0)
                #expect(recorder.announcements == ["Scanned a"])
            }

            @Test func `the announcement can be turned off`() {
                let recorder = Recorder()
                let view = makeView(announce: false, recorder: recorder)

                deliver("a", in: view)

                #expect(recorder.hapticCount == 1)
                #expect(recorder.announcements.isEmpty)
            }

            @Test func `a suspended scanner gives no feedback`() {
                let recorder = Recorder()
                let view = makeView(recorder: recorder)
                view.suspend()

                deliver("a", in: view)

                #expect(recorder.hapticCount == 0)
                #expect(recorder.announcements.isEmpty)
            }

            @Test func `the live feedback is safe to use`() {
                let feedback = BarcodeScannerFeedback.live

                feedback.haptic()
                feedback.announce("Scanned a")
            }

            @Test(arguments: [(true, true), (false, true), (true, false), (false, false)])
            func `the SwiftUI scanner passes its feedback options on`(haptic: Bool, announce: Bool) throws {
                let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 320, height: 480))
                let host = UIHostingController(rootView: BarcodeScanner(
                    result: .constant(nil),
                    state: .scanning,
                    hapticFeedback: haptic,
                    announcesScans: announce
                ))
                window.rootViewController = host
                window.makeKeyAndVisible()
                defer { window.isHidden = true }
                host.view.layoutIfNeeded()
                let controller = try #require(host.children.compactMap { $0 as? BarcodeScannerViewController }.first)
                let recorder = Recorder()
                controller.barcodeScanner.feedback = recorder.feedback

                deliver("a", in: controller.barcodeScanner)

                #expect(recorder.hapticCount == (haptic ? 1 : 0))
                #expect(recorder.announcements == (announce ? ["Scanned a"] : []))
            }

            @Test(arguments: [true, false])
            func `the continuous SwiftUI scanner passes its feedback options on`(enabled: Bool) throws {
                let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 320, height: 480))
                let host = UIHostingController(rootView: BarcodeScanner(state: .scanning, hapticFeedback: enabled, announcesScans: enabled) { _ in })
                window.rootViewController = host
                window.makeKeyAndVisible()
                defer { window.isHidden = true }
                host.view.layoutIfNeeded()
                let controller = try #require(host.children.compactMap { $0 as? BarcodeScannerViewController }.first)
                let recorder = Recorder()
                controller.barcodeScanner.feedback = recorder.feedback

                deliver("a", in: controller.barcodeScanner)

                #expect(recorder.hapticCount == (enabled ? 1 : 0))
                #expect(recorder.announcements.count == (enabled ? 1 : 0))
            }
        }
    #endif

#endif
