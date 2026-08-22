#if canImport(CoreGraphics)
import CalderUIKit
import CoreGraphics
import Foundation
import Testing

@Suite(.serialized) struct CGPointExtTests {

    // MARK: - Initializers

    @Test func `init with two parameters`() {
        let point = CGPoint(10.0, 20.0)
        #expect(point.x == 10.0)
        #expect(point.y == 20.0)
    }

    @Test func `init with X only`() {
        let point = CGPoint(x: 15.0)
        #expect(point.x == 15.0)
        #expect(point.y == 0.0)
    }

    @Test func `init with Y only`() {
        let point = CGPoint(y: 25.0)
        #expect(point.x == 0.0)
        #expect(point.y == 25.0)
    }

    @Test func `init with negative values`() {
        let point = CGPoint(-5.0, -10.0)
        #expect(point.x == -5.0)
        #expect(point.y == -10.0)
    }

    @Test func `init with zero`() {
        let point = CGPoint(0.0, 0.0)
        #expect(point == CGPoint.zero)
    }

    // MARK: - isNear Tests

    @Test func `is near same point returns true`() {
        let point1 = CGPoint(100.0, 100.0)
        let point2 = CGPoint(100.0, 100.0)
        #expect(point1.isNear(other: point2) == true)
    }

    @Test func `is near within default tolerance returns true`() {
        let point1 = CGPoint(100.0, 100.0)
        let point2 = CGPoint(110.0, 110.0)
        #expect(point1.isNear(other: point2) == true)
    }

    @Test func `is near outside default tolerance returns false`() {
        let point1 = CGPoint(100.0, 100.0)
        let point2 = CGPoint(120.0, 120.0)
        #expect(point1.isNear(other: point2) == false)
    }

    @Test func `is near x within tolerance Y outside returns false`() {
        let point1 = CGPoint(100.0, 100.0)
        let point2 = CGPoint(105.0, 120.0)
        #expect(point1.isNear(other: point2) == false)
    }

    @Test func `is near y within tolerance X outside returns false`() {
        let point1 = CGPoint(100.0, 100.0)
        let point2 = CGPoint(120.0, 105.0)
        #expect(point1.isNear(other: point2) == false)
    }

    @Test func `is near custom tolerance within range`() {
        let point1 = CGPoint(100.0, 100.0)
        let point2 = CGPoint(125.0, 125.0)
        #expect(point1.isNear(other: point2, tolerance: 30.0) == true)
    }

    @Test func `is near custom tolerance outside range`() {
        let point1 = CGPoint(100.0, 100.0)
        let point2 = CGPoint(106.0, 106.0)
        #expect(point1.isNear(other: point2, tolerance: 5.0) == false)
    }

    @Test func `is near negative coordinates`() {
        let point1 = CGPoint(-100.0, -100.0)
        let point2 = CGPoint(-95.0, -95.0)
        #expect(point1.isNear(other: point2) == true)
    }

    @Test func `is near mixed positive negative`() {
        let point1 = CGPoint(-5.0, 5.0)
        let point2 = CGPoint(5.0, -5.0)
        #expect(point1.isNear(other: point2) == true)
    }

    @Test func `is near exactly at tolerance returns false`() {
        let point1 = CGPoint(0.0, 0.0)
        let point2 = CGPoint(15.0, 0.0)
        #expect(point1.isNear(other: point2) == false)
    }

    @Test func `is near just below tolerance returns true`() {
        let point1 = CGPoint(0.0, 0.0)
        let point2 = CGPoint(14.9, 14.9)
        #expect(point1.isNear(other: point2) == true)
    }

}
#endif
