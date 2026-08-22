#if canImport(CoreGraphics)
import CalderUIKit
import CoreGraphics
import Foundation
import Testing

@Suite(.serialized) struct CGRectExtTests {

    // MARK: - Constants

    @Test func `one has correct values`() {
        #expect(CGRect.one.origin == .zero)
        #expect(CGRect.one.size == .one)
        #expect(CGRect.one.width == 1.0)
        #expect(CGRect.one.height == 1.0)
    }

    // MARK: - Initializers

    @Test func `init with four parameters`() {
        let rect = CGRect(10.0, 20.0, 100.0, 50.0)
        #expect(rect.origin.x == 10.0)
        #expect(rect.origin.y == 20.0)
        #expect(rect.size.width == 100.0)
        #expect(rect.size.height == 50.0)
    }

    @Test func `init with width and height`() {
        let rect = CGRect(w: 200.0, h: 100.0)
        #expect(rect.origin.x == 0.0)
        #expect(rect.origin.y == 0.0)
        #expect(rect.size.width == 200.0)
        #expect(rect.size.height == 100.0)
    }

    @Test func `init with width only`() {
        let rect = CGRect(w: 150.0)
        #expect(rect.origin == .zero)
        #expect(rect.size.width == 150.0)
        #expect(rect.size.height == 0.0)
    }

    @Test func `init with height only`() {
        let rect = CGRect(h: 75.0)
        #expect(rect.origin == .zero)
        #expect(rect.size.width == 0.0)
        #expect(rect.size.height == 75.0)
    }

    @Test func `init with size`() {
        let size = CGSize(80.0, 60.0)
        let rect = CGRect(size: size)
        #expect(rect.origin == .zero)
        #expect(rect.size == size)
    }

    @Test func `init with negative values`() {
        let rect = CGRect(-10.0, -20.0, 100.0, 50.0)
        #expect(rect.origin.x == -10.0)
        #expect(rect.origin.y == -20.0)
    }

    // MARK: - Corner Points

    @Test func `top left returns zero`() {
        let rect = CGRect(50.0, 100.0, 200.0, 150.0)
        #expect(rect.topLeft == .zero)
    }

    @Test func `top right returns correct point`() {
        let rect = CGRect(0.0, 0.0, 200.0, 150.0)
        #expect(rect.topRight.x == 200.0)
        #expect(rect.topRight.y == 0.0)
    }

    @Test func `bottom left returns correct point`() {
        let rect = CGRect(0.0, 0.0, 200.0, 150.0)
        #expect(rect.bottomLeft.x == 0.0)
        #expect(rect.bottomLeft.y == 150.0)
    }

    @Test func `bottom right returns correct point`() {
        let rect = CGRect(0.0, 0.0, 200.0, 150.0)
        #expect(rect.bottomRight.x == 200.0)
        #expect(rect.bottomRight.y == 150.0)
    }

    @Test func `mid left returns correct point`() {
        let rect = CGRect(0.0, 0.0, 200.0, 100.0)
        #expect(rect.midLeft.x == 0.0)
        #expect(rect.midLeft.y == 50.0)
    }

    @Test func `mid right returns correct point`() {
        let rect = CGRect(0.0, 0.0, 200.0, 100.0)
        #expect(rect.midRight.x == 200.0)
        #expect(rect.midRight.y == 50.0)
    }

    @Test func `center returns correct point`() {
        let rect = CGRect(0.0, 0.0, 200.0, 100.0)
        #expect(rect.center.x == 0.0)
        #expect(rect.center.y == 50.0)
    }

    // MARK: - With Offset

    @Test func `corner points with offset`() {
        let rect = CGRect(10.0, 20.0, 100.0, 80.0)
        #expect(rect.topRight.x == 110.0)
        #expect(rect.bottomLeft.y == 100.0)
        #expect(rect.bottomRight.x == 110.0)
        #expect(rect.bottomRight.y == 100.0)
    }

}
#endif
