#if canImport(CoreGraphics)
    import CalderUIKit
    import CoreGraphics
    import Foundation
    import Testing

    struct CGRectExtTests {

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

        // MARK: - Corner, Mid-Edge, and Centre Points

        @Test func `top left is the origin`() {
            let rect = CGRect(50.0, 100.0, 200.0, 150.0)
            #expect(rect.topLeft == CGPoint(x: 50.0, y: 100.0))
        }

        @Test func `top right is max x and min y`() {
            let rect = CGRect(50.0, 100.0, 200.0, 150.0)
            #expect(rect.topRight == CGPoint(x: 250.0, y: 100.0))
        }

        @Test func `bottom left is min x and max y`() {
            let rect = CGRect(50.0, 100.0, 200.0, 150.0)
            #expect(rect.bottomLeft == CGPoint(x: 50.0, y: 250.0))
        }

        @Test func `bottom right is max x and max y`() {
            let rect = CGRect(50.0, 100.0, 200.0, 150.0)
            #expect(rect.bottomRight == CGPoint(x: 250.0, y: 250.0))
        }

        @Test func `mid left is min x and mid y`() {
            let rect = CGRect(50.0, 100.0, 200.0, 150.0)
            #expect(rect.midLeft == CGPoint(x: 50.0, y: 175.0))
        }

        @Test func `mid right is max x and mid y`() {
            let rect = CGRect(50.0, 100.0, 200.0, 150.0)
            #expect(rect.midRight == CGPoint(x: 250.0, y: 175.0))
        }

        @Test func `center is mid x and mid y`() {
            let rect = CGRect(50.0, 100.0, 200.0, 150.0)
            #expect(rect.center == CGPoint(x: 150.0, y: 175.0))
        }

        @Test func `points of a rect with negative origin`() {
            let rect = CGRect(-40.0, -20.0, 80.0, 40.0)
            #expect(rect.topLeft == CGPoint(x: -40.0, y: -20.0))
            #expect(rect.topRight == CGPoint(x: 40.0, y: -20.0))
            #expect(rect.bottomLeft == CGPoint(x: -40.0, y: 20.0))
            #expect(rect.bottomRight == CGPoint(x: 40.0, y: 20.0))
            #expect(rect.center == .zero)
        }

    }
#endif
