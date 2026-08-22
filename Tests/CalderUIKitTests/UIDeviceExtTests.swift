#if canImport(SwiftUI) || canImport(UIKit) || canImport(AppKit)
#if canImport(UIKit) && !os(watchOS)
import CalderUIKit
import Foundation
import Testing
import UIKit

@Suite(.serialized)
@MainActor struct UIDeviceExtTests {

    // MARK: - Interface Type Tests

    @Test func `interface type returns current idiom`() {
        let idiom = UIDevice.interfaceType()
        let expected = UIDevice.current.userInterfaceIdiom
        #expect(idiom == expected)
    }

    // MARK: - Device Type Boolean Tests

    @Test func `is phone matches interface type`() {
        let result = UIDevice.isPhone
        let expected = UIDevice.interfaceType() == .phone
        #expect(result == expected)
    }

    @Test func `is pad matches interface type`() {
        let result = UIDevice.isPad
        let expected = UIDevice.interfaceType() == .pad
        #expect(result == expected)
    }

    @Test func `is TV matches interface type`() {
        let result = UIDevice.isTV
        let expected = UIDevice.interfaceType() == .tv
        #expect(result == expected)
    }

    @Test func `is car matches interface type`() {
        let result = UIDevice.isCar
        let expected = UIDevice.interfaceType() == .carPlay
        #expect(result == expected)
    }

    // MARK: - Environment Tests

    @Test func `is catalyst returns correct value`() {
        let result = UIDevice.isCatalyst
        #if targetEnvironment(macCatalyst)
        #expect(result == true)
        #else
        #expect(result == false)
        #endif
    }

    @Test func `is simulator returns correct value`() {
        let result = UIDevice.isSimulator
        #if targetEnvironment(simulator)
        #expect(result == true)
        #else
        #expect(result == false)
        #endif
    }

    // MARK: - Mutual Exclusivity Tests

    @Test func `device types are mutually exclusive`() {
        let types = [
            UIDevice.isPhone,
            UIDevice.isPad,
            UIDevice.isTV,
            UIDevice.isCar
        ]
        let trueCount = types.count(where: { $0 })
        #expect(trueCount <= 1)
    }

    @Test func `all device type properties are accessible`() {
        _ = UIDevice.isPhone
        _ = UIDevice.isPad
        _ = UIDevice.isTV
        _ = UIDevice.isCar
        _ = UIDevice.isCatalyst
        _ = UIDevice.isSimulator
        #expect(true)
    }
}
#endif

#endif
