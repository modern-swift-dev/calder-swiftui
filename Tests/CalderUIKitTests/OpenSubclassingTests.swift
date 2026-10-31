#if canImport(UIKit) && canImport(WebKit) && !os(watchOS)
    // A plain (non-@testable) import checks the access levels clients see: overriding a `public` member from
    // another module doesn't compile.
    import CalderUIKit
    import Foundation
    import Testing
    import UIKit
    import WebKit

    @MainActor struct OpenSubclassingTests {

        #if os(iOS) || targetEnvironment(macCatalyst) || os(tvOS) || os(visionOS)
            private final class RecordingUIKitSceneDelegate: UIKitSceneDelegate {
                private(set) var didConnect = false

                override func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
                    didConnect = true
                    super.scene(scene, willConnectTo: session, options: connectionOptions)
                }
            }

            @Test func `UIKit scene delegate scene connection is overridable`() {
                let delegate = RecordingUIKitSceneDelegate()
                #expect(!delegate.didConnect)
            }

            #if canImport(SwiftUI)
                private final class RecordingSwiftUISceneDelegate: SwiftUISceneDelegate {
                    private(set) var didConnect = false

                    override func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
                        didConnect = true
                        super.scene(scene, willConnectTo: session, options: connectionOptions)
                    }
                }

                @Test func `SwiftUI scene delegate scene connection is overridable`() {
                    let delegate = RecordingSwiftUISceneDelegate()
                    #expect(!delegate.didConnect)
                }
            #endif
        #endif

        private final class FixedSizeWebView: SelfSizingWebView {
            override var intrinsicContentSize: CGSize {
                CGSize(width: 10, height: 20)
            }
        }

        @Test func `self sizing web view is subclassable and its intrinsic size is overridable`() {
            let webView = FixedSizeWebView(frame: .zero, configuration: WKWebViewConfiguration())
            #expect(webView.intrinsicContentSize == CGSize(width: 10, height: 20))
        }
    }
#endif
