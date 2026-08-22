#if canImport(CoreLocation)
import CalderUIKit
import CoreLocation
import Foundation
import Testing

@Suite(.serialized) struct CLLocationExtTests {

    // MARK: - Convenience Init Tests

    @Test func `init with lat lon`() {
        let location = CLLocation(37.7749, -122.4194)
        #expect(abs(location.coordinate.latitude - 37.7749) < 0.0001)
        #expect(abs(location.coordinate.longitude - -122.4194) < 0.0001)
    }

    @Test func `init with coordinate`() {
        let coordinate = CLLocationCoordinate2D(latitude: 40.7128, longitude: -74.0060)
        let location = CLLocation(coordinate)
        #expect(abs(location.coordinate.latitude - 40.7128) < 0.0001)
        #expect(abs(location.coordinate.longitude - -74.0060) < 0.0001)
    }

    // MARK: - Computed Properties Tests

    @Test func `latitude property`() {
        let location = CLLocation(51.5074, -0.1278)
        #expect(abs(location.latitude - 51.5074) < 0.0001)
    }

    @Test func `longitude property`() {
        let location = CLLocation(51.5074, -0.1278)
        #expect(abs(location.longitude - -0.1278) < 0.0001)
    }

    // MARK: - Sequence center() Tests

    @Test func `center single location`() {
        let locations = [CLLocation(40.0, -100.0)]
        let center = locations.center()
        #expect(abs(center.latitude - 40.0) < 0.0001)
        #expect(abs(center.longitude - -100.0) < 0.0001)
    }

    @Test func `center two locations`() {
        let locations = [
            CLLocation(40.0, -100.0),
            CLLocation(42.0, -98.0)
        ]
        let center = locations.center()
        #expect(abs(center.latitude - 41.0) < 0.0001)
        #expect(abs(center.longitude - -99.0) < 0.0001)
    }

    @Test func `center four corners`() {
        let locations = [
            CLLocation(50.0, -110.0), // NW
            CLLocation(50.0, -90.0), // NE
            CLLocation(30.0, -110.0), // SW
            CLLocation(30.0, -90.0) // SE
        ]
        let center = locations.center()
        #expect(abs(center.latitude - 40.0) < 0.0001)
        #expect(abs(center.longitude - -100.0) < 0.0001)
    }

    @Test func `center negative coordinates`() {
        let locations = [
            CLLocation(-34.6037, -58.3816), // Buenos Aires
            CLLocation(-33.8688, 151.2093) // Sydney
        ]
        let center = locations.center()
        #expect(center.latitude < 0) // Should be in southern hemisphere
    }
}
#endif
