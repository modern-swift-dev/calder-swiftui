#if canImport(SwiftUI) || canImport(UIKit) || canImport(AppKit)
#if canImport(UIKit)
import CalderUIKit
import CoreGraphics
import Foundation
import Testing
import UIKit

@Suite(.serialized)
@MainActor struct UIColorExtTests {

    // MARK: - alphaComponent Tests

    @Test func `alpha component fully opaque`() {
        let color = UIColor.red
        let alpha = color.alphaComponent()
        #expect(alpha == 1.0)
    }

    @Test func `alpha component semi transparent`() {
        let color = UIColor.blue.withAlphaComponent(0.5)
        let alpha = color.alphaComponent()
        #expect(abs(alpha - 0.5) < 0.01)
    }

    @Test func `alpha component fully transparent`() {
        let color = UIColor.green.withAlphaComponent(0.0)
        let alpha = color.alphaComponent()
        #expect(alpha == 0.0)
    }

    @Test func `alpha component custom alpha`() {
        let color = UIColor.black.withAlphaComponent(0.75)
        let alpha = color.alphaComponent()
        #expect(abs(alpha - 0.75) < 0.01)
    }

    // MARK: - asImage Tests

    @Test func `as image default size`() {
        let color = UIColor.red
        let image = color.asImage()
        #expect(image.size.width == 1)
        #expect(image.size.height == 1)
    }

    @Test func `as image custom size`() {
        let color = UIColor.blue
        let size = CGSize(width: 100, height: 50)
        let image = color.asImage(size)
        #expect(image.size.width == 100)
        #expect(image.size.height == 50)
    }

    @Test func `as image square size`() {
        let color = UIColor.green
        let size = CGSize(width: 64, height: 64)
        let image = color.asImage(size)
        #expect(image.size.width == 64)
        #expect(image.size.height == 64)
    }

    // MARK: - asSquare Tests

    @Test func `as square returns square image`() {
        let color = UIColor.yellow
        let image = color.asSquare(50)
        #expect(image.size.width == 50)
        #expect(image.size.height == 50)
    }

    @Test func `as square small size`() {
        let color = UIColor.purple
        let image = color.asSquare(1)
        #expect(image.size.width == 1)
        #expect(image.size.height == 1)
    }

    @Test func `as square large size`() {
        let color = UIColor.orange
        let image = color.asSquare(200)
        #expect(image.size.width == 200)
        #expect(image.size.height == 200)
    }

    // MARK: - asCircle Tests

    @Test func `as circle returns square image`() {
        let color = UIColor.cyan
        let image = color.asCircle(50)
        #expect(image.size.width == 50)
        #expect(image.size.height == 50)
    }

    @Test func `as circle small size`() {
        let color = UIColor.magenta
        let image = color.asCircle(10)
        #expect(image.size.width == 10)
        #expect(image.size.height == 10)
    }

    @Test func `as circle large size`() {
        let color = UIColor.brown
        let image = color.asCircle(150)
        #expect(image.size.width == 150)
        #expect(image.size.height == 150)
    }

    // MARK: - asOval Tests

    @Test func `as oval centered default`() {
        let color = UIColor.red
        let size = CGSize(width: 100, height: 50)
        let image = color.asOval(size)
        #expect(image.size.width == 100)
        #expect(image.size.height == 50)
    }

    @Test func `as oval centered`() {
        let color = UIColor.blue
        let size = CGSize(width: 80, height: 40)
        let image = color.asOval(size, centered: true)
        #expect(image.size.width == 80)
        #expect(image.size.height == 40)
    }

    @Test func `as oval not centered`() {
        let color = UIColor.green
        let size = CGSize(width: 60, height: 30)
        let image = color.asOval(size, centered: false)
        #expect(image.size.width == 60)
        #expect(image.size.height == 30)
    }

    @Test func `as oval square size`() {
        let color = UIColor.yellow
        let size = CGSize(width: 100, height: 100)
        let image = color.asOval(size)
        #expect(image.size.width == 100)
        #expect(image.size.height == 100)
    }
}
#endif

#endif
