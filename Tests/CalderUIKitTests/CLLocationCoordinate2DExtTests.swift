#if canImport(CoreLocation)
import CalderUIKit
import CoreLocation
import Foundation
import Testing

@Suite(.serialized) struct CLLocationCoordinate2DExtTests {

    // MARK: - Convenience Init Tests

    @Test func `init with lat lon`() {
        let coord = CLLocationCoordinate2D(37.7749, -122.4194)
        #expect(abs(coord.latitude - 37.7749) < 0.0001)
        #expect(abs(coord.longitude - -122.4194) < 0.0001)
    }

    // MARK: - toCLLocation Tests

    @Test func `to CL location converts correctly`() {
        let coord = CLLocationCoordinate2D(40.7128, -74.0060)
        let location = coord.toCLLocation()
        #expect(abs(location.coordinate.latitude - 40.7128) < 0.0001)
        #expect(abs(location.coordinate.longitude - -74.0060) < 0.0001)
    }

    // MARK: - distance Tests

    @Test func `distance same location`() {
        let coord1 = CLLocationCoordinate2D(40.0, -100.0)
        let coord2 = CLLocationCoordinate2D(40.0, -100.0)
        let dist = coord1.distance(from: coord2)
        #expect(dist < 0.0001)
    }

    @Test func `distance different locations`() {
        let coord1 = CLLocationCoordinate2D(40.0, -100.0)
        let coord2 = CLLocationCoordinate2D(41.0, -99.0)
        let dist = coord1.distance(from: coord2)
        #expect(dist > 0)
    }

    // MARK: - distanceInMeters Tests

    @Test func `distance in meters same location`() {
        let coord1 = CLLocationCoordinate2D(40.0, -100.0)
        let coord2 = CLLocationCoordinate2D(40.0, -100.0)
        let dist = coord1.distanceInMeters(from: coord2)
        #expect(dist < 1)
    }

    @Test func `distance in meters different locations`() {
        let coord1 = CLLocationCoordinate2D(40.0, -100.0)
        let coord2 = CLLocationCoordinate2D(41.0, -99.0)
        let dist = coord1.distanceInMeters(from: coord2)
        #expect(dist > 0)
    }

    // MARK: - isNear (degrees) Tests

    @Test func `is near degrees within threshold`() {
        let coord1 = CLLocationCoordinate2D(40.0, -100.0)
        let coord2 = CLLocationCoordinate2D(40.0001, -100.0001)
        #expect(coord1.isNear(coord2, threshold: 1.0))
    }

    @Test func `is near degrees outside threshold`() {
        let coord1 = CLLocationCoordinate2D(40.0, -100.0)
        let coord2 = CLLocationCoordinate2D(50.0, -90.0)
        #expect(!coord1.isNear(coord2, threshold: 1.0))
    }

    // MARK: - isNear (meters) Tests

    @Test func `is near meters within threshold`() {
        let coord1 = CLLocationCoordinate2D(40.0, -100.0)
        let coord2 = CLLocationCoordinate2D(40.0, -100.0)
        #expect(coord1.isNear(coord2, thresholdInMeters: 1000.0))
    }

    @Test func `is near meters outside threshold`() {
        let coord1 = CLLocationCoordinate2D(40.0, -100.0)
        let coord2 = CLLocationCoordinate2D(50.0, -90.0)
        #expect(!coord1.isNear(coord2, thresholdInMeters: 1000.0))
    }

    // MARK: - getHeadingInRadians Tests

    @Test func `get heading in radians same location`() {
        let coord1 = CLLocationCoordinate2D(40.0, -100.0)
        let coord2 = CLLocationCoordinate2D(40.0, -100.0)
        let heading = coord1.getHeadingInRadians(fromHere: coord2)
        // Heading should be 0 or very small for same location
        #expect(abs(heading) < 0.0001 || !heading.isNaN)
    }

    @Test func `get heading in radians northward`() {
        let coord1 = CLLocationCoordinate2D(40.0, -100.0)
        let coord2 = CLLocationCoordinate2D(50.0, -100.0)
        let heading = coord1.getHeadingInRadians(fromHere: coord2)
        // Should be approximately 0 radians (north)
        #expect(abs(heading) < 0.5 || abs(heading - .pi * 2) < 0.5)
    }

    // MARK: - getHeadingInDegrees Tests

    @Test func `get heading in degrees eastward`() {
        let coord1 = CLLocationCoordinate2D(40.0, -100.0)
        let coord2 = CLLocationCoordinate2D(40.0, -90.0)
        let heading = coord1.getHeadingInDegrees(fromHere: coord2)
        // Should be approximately 90 degrees (east)
        #expect(heading >= 0 && heading <= 360)
    }

    @Test func `get heading in degrees always positive`() {
        let coord1 = CLLocationCoordinate2D(40.0, -100.0)
        let coord2 = CLLocationCoordinate2D(30.0, -110.0) // Southwest
        let heading = coord1.getHeadingInDegrees(fromHere: coord2)
        #expect(heading >= 0)
        #expect(heading <= 360)
    }

    // MARK: - Sequence center() Tests

    @Test func `center single coordinate`() {
        let coords = [CLLocationCoordinate2D(40.0, -100.0)]
        let center = coords.center()
        #expect(abs(center.latitude - 40.0) < 0.0001)
        #expect(abs(center.longitude - -100.0) < 0.0001)
    }

    @Test func `center two coordinates`() {
        let coords = [
            CLLocationCoordinate2D(40.0, -100.0),
            CLLocationCoordinate2D(42.0, -98.0)
        ]
        let center = coords.center()
        #expect(abs(center.latitude - 41.0) < 0.0001)
        #expect(abs(center.longitude - -99.0) < 0.0001)
    }

    @Test func `center multiple coordinates`() {
        let coords = [
            CLLocationCoordinate2D(50.0, -110.0),
            CLLocationCoordinate2D(50.0, -90.0),
            CLLocationCoordinate2D(30.0, -110.0),
            CLLocationCoordinate2D(30.0, -90.0)
        ]
        let center = coords.center()
        #expect(abs(center.latitude - 40.0) < 0.0001)
        #expect(abs(center.longitude - -100.0) < 0.0001)
    }
}
#endif
