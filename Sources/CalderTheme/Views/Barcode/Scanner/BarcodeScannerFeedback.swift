#if canImport(UIKit) && canImport(Vision) && !os(visionOS) && !os(watchOS)
    import UIKit

    /// The feedback ``BarcodeScannerView`` gives when it reads a code.
    struct BarcodeScannerFeedback {
        /// Plays a haptic that confirms a scan, where the device has a haptic engine.
        var haptic: @MainActor () -> Void

        /// Posts a VoiceOver announcement.
        var announce: @MainActor (String) -> Void

        /// Feedback through UIKit's feedback generator and VoiceOver.
        static let live = BarcodeScannerFeedback(
            haptic: {
                #if !os(tvOS)
                    UINotificationFeedbackGenerator().notificationOccurred(.success)
                #endif
            },
            announce: { message in
                UIAccessibility.post(notification: .announcement, argument: message)
            }
        )
    }
#endif
