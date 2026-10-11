#if canImport(SwiftUI) || canImport(UIKit) || canImport(AppKit)
    #if os(iOS)
        import AVFoundation
        @testable import CalderTheme
        import Testing
        import UIKit

        @Suite(.serialized)
        @MainActor struct BarcodeScannerViewControllerTests {

            @Test func `only the first of several codes in frame is delivered`() {
                let controller = BarcodeScannerViewController()
                var delivered: [String] = []
                controller.callback = { code, _ in delivered.append(code) }

                controller.barcodeScanner.deliverScannedCode("first", type: .qr, rect: .zero, path: UIBezierPath())
                controller.barcodeScanner.deliverScannedCode("second", type: .qr, rect: .zero, path: UIBezierPath())

                #expect(delivered == ["first"])
                #expect(controller.barcodeScanner.isSuspended)
            }

            @Test func `undetermined permission prompts the user`() async throws {
                let access = FakeCameraAccess(status: .notDetermined, grantsAccess: true)
                let controller = BarcodeScannerViewController()
                controller.cameraAccess = access.access

                let window = present(controller)
                try await waitUntil { access.requestCount == 1 && access.status == .authorized }

                #expect(access.requestCount == 1)
                #expect(controller.unavailableReason == nil)
                window.isHidden = true
            }

            @Test(arguments: [AVAuthorizationStatus.denied, .restricted])
            func `denied permission shows the settings message`(status: AVAuthorizationStatus) {
                let access = FakeCameraAccess(status: status, grantsAccess: false)
                let controller = BarcodeScannerViewController()
                controller.cameraAccess = access.access

                let window = present(controller)

                #expect(controller.unavailableReason == .permissionDenied)
                #expect(access.requestCount == 0)
                window.isHidden = true
            }

            @Test func `declining the prompt shows the settings message`() async throws {
                let access = FakeCameraAccess(status: .notDetermined, grantsAccess: false)
                let controller = BarcodeScannerViewController()
                controller.cameraAccess = access.access

                let window = present(controller)
                try await waitUntil { controller.unavailableReason != nil }

                #expect(controller.unavailableReason == .permissionDenied)
                window.isHidden = true
            }

            @Test func `granting permission later resumes scanning`() {
                let access = FakeCameraAccess(status: .denied, grantsAccess: false)
                let controller = BarcodeScannerViewController()
                controller.cameraAccess = access.access
                let window = present(controller)
                #expect(controller.unavailableReason == .permissionDenied)

                access.status = .authorized
                NotificationCenter.default.post(name: UIApplication.didBecomeActiveNotification, object: nil)

                #expect(controller.unavailableReason == nil)
                window.isHidden = true
            }

            @Test func `missing camera shows the unsupported message without prompting`() {
                let access = FakeCameraAccess(status: .notDetermined, grantsAccess: true, hasCamera: false)
                let controller = BarcodeScannerViewController()
                controller.cameraAccess = access.access

                let window = present(controller)

                #expect(controller.unavailableReason == .unsupported)
                #expect(access.requestCount == 0)
                window.isHidden = true
            }

            private func present(_ controller: UIViewController) -> UIWindow {
                let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 320, height: 480))
                window.rootViewController = controller
                window.makeKeyAndVisible()
                controller.view.layoutIfNeeded()
                return window
            }

            private func waitUntil(_ condition: () -> Bool) async throws {
                for _ in 0 ..< 100 where !condition() {
                    try await Task.sleep(for: .milliseconds(10))
                }
                try #require(condition())
            }

            /// A camera-access fake whose authorization status the test controls.
            @MainActor private final class FakeCameraAccess {
                var status: AVAuthorizationStatus
                let grantsAccess: Bool
                let hasCamera: Bool
                private(set) var requestCount = 0

                init(status: AVAuthorizationStatus, grantsAccess: Bool, hasCamera: Bool = true) {
                    self.status = status
                    self.grantsAccess = grantsAccess
                    self.hasCamera = hasCamera
                }

                var access: BarcodeScannerCameraAccess {
                    BarcodeScannerCameraAccess(
                        isCameraAvailable: { self.hasCamera },
                        authorizationStatus: { self.status },
                        requestAccess: {
                            self.requestCount += 1
                            self.status = self.grantsAccess ? .authorized : .denied
                            return self.grantsAccess
                        }
                    )
                }
            }
        }
    #endif

#endif
