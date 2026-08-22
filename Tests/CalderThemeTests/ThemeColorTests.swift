#if canImport(SwiftUI) || canImport(UIKit) || canImport(AppKit)
@testable import CalderTheme
import Foundation
import SwiftUI
import Testing

@Suite(.serialized) struct ThemeColorTests {

    // MARK: - Initialization: init(light:dark:lightContrast:darkContrast:)

    @Test func `init with light color only`() {
        let light = Color.red
        let themeColor = ThemeColor(light: light)

        #expect(themeColor.getColor(scheme: .light, contrast: nil) == light)
        #expect(themeColor.getColor(scheme: .dark, contrast: nil) == light) // Falls back to light
    }

    @Test func `init with light and dark colors`() {
        let light = Color.red
        let dark = Color.blue
        let themeColor = ThemeColor(light: light, dark: dark)

        #expect(themeColor.getColor(scheme: .light, contrast: nil) == light)
        #expect(themeColor.getColor(scheme: .dark, contrast: nil) == dark)
    }

    @Test func `init with all color variants`() {
        let light = Color.red
        let dark = Color.blue
        let lightContrast = Color.orange
        let darkContrast = Color.purple
        let themeColor = ThemeColor(
            light: light,
            dark: dark,
            lightContrast: lightContrast,
            darkContrast: darkContrast
        )

        #expect(themeColor.getColor(scheme: .light, contrast: nil) == light)
        #expect(themeColor.getColor(scheme: .light, contrast: .increased) == lightContrast)
        #expect(themeColor.getColor(scheme: .dark, contrast: nil) == dark)
        #expect(themeColor.getColor(scheme: .dark, contrast: .increased) == darkContrast)
    }

    @Test func `init with light and light contrast only`() {
        let light = Color.red
        let lightContrast = Color.orange
        let themeColor = ThemeColor(light: light, lightContrast: lightContrast)

        #expect(themeColor.getColor(scheme: .light, contrast: nil) == light)
        #expect(themeColor.getColor(scheme: .light, contrast: .increased) == lightContrast)
        #expect(themeColor.getColor(scheme: .dark, contrast: nil) == light) // Falls back to light
        #expect(themeColor.getColor(scheme: .dark, contrast: .increased) == light) // No dark contrast, falls back
    }

    @Test func `init with light and dark contrast only`() {
        let light = Color.red
        let darkContrast = Color.purple
        let themeColor = ThemeColor(light: light, darkContrast: darkContrast)

        #expect(themeColor.getColor(scheme: .light, contrast: nil) == light)
        #expect(themeColor.getColor(scheme: .light, contrast: .increased) == light) // No light contrast
        #expect(themeColor.getColor(scheme: .dark, contrast: nil) == light) // No dark, falls back
        #expect(themeColor.getColor(scheme: .dark, contrast: .increased) == darkContrast)
    }

    // MARK: - Initialization: init(darken:ratio:lightContrastRatio:darkContrastRatio:)

    @Test func `init with darken creates correct colors`() {
        let base = Color.blue
        let themeColor = ThemeColor(darken: base, ratio: 0.3)

        #expect(themeColor.getColor(scheme: .light, contrast: nil) == base)
        // Dark should be darkened version of base
        let darkColor = themeColor.getColor(scheme: .dark, contrast: nil)
        #expect(darkColor != base)
    }

    @Test func `init with darken default ratio`() {
        let base = Color.blue
        let themeColor = ThemeColor(darken: base)

        #expect(themeColor.getColor(scheme: .light, contrast: nil) == base)
        // Dark should be darkened with default ratio 0.5
        let darkColor = themeColor.getColor(scheme: .dark, contrast: nil)
        #expect(darkColor != base)
    }

    @Test func `init with darken and light contrast ratio`() {
        let base = Color.blue
        let themeColor = ThemeColor(darken: base, ratio: 0.3, lightContrastRatio: 0.2)

        #expect(themeColor.getColor(scheme: .light, contrast: nil) == base)
        let lightContrastColor = themeColor.getColor(scheme: .light, contrast: .increased)
        #expect(lightContrastColor != base) // Should be lightened
    }

    @Test func `init with darken and dark contrast ratio`() {
        let base = Color.blue
        let themeColor = ThemeColor(darken: base, ratio: 0.3, darkContrastRatio: 0.2)

        #expect(themeColor.getColor(scheme: .light, contrast: nil) == base)
        let darkContrastColor = themeColor.getColor(scheme: .dark, contrast: .increased)
        #expect(darkContrastColor != base) // Should be lightened
    }

    @Test func `init with darken and all contrast ratios`() {
        let base = Color.blue
        let themeColor = ThemeColor(
            darken: base,
            ratio: 0.4,
            lightContrastRatio: 0.2,
            darkContrastRatio: 0.3
        )

        let lightColor = themeColor.getColor(scheme: .light, contrast: nil)
        let lightContrastColor = themeColor.getColor(scheme: .light, contrast: .increased)
        let darkColor = themeColor.getColor(scheme: .dark, contrast: nil)
        let darkContrastColor = themeColor.getColor(scheme: .dark, contrast: .increased)

        #expect(lightColor == base)
        #expect(lightContrastColor != base)
        #expect(darkColor != base)
        #expect(darkContrastColor != base)
        #expect(lightContrastColor != darkContrastColor)
    }

    // MARK: - Initialization: init(lighten:ratio:lightContrastRatio:darkContrastRatio:)

    @Test func `init with lighten creates correct colors`() {
        let base = Color.blue
        let themeColor = ThemeColor(lighten: base, ratio: 0.3)

        #expect(themeColor.getColor(scheme: .light, contrast: nil) == base)
        // Dark should be lightened version of base
        let darkColor = themeColor.getColor(scheme: .dark, contrast: nil)
        #expect(darkColor != base)
    }

    @Test func `init with lighten default ratio`() {
        let base = Color.blue
        let themeColor = ThemeColor(lighten: base)

        #expect(themeColor.getColor(scheme: .light, contrast: nil) == base)
        // Dark should be lightened with default ratio 0.5
        let darkColor = themeColor.getColor(scheme: .dark, contrast: nil)
        #expect(darkColor != base)
    }

    @Test func `init with lighten and light contrast ratio`() {
        let base = Color.blue
        let themeColor = ThemeColor(lighten: base, ratio: 0.3, lightContrastRatio: 0.2)

        #expect(themeColor.getColor(scheme: .light, contrast: nil) == base)
        let lightContrastColor = themeColor.getColor(scheme: .light, contrast: .increased)
        #expect(lightContrastColor != base) // Should be darkened
    }

    @Test func `init with lighten and dark contrast ratio`() {
        let base = Color.blue
        let themeColor = ThemeColor(lighten: base, ratio: 0.3, darkContrastRatio: 0.2)

        #expect(themeColor.getColor(scheme: .light, contrast: nil) == base)
        let darkContrastColor = themeColor.getColor(scheme: .dark, contrast: .increased)
        #expect(darkContrastColor != base) // Should be lightened
    }

    @Test func `init with lighten and all contrast ratios`() {
        let base = Color.blue
        let themeColor = ThemeColor(
            lighten: base,
            ratio: 0.4,
            lightContrastRatio: 0.2,
            darkContrastRatio: 0.3
        )

        let lightColor = themeColor.getColor(scheme: .light, contrast: nil)
        let lightContrastColor = themeColor.getColor(scheme: .light, contrast: .increased)
        let darkColor = themeColor.getColor(scheme: .dark, contrast: nil)
        let darkContrastColor = themeColor.getColor(scheme: .dark, contrast: .increased)

        #expect(lightColor == base)
        #expect(lightContrastColor != base)
        #expect(darkColor != base)
        #expect(darkContrastColor != base)
        #expect(lightContrastColor != darkContrastColor)
    }

    // MARK: - Initialization: init(lighten rgb:ratio:lightContrastRatio:darkContrastRatio:)

    @Test func `init with lighten RGB string`() {
        let themeColor = ThemeColor(lighten: "#FF0000", ratio: 0.3)

        let lightColor = themeColor.getColor(scheme: .light, contrast: nil)
        let darkColor = themeColor.getColor(scheme: .dark, contrast: nil)

        #expect(lightColor != darkColor)
    }

    @Test func `init with lighten RGB string default ratio`() {
        let themeColor = ThemeColor(lighten: "#FF0000")

        let lightColor = themeColor.getColor(scheme: .light, contrast: nil)
        let darkColor = themeColor.getColor(scheme: .dark, contrast: nil)

        #expect(lightColor != darkColor)
    }

    @Test func `init with lighten RGB string and contrast ratios`() {
        let themeColor = ThemeColor(
            lighten: "#0000FF",
            ratio: 0.4,
            lightContrastRatio: 0.2,
            darkContrastRatio: 0.3
        )

        let lightColor = themeColor.getColor(scheme: .light, contrast: nil)
        let lightContrastColor = themeColor.getColor(scheme: .light, contrast: .increased)
        let darkColor = themeColor.getColor(scheme: .dark, contrast: nil)
        let darkContrastColor = themeColor.getColor(scheme: .dark, contrast: .increased)

        #expect(lightContrastColor != lightColor)
        #expect(darkColor != lightColor)
        #expect(darkContrastColor != darkColor)
    }

    // MARK: - Initialization: init(darken rgb:ratio:lightContrastRatio:darkContrastRatio:)

    @Test func `init with darken RGB string`() {
        let themeColor = ThemeColor(darken: "#FF0000", ratio: 0.3)

        let lightColor = themeColor.getColor(scheme: .light, contrast: nil)
        let darkColor = themeColor.getColor(scheme: .dark, contrast: nil)

        #expect(lightColor != darkColor)
    }

    @Test func `init with darken RGB string default ratio`() {
        let themeColor = ThemeColor(darken: "#FF0000")

        let lightColor = themeColor.getColor(scheme: .light, contrast: nil)
        let darkColor = themeColor.getColor(scheme: .dark, contrast: nil)

        #expect(lightColor != darkColor)
    }

    @Test func `init with darken RGB string and contrast ratios`() {
        let themeColor = ThemeColor(
            darken: "#0000FF",
            ratio: 0.4,
            lightContrastRatio: 0.2,
            darkContrastRatio: 0.3
        )

        let lightColor = themeColor.getColor(scheme: .light, contrast: nil)
        let lightContrastColor = themeColor.getColor(scheme: .light, contrast: .increased)
        let darkColor = themeColor.getColor(scheme: .dark, contrast: nil)
        let darkContrastColor = themeColor.getColor(scheme: .dark, contrast: .increased)

        #expect(lightContrastColor != lightColor)
        #expect(darkColor != lightColor)
        #expect(darkContrastColor != darkColor)
    }

    // MARK: - Initialization: init(rgb:)

    @Test func `init with RGB string used for all modes`() {
        let themeColor = ThemeColor(rgb: "#00FF00")

        let lightColor = themeColor.getColor(scheme: .light, contrast: nil)
        let lightContrastColor = themeColor.getColor(scheme: .light, contrast: .increased)
        let darkColor = themeColor.getColor(scheme: .dark, contrast: nil)
        let darkContrastColor = themeColor.getColor(scheme: .dark, contrast: .increased)

        // All should be the same color
        #expect(lightColor == lightContrastColor)
        #expect(lightColor == darkColor)
        #expect(lightColor == darkContrastColor)
    }

    @Test func `init with RGB string handles red color`() {
        let themeColor = ThemeColor(rgb: "#FF0000")
        let color = themeColor.getColor(scheme: .light, contrast: nil)

        // Verify it's a valid color (not crashing)
        #expect(color == themeColor.getColor(scheme: .dark, contrast: nil))
    }

    @Test func `init with RGB string handles blue color`() {
        let themeColor = ThemeColor(rgb: "#0000FF")
        let color = themeColor.getColor(scheme: .light, contrast: nil)

        // Verify it's a valid color (not crashing)
        #expect(color == themeColor.getColor(scheme: .dark, contrast: nil))
    }

    @Test func `init with RGB string handles green color`() {
        let themeColor = ThemeColor(rgb: "#00FF00")
        let color = themeColor.getColor(scheme: .light, contrast: nil)

        // Verify it's a valid color (not crashing)
        #expect(color == themeColor.getColor(scheme: .dark, contrast: nil))
    }

    // MARK: - getColor Method: Light Scheme

    @Test func `get color light scheme no contrast returns light`() {
        let light = Color.red
        let dark = Color.blue
        let themeColor = ThemeColor(light: light, dark: dark)

        let result = themeColor.getColor(scheme: .light, contrast: nil)
        #expect(result == light)
    }

    @Test func `get color light scheme increased contrast returns light contrast`() {
        let light = Color.red
        let dark = Color.blue
        let lightContrast = Color.orange
        let themeColor = ThemeColor(light: light, dark: dark, lightContrast: lightContrast)

        let result = themeColor.getColor(scheme: .light, contrast: .increased)
        #expect(result == lightContrast)
    }

    @Test func `get color light scheme increased contrast falls back to light`() {
        let light = Color.red
        let dark = Color.blue
        let themeColor = ThemeColor(light: light, dark: dark)

        let result = themeColor.getColor(scheme: .light, contrast: .increased)
        #expect(result == light) // No lightContrast, falls back to light
    }

    @Test func `get color light scheme standard contrast returns light`() {
        let light = Color.red
        let dark = Color.blue
        let lightContrast = Color.orange
        let themeColor = ThemeColor(light: light, dark: dark, lightContrast: lightContrast)

        let result = themeColor.getColor(scheme: .light, contrast: .standard)
        #expect(result == light)
    }

    // MARK: - getColor Method: Dark Scheme

    @Test func `get color dark scheme no contrast returns dark`() {
        let light = Color.red
        let dark = Color.blue
        let themeColor = ThemeColor(light: light, dark: dark)

        let result = themeColor.getColor(scheme: .dark, contrast: nil)
        #expect(result == dark)
    }

    @Test func `get color dark scheme no contrast falls back to light`() {
        let light = Color.red
        let themeColor = ThemeColor(light: light)

        let result = themeColor.getColor(scheme: .dark, contrast: nil)
        #expect(result == light) // No dark, falls back to light
    }

    @Test func `get color dark scheme increased contrast returns dark contrast`() {
        let light = Color.red
        let dark = Color.blue
        let darkContrast = Color.purple
        let themeColor = ThemeColor(light: light, dark: dark, darkContrast: darkContrast)

        let result = themeColor.getColor(scheme: .dark, contrast: .increased)
        #expect(result == darkContrast)
    }

    @Test func `get color dark scheme increased contrast falls back to dark`() {
        let light = Color.red
        let dark = Color.blue
        let themeColor = ThemeColor(light: light, dark: dark)

        let result = themeColor.getColor(scheme: .dark, contrast: .increased)
        #expect(result == dark) // No darkContrast, falls back to dark
    }

    @Test func `get color dark scheme increased contrast falls back to light`() {
        let light = Color.red
        let themeColor = ThemeColor(light: light)

        let result = themeColor.getColor(scheme: .dark, contrast: .increased)
        #expect(result == light) // No dark or darkContrast, falls back to light
    }

    @Test func `get color dark scheme standard contrast returns dark`() {
        let light = Color.red
        let dark = Color.blue
        let darkContrast = Color.purple
        let themeColor = ThemeColor(light: light, dark: dark, darkContrast: darkContrast)

        let result = themeColor.getColor(scheme: .dark, contrast: .standard)
        #expect(result == dark)
    }

    // MARK: - getColor Method: All Combinations

    @Test func `get color all combinations with full configuration`() {
        let light = Color.red
        let dark = Color.blue
        let lightContrast = Color.orange
        let darkContrast = Color.purple
        let themeColor = ThemeColor(
            light: light,
            dark: dark,
            lightContrast: lightContrast,
            darkContrast: darkContrast
        )

        // Light mode
        #expect(themeColor.getColor(scheme: .light, contrast: nil) == light)
        #expect(themeColor.getColor(scheme: .light, contrast: .standard) == light)
        #expect(themeColor.getColor(scheme: .light, contrast: .increased) == lightContrast)

        // Dark mode
        #expect(themeColor.getColor(scheme: .dark, contrast: nil) == dark)
        #expect(themeColor.getColor(scheme: .dark, contrast: .standard) == dark)
        #expect(themeColor.getColor(scheme: .dark, contrast: .increased) == darkContrast)
    }

    @Test func `get color all combinations with minimal configuration`() {
        let light = Color.red
        let themeColor = ThemeColor(light: light)

        // Light mode
        #expect(themeColor.getColor(scheme: .light, contrast: nil) == light)
        #expect(themeColor.getColor(scheme: .light, contrast: .standard) == light)
        #expect(themeColor.getColor(scheme: .light, contrast: .increased) == light)

        // Dark mode (all fall back to light)
        #expect(themeColor.getColor(scheme: .dark, contrast: nil) == light)
        #expect(themeColor.getColor(scheme: .dark, contrast: .standard) == light)
        #expect(themeColor.getColor(scheme: .dark, contrast: .increased) == light)
    }

    @Test func `get color all combinations with partial configuration`() {
        let light = Color.red
        let dark = Color.blue
        let lightContrast = Color.orange
        let themeColor = ThemeColor(light: light, dark: dark, lightContrast: lightContrast)

        // Light mode
        #expect(themeColor.getColor(scheme: .light, contrast: nil) == light)
        #expect(themeColor.getColor(scheme: .light, contrast: .standard) == light)
        #expect(themeColor.getColor(scheme: .light, contrast: .increased) == lightContrast)

        // Dark mode (darkContrast falls back to dark)
        #expect(themeColor.getColor(scheme: .dark, contrast: nil) == dark)
        #expect(themeColor.getColor(scheme: .dark, contrast: .standard) == dark)
        #expect(themeColor.getColor(scheme: .dark, contrast: .increased) == dark)
    }

    // MARK: - Edge Cases

    @Test func `get color default parameters return light`() {
        let light = Color.red
        let dark = Color.blue
        let themeColor = ThemeColor(light: light, dark: dark)

        let result = themeColor.getColor() // Uses default parameters
        #expect(result == light)
    }

    @Test func `get color with system colors`() {
        let themeColor = ThemeColor(
            light: .primary,
            dark: .secondary,
            lightContrast: .accentColor,
            darkContrast: .gray
        )

        // Verify system colors work without crashing
        let lightColor = themeColor.getColor(scheme: .light, contrast: nil)
        let darkColor = themeColor.getColor(scheme: .dark, contrast: nil)
        let lightContrastColor = themeColor.getColor(scheme: .light, contrast: .increased)
        let darkContrastColor = themeColor.getColor(scheme: .dark, contrast: .increased)

        #expect(lightColor == .primary)
        #expect(darkColor == .secondary)
        #expect(lightContrastColor == .accentColor)
        #expect(darkContrastColor == .gray)
    }

    @Test func `init with zero ratio darken`() {
        let base = Color.blue
        let themeColor = ThemeColor(darken: base, ratio: 0.0)

        let lightColor = themeColor.getColor(scheme: .light, contrast: nil)
        let darkColor = themeColor.getColor(scheme: .dark, contrast: nil)

        #expect(lightColor == base)
        // Dark with ratio 0 should be same or very close to base
        #expect(darkColor != base) // darken still applies transformation
    }

    @Test func `init with zero ratio lighten`() {
        let base = Color.blue
        let themeColor = ThemeColor(lighten: base, ratio: 0.0)

        let lightColor = themeColor.getColor(scheme: .light, contrast: nil)
        let darkColor = themeColor.getColor(scheme: .dark, contrast: nil)

        #expect(lightColor == base)
        // Dark with ratio 0 should be same or very close to base
        #expect(darkColor != base) // lighten still applies transformation
    }

    @Test func `init with max ratio darken`() {
        let base = Color.blue
        let themeColor = ThemeColor(darken: base, ratio: 1.0)

        let lightColor = themeColor.getColor(scheme: .light, contrast: nil)
        let darkColor = themeColor.getColor(scheme: .dark, contrast: nil)

        #expect(lightColor == base)
        #expect(darkColor != base) // Should be significantly darker
    }

    @Test func `init with max ratio lighten`() {
        let base = Color.blue
        let themeColor = ThemeColor(lighten: base, ratio: 1.0)

        let lightColor = themeColor.getColor(scheme: .light, contrast: nil)
        let darkColor = themeColor.getColor(scheme: .dark, contrast: nil)

        #expect(lightColor == base)
        #expect(darkColor != base) // Should be significantly lighter
    }
}

#endif
