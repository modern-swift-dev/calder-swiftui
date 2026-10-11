#if os(iOS)
    import Foundation
    import SwiftUI
    import UIKit

    /// Hosts a SwiftUI view and collects the accessibility elements VoiceOver would see.
    ///
    /// SwiftUI only builds its accessibility tree while accessibility is active, so the helper
    /// enables it for the test process through `libAccessibility`, as accessibility snapshot tools do.
    @MainActor enum AccessibilityTree {
        /// A flattened accessibility element.
        struct Element {
            let label: String?
            let value: String?
            let traits: UIAccessibilityTraits
            let expandedStatus: UIAccessibility.ExpandedStatus
        }

        /// Returns the accessibility elements exposed by `view`, in traversal order.
        /// - Parameter view: The view to host in a window.
        /// - Returns: Every element whose `isAccessibilityElement` is `true`.
        static func elements(of view: some View) -> [Element] {
            enableAccessibility()
            let controller = UIHostingController(rootView: view)
            let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 390, height: 400))
            window.rootViewController = controller
            window.makeKeyAndVisible()
            controller.view.layoutIfNeeded()
            defer { window.isHidden = true }

            var result: [Element] = []
            collect(controller.view, into: &result)
            return result
        }

        private static func collect(_ object: NSObject, into result: inout [Element]) {
            if object.isAccessibilityElement {
                result.append(
                    Element(
                        label: object.accessibilityLabel,
                        value: object.accessibilityValue,
                        traits: object.accessibilityTraits,
                        expandedStatus: object.accessibilityExpandedStatus
                    )
                )
            }
            if let elements = object.accessibilityElements {
                for case let child as NSObject in elements {
                    collect(child, into: &result)
                }
            } else {
                let count = object.accessibilityElementCount()
                if count != NSNotFound {
                    for index in 0 ..< count {
                        if let child = object.accessibilityElement(at: index) as? NSObject {
                            collect(child, into: &result)
                        }
                    }
                }
            }
            if let view = object as? UIView {
                for subview in view.subviews {
                    collect(subview, into: &result)
                }
            }
        }

        private static func enableAccessibility() {
            let root = ProcessInfo.processInfo.environment["IPHONE_SIMULATOR_ROOT"] ?? ""
            guard let handle = dlopen(root + "/usr/lib/libAccessibility.dylib", RTLD_NOW),
                  let symbol = dlsym(handle, "_AXSApplicationAccessibilitySetEnabled") else {
                return
            }
            typealias SetEnabled = @convention(c) (Int32) -> Void
            unsafeBitCast(symbol, to: SetEnabled.self)(1)
        }
    }
#endif
