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
    static var isCar: Bool {
        interfaceType() == .carPlay
    }

    /// A boolean indicating if the device is running on a Mac Catalyst build (i.e., UIKit on macOS).
    static var isCatalyst: Bool {
        #if targetEnvironment(macCatalyst)
        return true
        #else
        return false
        #endif
    }

    /// A boolean indicating if the device is a simulator.
    static var isSimulator: Bool {
        #if targetEnvironment(simulator)
        return true
        #else
        return false
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
