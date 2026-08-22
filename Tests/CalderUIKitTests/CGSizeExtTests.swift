#if canImport(CoreGraphics)
import CalderUIKit
import CoreGraphics
import Foundation
import Testing

@Suite(.serialized) struct CGSizeExtTests {

    // MARK: - Constants

    @Test func `one has width and height of one`() {
        #expect(CGSize.one.width == 1.0)
        #expect(CGSize.one.height == 1.0)
    }

    // MARK: - Initializers

    @Test func `init with two parameters`() {
        let size = CGSize(10.0, 20.0)
        #expect(size.width == 10.0)
        #expect(size.height == 20.0)
    }

    @Test func `init with width only`() {
        let size = CGSize(w: 15.0)
        #expect(size.width == 15.0)
        #expect(size.height == 0.0)
    }

    @Test func `init with height only`() {
        let size = CGSize(h: 25.0)
        #expect(size.width == 0.0)
        #expect(size.height == 25.0)
    }

    @Test func `init with negative values`() {
        let size = CGSize(-5.0, -10.0)
        #expect(size.width == -5.0)
        #expect(size.height == -10.0)
    }

    @Test func `init with zero`() {
        let size = CGSize(0.0, 0.0)
        #expect(size.width == 0.0)
        #expect(size.height == 0.0)
    }

    // MARK: - Computed Properties

    @Test func `half returns half size`() {
        let size = CGSize(100.0, 50.0)
        let halfSize = size.half
        #expect(halfSize.width == 50.0)
        #expect(halfSize.height == 25.0)
    }

    @Test func `half with odd numbers`() {
        let size = CGSize(101.0, 51.0)
        let halfSize = size.half
        #expect(halfSize.width == 50.5)
        #expect(halfSize.height == 25.5)
    }

    @Test func `half with zero`() {
        let size = CGSize.zero
        let halfSize = size.half
        #expect(halfSize.width == 0.0)
        #expect(halfSize.height == 0.0)
    }

    @Test func `quarter returns quarter size`() {
        let size = CGSize(200.0, 100.0)
        let quarterSize = size.quarter
        #expect(quarterSize.width == 50.0)
        #expect(quarterSize.height == 25.0)
    }

    @Test func `quarter with small values`() {
        let size = CGSize(4.0, 8.0)
        let quarterSize = size.quarter
        #expect(quarterSize.width == 1.0)
        #expect(quarterSize.height == 2.0)
    }

    @Test func `rect returns rect with zero origin`() {
        let size = CGSize(80.0, 60.0)
        let rect = size.rect
        #expect(rect.origin.x == 0.0)
        #expect(rect.origin.y == 0.0)
        #expect(rect.size.width == 80.0)
        #expect(rect.size.height == 60.0)
    }

    @Test func `rect with zero size`() {
        let size = CGSize.zero
        let rect = size.rect
        #expect(rect == CGRect.zero)
    }

}
#endif
