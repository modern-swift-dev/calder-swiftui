#if canImport(Darwin)
    #if canImport(UIKit) && !os(watchOS)
        import Foundation
        import UIKit

        public extension UIDevice {
            /// A boolean indicating if the device is an iPhone.
            static var isPhone: Bool {
                interfaceType() == .phone
            }

            /// A boolean indicating if the device is an iPad.
            static var isPad: Bool {
                interfaceType() == .pad
            }

            /// A boolean indicating if the device is an Apple TV.
            static var isTV: Bool {
                interfaceType() == .tv
            }

            /// A boolean indicating if the device is a CarPlay unit.
            ///
            /// This is always `false`: `UIDevice.current.userInterfaceIdiom` never reports `.carPlay`. Read
            /// `traitCollection.userInterfaceIdiom` from a CarPlay scene's view controller or screen instead.
            @available(*, deprecated, message: "UIDevice.current.userInterfaceIdiom never reports .carPlay, so this is always false. Check traitCollection.userInterfaceIdiom == .carPlay instead.")
            static var isCar: Bool {
                interfaceType() == .carPlay
            }

            /// A boolean indicating if the app is running on a Mac Catalyst build (i.e., UIKit on macOS).
            ///
            /// This is the single spelling for the check; `UIApplication.isMacCatalyst` is deprecated.
            static var isCatalyst: Bool {
                #if targetEnvironment(macCatalyst)
                    true
                #else
                    false
                #endif
            }

            /// A boolean indicating if the app is running on a simulator.
            ///
            /// This is the single spelling for the check; `UIApplication.isSimulator` is deprecated.
            static var isSimulator: Bool {
                #if targetEnvironment(simulator)
                    true
                #else
                    false
                #endif
            }

            /// Returns the current user interface idiom of the device.
            /// - Returns: The `UIUserInterfaceIdiom` of the device.
            static func interfaceType() -> UIUserInterfaceIdiom {
                UIDevice.current.userInterfaceIdiom
            }
        }
    #endif

#endif
