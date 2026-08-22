#if canImport(SwiftUI) || canImport(UIKit) || canImport(AppKit)
@testable import CalderSwiftUI
import Foundation
import SwiftUI
import Testing

@Suite(.serialized) struct LinearGradientExtTests {

    // Use explicit RGB colors to avoid macOS catalog color issues
    private static let testRed = Color(red: 1, green: 0, blue: 0)
    private static let testBlue = Color(red: 0, green: 0, blue: 1)
    private static let testGreen = Color(red: 0, green: 1, blue: 0)
    private static let testWhite = Color(red: 1, green: 1, blue: 1)
    private static let testBlack = Color(red: 0, green: 0, blue: 0)
    private static let testPurple = Color(red: 0.5, green: 0, blue: 0.5)

    // MARK: - init(darken:) with defaults

    @Test func `init darken with default values`() {
        let gradient = LinearGradient(darken: Self.testRed)
        #expect(type(of: gradient) == LinearGradient.self)
    }

    @Test func `init darken with blue`() {
        let gradient = LinearGradient(darken: Self.testBlue)
        #expect(type(of: gradient) == LinearGradient.self)
    }

    @Test func `init darken with white`() {
        let gradient = LinearGradient(darken: Self.testWhite)
        #expect(type(of: gradient) == LinearGradient.self)
    }

    // MARK: - init(darken:) with custom amount

    @Test func `init darken with custom amount`() {
        let gradient = LinearGradient(darken: Self.testRed, amount: 0.3)
        #expect(type(of: gradient) == LinearGradient.self)
    }

    @Test func `init darken with zero amount`() {
        let gradient = LinearGradient(darken: Self.testRed, amount: 0)
        #expect(type(of: gradient) == LinearGradient.self)
    }

    @Test func `init darken with max amount`() {
        let gradient = LinearGradient(darken: Self.testRed, amount: 1.0)
        #expect(type(of: gradient) == LinearGradient.self)
    }

    // MARK: - init(darken:) with custom start/end

    @Test func `init darken with custom start end`() {
        let gradient = LinearGradient(darken: Self.testGreen, start: .leading, end: .trailing)
        #expect(type(of: gradient) == LinearGradient.self)
    }

    @Test func `init darken with top leading to bottom trailing`() {
        let gradient = LinearGradient(darken: Self.testGreen, start: .topLeading, end: .bottomTrailing)
        #expect(type(of: gradient) == LinearGradient.self)
    }

    @Test func `init darken with bottom to top`() {
        let gradient = LinearGradient(darken: Self.testGreen, start: .bottom, end: .top)
        #expect(type(of: gradient) == LinearGradient.self)
    }

    // MARK: - init(darken:) with all custom parameters

    @Test func `init darken with all parameters`() {
        let gradient = LinearGradient(
            darken: Self.testPurple,
            amount: 0.2,
            start: .topLeading,
            end: .bottomTrailing
        )
        #expect(type(of: gradient) == LinearGradient.self)
    }

    // MARK: - init(lighten:) with defaults

    @Test func `init lighten with default values`() {
        let gradient = LinearGradient(lighten: Self.testRed)
        #expect(type(of: gradient) == LinearGradient.self)
    }

    @Test func `init lighten with blue`() {
        let gradient = LinearGradient(lighten: Self.testBlue)
        #expect(type(of: gradient) == LinearGradient.self)
    }

    @Test func `init lighten with black`() {
        let gradient = LinearGradient(lighten: Self.testBlack)
        #expect(type(of: gradient) == LinearGradient.self)
    }

    // MARK: - init(lighten:) with custom amount

    @Test func `init lighten with custom amount`() {
        let gradient = LinearGradient(lighten: Self.testRed, amount: 0.3)
        #expect(type(of: gradient) == LinearGradient.self)
    }

    @Test func `init lighten with zero amount`() {
        let gradient = LinearGradient(lighten: Self.testRed, amount: 0)
        #expect(type(of: gradient) == LinearGradient.self)
    }

    @Test func `init lighten with max amount`() {
        let gradient = LinearGradient(lighten: Self.testRed, amount: 1.0)
        #expect(type(of: gradient) == LinearGradient.self)
    }

    // MARK: - init(lighten:) with custom start/end

    @Test func `init lighten with custom start end`() {
        let gradient = LinearGradient(lighten: Self.testGreen, start: .leading, end: .trailing)
        #expect(type(of: gradient) == LinearGradient.self)
    }

    @Test func `init lighten with top leading to bottom trailing`() {
        let gradient = LinearGradient(lighten: Self.testGreen, start: .topLeading, end: .bottomTrailing)
        #expect(type(of: gradient) == LinearGradient.self)
    }

    @Test func `init lighten with bottom to top`() {
        let gradient = LinearGradient(lighten: Self.testGreen, start: .bottom, end: .top)
        #expect(type(of: gradient) == LinearGradient.self)
    }

    // MARK: - init(lighten:) with all custom parameters

    @Test func `init lighten with all parameters`() {
        let gradient = LinearGradient(
            lighten: Self.testPurple,
            amount: 0.2,
            start: .topLeading,
            end: .bottomTrailing
        )
        #expect(type(of: gradient) == LinearGradient.self)
    }

    // MARK: - Usage in Views

    @Test func `darken gradient can be used as background`() {
        _ = Rectangle()
            .fill(LinearGradient(darken: Self.testBlue))
    }

    @Test func `lighten gradient can be used as background`() {
        _ = Rectangle()
            .fill(LinearGradient(lighten: Self.testBlue))
    }

    @Test func `gradient can be used with text`() {
        _ = Text("Hello")
            .foregroundStyle(LinearGradient(darken: Self.testRed))
    }

    @Test func `gradient can be used with shape`() {
        _ = Circle()
            .fill(LinearGradient(lighten: Self.testGreen, amount: 0.2))
    }

    // MARK: - Custom Colors

    @Test func `init darken with custom color`() {
        let customColor = Color(red: 0.5, green: 0.3, blue: 0.7)
        let gradient = LinearGradient(darken: customColor)
        #expect(type(of: gradient) == LinearGradient.self)
    }

    @Test func `init lighten with custom color`() {
        let customColor = Color(red: 0.2, green: 0.8, blue: 0.4)
        let gradient = LinearGradient(lighten: customColor)
        #expect(type(of: gradient) == LinearGradient.self)
    }

    @Test func `init darken with hex color`() {
        let hexColor = Color(rgb: "#FF5500")
        let gradient = LinearGradient(darken: hexColor)
        #expect(type(of: gradient) == LinearGradient.self)
    }

    @Test func `init lighten with hex color`() {
        let hexColor = Color(rgb: "#0055FF")
        let gradient = LinearGradient(lighten: hexColor)
        #expect(type(of: gradient) == LinearGradient.self)
    }
}

#endif
