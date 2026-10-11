#if canImport(SwiftUI) || canImport(UIKit) || canImport(AppKit)
    @testable import CalderSwiftUI
    import Foundation
    import SwiftUI
    import Testing

    #if canImport(UIKit)
        import UIKit
    #elseif canImport(AppKit)
        import AppKit
    #endif

    struct ColorHexTests {

        // MARK: - Helper to extract RGB components

        #if canImport(UIKit)
            private func getRGBComponents(_ color: Color) -> (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
                let uiColor = UIColor(color)
                var r: CGFloat = 0
                var g: CGFloat = 0
                var b: CGFloat = 0
                var a: CGFloat = 0
                uiColor.getRed(&r, green: &g, blue: &b, alpha: &a)
                return (r, g, b, a)
            }

        #elseif canImport(AppKit)
            private func getRGBComponents(_ color: Color) -> (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
                let nsColor = NSColor(color).usingColorSpace(.sRGB) ?? NSColor(color)
                var r: CGFloat = 0
                var g: CGFloat = 0
                var b: CGFloat = 0
                var a: CGFloat = 0
                nsColor.getRed(&r, green: &g, blue: &b, alpha: &a)
                return (r, g, b, a)
            }
        #endif

        private func assertColorEquals(
            _ color: Color?,
            red: CGFloat,
            green: CGFloat,
            blue: CGFloat,
            alpha: CGFloat = 1.0,
            accuracy: CGFloat = 0.01,
            sourceLocation: SourceLocation = #_sourceLocation
        ) {
            guard let color else {
                Issue.record("Expected a color, got nil", sourceLocation: sourceLocation)
                return
            }
            let components = getRGBComponents(color)
            #expect(abs(components.red - red) < accuracy)
            #expect(abs(components.green - green) < accuracy)
            #expect(abs(components.blue - blue) < accuracy)
            #expect(abs(components.alpha - alpha) < accuracy)
        }

        // MARK: - init(rgb:) with hash prefix

        @Test func `init RGB with hash prefix black`() {
            let color = Color(rgb: "#000000")
            assertColorEquals(color, red: 0, green: 0, blue: 0)
        }

        @Test func `init RGB with hash prefix white`() {
            let color = Color(rgb: "#FFFFFF")
            assertColorEquals(color, red: 1, green: 1, blue: 1)
        }

        @Test func `init RGB with hash prefix red`() {
            let color = Color(rgb: "#FF0000")
            assertColorEquals(color, red: 1, green: 0, blue: 0)
        }

        @Test func `init RGB with hash prefix green`() {
            let color = Color(rgb: "#00FF00")
            assertColorEquals(color, red: 0, green: 1, blue: 0)
        }

        @Test func `init RGB with hash prefix blue`() {
            let color = Color(rgb: "#0000FF")
            assertColorEquals(color, red: 0, green: 0, blue: 1)
        }

        @Test func `init RGB with hash prefix mixed color`() {
            let color = Color(rgb: "#AABBCC")
            assertColorEquals(color, red: 170.0 / 255.0, green: 187.0 / 255.0, blue: 204.0 / 255.0)
        }

        // MARK: - init(rgb:) with 0x prefix

        @Test func `init RGB with 0 x prefix black`() {
            let color = Color(rgb: "0x000000")
            assertColorEquals(color, red: 0, green: 0, blue: 0)
        }

        @Test func `init RGB with 0 x prefix white`() {
            let color = Color(rgb: "0xFFFFFF")
            assertColorEquals(color, red: 1, green: 1, blue: 1)
        }

        @Test func `init RGB with 0 x prefix red`() {
            let color = Color(rgb: "0xFF0000")
            assertColorEquals(color, red: 1, green: 0, blue: 0)
        }

        // MARK: - init(rgb:) without prefix

        @Test func `init RGB without prefix black`() {
            let color = Color(rgb: "000000")
            assertColorEquals(color, red: 0, green: 0, blue: 0)
        }

        @Test func `init RGB without prefix white`() {
            let color = Color(rgb: "FFFFFF")
            assertColorEquals(color, red: 1, green: 1, blue: 1)
        }

        // MARK: - init(rgb:) edge cases

        @Test(arguments: ["#FFF", "", "#", "0x", "#FFFFFFFF", "FFFFF", "1234567"])
        func `init RGB with invalid length returns nil`(_ hex: String) {
            #expect(Color(rgb: hex) == nil)
        }

        @Test(arguments: ["#GGHHII", "#12345G", "0x12345Z", "+12345", "-12345", "#+1234F", "0x0x1234", "#0x1234", "##123456"])
        func `init RGB with invalid digits returns nil`(_ hex: String) {
            #expect(Color(rgb: hex) == nil)
        }

        @Test(arguments: [" #AABBCC", "#AABBCC ", "#AABBCC\n", "#AA BBCC", "\t0xAABBCC"])
        func `init RGB rejects whitespace`(_ hex: String) {
            #expect(Color(rgb: hex) == nil)
        }

        @Test func `init RGB with uppercase 0 X prefix`() {
            assertColorEquals(Color(rgb: "0XAABBCC"), red: 170.0 / 255.0, green: 187.0 / 255.0, blue: 204.0 / 255.0)
        }

        @Test func `init RGB with lowercase hex`() {
            let color = Color(rgb: "#aabbcc")
            assertColorEquals(color, red: 170.0 / 255.0, green: 187.0 / 255.0, blue: 204.0 / 255.0)
        }

        // MARK: - init(rgba:) with hash prefix

        @Test func `init RGBA with hash prefix full opacity`() {
            let color = Color(rgba: "#FF0000FF")
            #expect(color != nil)
            if let color {
                assertColorEquals(color, red: 1, green: 0, blue: 0, alpha: 1)
            }
        }

        @Test func `init RGBA with hash prefix half opacity`() {
            let color = Color(rgba: "#FF000080")
            #expect(color != nil)
            if let color {
                assertColorEquals(color, red: 1, green: 0, blue: 0, alpha: 128.0 / 255.0)
            }
        }

        @Test func `init RGBA with hash prefix zero opacity`() {
            let color = Color(rgba: "#FF000000")
            #expect(color != nil)
            if let color {
                assertColorEquals(color, red: 1, green: 0, blue: 0, alpha: 0)
            }
        }

        @Test func `init RGBA with hash prefix white full opacity`() {
            let color = Color(rgba: "#FFFFFFFF")
            #expect(color != nil)
            if let color {
                assertColorEquals(color, red: 1, green: 1, blue: 1, alpha: 1)
            }
        }

        // MARK: - init(rgba:) with 0x prefix

        @Test func `init RGBA with 0 x prefix full opacity`() {
            let color = Color(rgba: "0x00FF00FF")
            #expect(color != nil)
            if let color {
                assertColorEquals(color, red: 0, green: 1, blue: 0, alpha: 1)
            }
        }

        // MARK: - init(rgba:) without prefix

        @Test func `init RGBA without prefix full opacity`() {
            let color = Color(rgba: "0000FFFF")
            #expect(color != nil)
            if let color {
                assertColorEquals(color, red: 0, green: 0, blue: 1, alpha: 1)
            }
        }

        // MARK: - init(rgba:) edge cases

        @Test(arguments: ["#FFFFFF", "", "#", "0x", "#FFFFFFFFFF", "FFFFFFF", "123456789"])
        func `init RGBA with invalid length returns nil`(_ hex: String) {
            #expect(Color(rgba: hex) == nil)
        }

        @Test(arguments: ["#GGHHIIJJ", "#1234567G", "0x1234567Z", "+1234567", "-1234567", "#0x123456", "##1234567"])
        func `init RGBA with invalid digits returns nil`(_ hex: String) {
            #expect(Color(rgba: hex) == nil)
        }

        @Test(arguments: [" #AABBCCDD", "#AABBCCDD ", "#AABB CCDD"])
        func `init RGBA rejects whitespace`(_ hex: String) {
            #expect(Color(rgba: hex) == nil)
        }

        @Test func `init RGBA with uppercase 0 X prefix`() {
            assertColorEquals(Color(rgba: "0XAABBCCDD"), red: 170.0 / 255.0, green: 187.0 / 255.0, blue: 204.0 / 255.0, alpha: 221.0 / 255.0)
        }

        @Test func `init RGBA with lowercase hex`() {
            let color = Color(rgba: "#aabbccdd")
            #expect(color != nil)
            if let color {
                assertColorEquals(color, red: 170.0 / 255.0, green: 187.0 / 255.0, blue: 204.0 / 255.0, alpha: 221.0 / 255.0)
            }
        }

        // MARK: - Round trips

        #if canImport(UIKit) || canImport(AppKit)
            @Test(arguments: 0 ... 255)
            func `rgb round trips every grey level`(_ level: Int) throws {
                let hex = String(format: "#%02X%02X%02X", level, level, level)
                #expect(try #require(Color(rgb: hex)).rgb == hex)
            }

            @Test(arguments: ["#000000", "#FFFFFF", "#090909", "#336699", "#AB12CD", "#FF5500", "#0055FF", "#7F8081", "#123456", "#FEDCBA"])
            func `rgb round trips sample colors`(_ hex: String) throws {
                #expect(try #require(Color(rgb: hex)).rgb == hex)
            }

            @Test(arguments: 0 ... 255)
            func `rgba round trips every alpha level`(_ level: Int) throws {
                let hex = String(format: "#336699%02X", level)
                #expect(try #require(Color(rgba: hex)).rgba == hex)
            }
        #endif

        // MARK: - Specific color values

        @Test func `init RGB with mid gray`() {
            let color = Color(rgb: "#808080")
            assertColorEquals(color, red: 128.0 / 255.0, green: 128.0 / 255.0, blue: 128.0 / 255.0)
        }

        @Test func `init RGB with cyan`() {
            let color = Color(rgb: "#00FFFF")
            assertColorEquals(color, red: 0, green: 1, blue: 1)
        }

        @Test func `init RGB with magenta`() {
            let color = Color(rgb: "#FF00FF")
            assertColorEquals(color, red: 1, green: 0, blue: 1)
        }

        @Test func `init RGB with yellow`() {
            let color = Color(rgb: "#FFFF00")
            assertColorEquals(color, red: 1, green: 1, blue: 0)
        }
    }

#endif
