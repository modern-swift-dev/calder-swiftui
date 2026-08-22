#if canImport(SwiftUI) || canImport(UIKit) || canImport(AppKit)
#if canImport(UIKit)
import CalderUIKit
import Foundation
import Testing
import UIKit

@Suite(.serialized) struct UIColorBlendTests {

    /// Helper to compare color components with tolerance
    private func getComponents(_ color: UIColor) -> (r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat) {
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        color.getRed(&r, green: &g, blue: &b, alpha: &a)
        return (r, g, b, a)
    }

    private func isApproximatelyEqual(_ a: CGFloat, _ b: CGFloat, tolerance: CGFloat = 0.01) -> Bool {
        abs(a - b) < tolerance
    }

    // MARK: - lighten Tests

    @Test func `lighten zero amount returns original color`() {
        let color = UIColor.red
        let lightened = color.lighten(0.0)
        let original = getComponents(color)
        let result = getComponents(lightened)
        #expect(isApproximatelyEqual(original.r, result.r))
        #expect(isApproximatelyEqual(original.g, result.g))
        #expect(isApproximatelyEqual(original.b, result.b))
    }

    @Test func `lighten full amount returns white`() {
        let color = UIColor.black
        let lightened = color.lighten(1.0)
        let result = getComponents(lightened)
        #expect(isApproximatelyEqual(result.r, 1.0))
        #expect(isApproximatelyEqual(result.g, 1.0))
        #expect(isApproximatelyEqual(result.b, 1.0))
    }

    @Test func `lighten half amount`() {
        let color = UIColor.black
        let lightened = color.lighten(0.5)
        let result = getComponents(lightened)
        #expect(isApproximatelyEqual(result.r, 0.5))
        #expect(isApproximatelyEqual(result.g, 0.5))
        #expect(isApproximatelyEqual(result.b, 0.5))
    }

    @Test func `lighten red`() {
        let color = UIColor.red
        let lightened = color.lighten(0.5)
        let result = getComponents(lightened)
        #expect(result.r >= 0.5)
        #expect(result.g >= 0.0)
        #expect(result.b >= 0.0)
    }

    // MARK: - darken Tests

    @Test func `darken zero amount returns original color`() {
        let color = UIColor.white
        let darkened = color.darken(0.0)
        let original = getComponents(color)
        let result = getComponents(darkened)
        #expect(isApproximatelyEqual(original.r, result.r))
        #expect(isApproximatelyEqual(original.g, result.g))
        #expect(isApproximatelyEqual(original.b, result.b))
    }

    @Test func `darken full amount returns black`() {
        let color = UIColor.white
        let darkened = color.darken(1.0)
        let result = getComponents(darkened)
        #expect(isApproximatelyEqual(result.r, 0.0))
        #expect(isApproximatelyEqual(result.g, 0.0))
        #expect(isApproximatelyEqual(result.b, 0.0))
    }

    @Test func `darken half amount`() {
        let color = UIColor.white
        let darkened = color.darken(0.5)
        let result = getComponents(darkened)
        #expect(isApproximatelyEqual(result.r, 0.5))
        #expect(isApproximatelyEqual(result.g, 0.5))
        #expect(isApproximatelyEqual(result.b, 0.5))
    }

    // MARK: - blend Tests

    @Test func `blend zero intensity returns original color`() {
        let color1 = UIColor.red
        let color2 = UIColor.blue
        let blended = color1.blend(with: color2, intensity: 0.0)
        let original = getComponents(color1)
        let result = getComponents(blended)
        #expect(isApproximatelyEqual(original.r, result.r))
        #expect(isApproximatelyEqual(original.g, result.g))
        #expect(isApproximatelyEqual(original.b, result.b))
    }

    @Test func `blend full intensity returns second color`() {
        let color1 = UIColor.red
        let color2 = UIColor.blue
        let blended = color1.blend(with: color2, intensity: 1.0)
        let target = getComponents(color2)
        let result = getComponents(blended)
        #expect(isApproximatelyEqual(target.r, result.r))
        #expect(isApproximatelyEqual(target.g, result.g))
        #expect(isApproximatelyEqual(target.b, result.b))
    }

    @Test func `blend half intensity returns midpoint`() {
        let color1 = UIColor.black
        let color2 = UIColor.white
        let blended = color1.blend(with: color2, intensity: 0.5)
        let result = getComponents(blended)
        #expect(isApproximatelyEqual(result.r, 0.5))
        #expect(isApproximatelyEqual(result.g, 0.5))
        #expect(isApproximatelyEqual(result.b, 0.5))
    }

    @Test func `blend red and blue`() {
        let red = UIColor.red
        let blue = UIColor.blue
        let blended = red.blend(with: blue, intensity: 0.5)
        let result = getComponents(blended)
        #expect(isApproximatelyEqual(result.r, 0.5))
        #expect(isApproximatelyEqual(result.g, 0.0))
        #expect(isApproximatelyEqual(result.b, 0.5))
    }

    @Test func `blend clamps intensity above one`() {
        let color1 = UIColor.red
        let color2 = UIColor.blue
        let blended = color1.blend(with: color2, intensity: 1.5)
        let target = getComponents(color2)
        let result = getComponents(blended)
        #expect(isApproximatelyEqual(target.r, result.r))
        #expect(isApproximatelyEqual(target.g, result.g))
        #expect(isApproximatelyEqual(target.b, result.b))
    }

    @Test func `blend clamps intensity below zero`() {
        let color1 = UIColor.red
        let color2 = UIColor.blue
        let blended = color1.blend(with: color2, intensity: -0.5)
        let original = getComponents(color1)
        let result = getComponents(blended)
        #expect(isApproximatelyEqual(original.r, result.r))
        #expect(isApproximatelyEqual(original.g, result.g))
        #expect(isApproximatelyEqual(original.b, result.b))
    }

    @Test func `blend preserves alpha`() {
        let color1 = UIColor.red.withAlphaComponent(0.8)
        let color2 = UIColor.blue.withAlphaComponent(0.4)
        let blended = color1.blend(with: color2, intensity: 0.5)
        let result = getComponents(blended)
        #expect(isApproximatelyEqual(result.a, 0.6))
    }

    // MARK: - brighten Tests

    @Test func `brighten increase brightness`() {
        let color = UIColor(hue: 0.5, saturation: 0.5, brightness: 0.5, alpha: 1.0)
        let brightened = color.brighten(0.2)
        var originalBrightness: CGFloat = 0
        var resultBrightness: CGFloat = 0
        color.getHue(nil, saturation: nil, brightness: &originalBrightness, alpha: nil)
        brightened.getHue(nil, saturation: nil, brightness: &resultBrightness, alpha: nil)
        #expect(resultBrightness > originalBrightness)
    }

    @Test func `brighten zero amount same color`() {
        let color = UIColor(hue: 0.5, saturation: 0.5, brightness: 0.5, alpha: 1.0)
        let brightened = color.brighten(0.0)
        var originalBrightness: CGFloat = 0
        var resultBrightness: CGFloat = 0
        color.getHue(nil, saturation: nil, brightness: &originalBrightness, alpha: nil)
        brightened.getHue(nil, saturation: nil, brightness: &resultBrightness, alpha: nil)
        #expect(isApproximatelyEqual(resultBrightness, originalBrightness))
    }

    // MARK: - dim Tests

    @Test func `dim decreases brightness`() {
        let color = UIColor(hue: 0.5, saturation: 0.5, brightness: 0.8, alpha: 1.0)
        let dimmed = color.dim(0.2)
        var originalBrightness: CGFloat = 0
        var resultBrightness: CGFloat = 0
        color.getHue(nil, saturation: nil, brightness: &originalBrightness, alpha: nil)
        dimmed.getHue(nil, saturation: nil, brightness: &resultBrightness, alpha: nil)
        #expect(resultBrightness < originalBrightness)
    }

    @Test func `dim zero amount same color`() {
        let color = UIColor(hue: 0.5, saturation: 0.5, brightness: 0.5, alpha: 1.0)
        let dimmed = color.dim(0.0)
        var originalBrightness: CGFloat = 0
        var resultBrightness: CGFloat = 0
        color.getHue(nil, saturation: nil, brightness: &originalBrightness, alpha: nil)
        dimmed.getHue(nil, saturation: nil, brightness: &resultBrightness, alpha: nil)
        #expect(isApproximatelyEqual(resultBrightness, originalBrightness))
    }

    @Test func `dim full amount returns black`() {
        let color = UIColor(hue: 0.5, saturation: 0.5, brightness: 0.5, alpha: 1.0)
        let dimmed = color.dim(1.0)
        var resultBrightness: CGFloat = 0
        dimmed.getHue(nil, saturation: nil, brightness: &resultBrightness, alpha: nil)
        #expect(isApproximatelyEqual(resultBrightness, 0.0))
    }
}
#endif

#endif
