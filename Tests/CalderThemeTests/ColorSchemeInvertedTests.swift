#if canImport(SwiftUI) || canImport(UIKit) || canImport(AppKit)
@testable import CalderTheme
import Foundation
import SwiftUI
import Testing

@Suite(.serialized) struct ColorSchemeInvertedTests {

    @Test func `light inverts to dark`() {
        let scheme: ColorScheme = .light
        let inverted = scheme.inverted
        #expect(inverted == .dark)
    }

    @Test func `dark inverts to light`() {
        let scheme: ColorScheme = .dark
        let inverted = scheme.inverted
        #expect(inverted == .light)
    }

    @Test func `double invert returns original`() {
        let light: ColorScheme = .light
        let dark: ColorScheme = .dark

        #expect(light.inverted.inverted == .light)
        #expect(dark.inverted.inverted == .dark)
    }
}

#endif
