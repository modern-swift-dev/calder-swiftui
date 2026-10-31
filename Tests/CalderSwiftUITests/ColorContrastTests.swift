#if canImport(SwiftUI)
    @testable import CalderSwiftUI
    import Foundation
    import SwiftUI
    import Testing

    struct ColorContrastTests {

        private func hex(_ value: UInt32) -> Color {
            Color(
                .sRGB,
                red: Double((value >> 16) & 0xFF) / 255,
                green: Double((value >> 8) & 0xFF) / 255,
                blue: Double(value & 0xFF) / 255
            )
        }

        private func isEqual(_ lhs: Double, _ rhs: Double, accuracy: Double = 0.005) -> Bool {
            abs(lhs - rhs) < accuracy
        }

        @Test func `black against white is 21`() {
            #expect(isEqual(hex(0x000000).contrastRatio(with: hex(0xFFFFFF)), 21))
        }

        @Test func `identical colours have a ratio of 1`() {
            #expect(isEqual(hex(0x336699).contrastRatio(with: hex(0x336699)), 1))
        }

        @Test func `ratio is symmetric`() {
            let forward = hex(0x0000FF).contrastRatio(with: hex(0xFFFFFF))
            let backward = hex(0xFFFFFF).contrastRatio(with: hex(0x0000FF))
            #expect(isEqual(forward, backward, accuracy: 0.000_001))
        }

        @Test(arguments: [
            (UInt32(0x767676), UInt32(0xFFFFFF), 4.54),
            (UInt32(0x777777), UInt32(0xFFFFFF), 4.48),
            (UInt32(0x0000FF), UInt32(0xFFFFFF), 8.59),
            (UInt32(0xFF0000), UInt32(0xFFFFFF), 4.00),
            (UInt32(0xFF0000), UInt32(0x000000), 5.25)
        ])
        func `known WCAG reference pairs match to two decimals`(first: UInt32, second: UInt32, expected: Double) {
            #expect(isEqual(hex(first).contrastRatio(with: hex(second)), expected))
        }

        @Test func `higher contrast candidate wins`() {
            // Red has a ratio of 5.25 against black and 4.00 against white, so black wins even though
            // the colour's luma is below one half.
            #expect(hex(0xFF0000).higherContrast(light: .white, dark: .black, in: EnvironmentValues()) == .black)
            #expect(hex(0x0000FF).higherContrast(light: .white, dark: .black, in: EnvironmentValues()) == .white)
        }

        @Test func `higher contrast honours custom candidates`() {
            let yellow = hex(0xFFFF00)
            let result = hex(0xFF0000).higherContrast(light: yellow, dark: hex(0x0000FF), in: EnvironmentValues())
            #expect(result == yellow)
        }

        @Test func `contrasting text colour returns a Color`() {
            let result: Color = hex(0xFF0000).contrastingTextColor()
            #expect(result == .black)
            #expect(hex(0xFFFFFF).contrastingTextColor(light: .white, dark: .black) == .black)
            #expect(hex(0x000000).contrastingTextColor(light: .white, dark: .black) == .white)
        }

        @Test func `contrasting text colour honours custom candidates and environment`() {
            let yellow = hex(0xFFFF00)
            let blue = hex(0x0000FF)
            #expect(hex(0xFF0000).contrastingTextColor(light: yellow, dark: blue, in: EnvironmentValues()) == yellow)
        }

        @Test func `text colour follows the contrasting text colour`() {
            #expect(hex(0xFF0000).textColor == .black)
            #expect(hex(0x000080).textColor == .white)
        }
    }
#endif
