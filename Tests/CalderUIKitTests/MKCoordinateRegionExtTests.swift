#if canImport(MapKit)
import CalderUIKit
import CoreLocation
import Foundation
import MapKit
import Testing

@Suite(.serialized) struct MKCoordinateRegionExtTests {

    // MARK: - Init with distance Tests

    @Test func `init center and distance`() {
        let center = CLLocationCoordinate2D(40.7128, -74.0060)
        let region = MKCoordinateRegion(center: center, distance: 10000)

        #expect(abs(region.center.latitude - 40.7128) < 0.0001)
        #expect(abs(region.center.longitude - -74.0060) < 0.0001)
        #expect(region.span.latitudeDelta > 0)
        #expect(region.span.longitudeDelta > 0)
    }

    @Test func `init small distance`() {
        let center = CLLocationCoordinate2D(51.5074, -0.1278)
        let region = MKCoordinateRegion(center: center, distance: 100)

        #expect(region.span.latitudeDelta > 0)
        #expect(region.span.longitudeDelta > 0)
    }

    @Test func `init large distance`() {
        let center = CLLocationCoordinate2D(35.6762, 139.6503)
        let region = MKCoordinateRegion(center: center, distance: 100_000)

        #expect(region.span.latitudeDelta > 0)
        #expect(region.span.longitudeDelta > 0)
    }

    // MARK: - Sequence<CLLocationCoordinate2D> coordinateRegion Tests

    @Test func `coordinate region single coordinate`() {
        let coords = [CLLocationCoordinate2D(40.0, -100.0)]
        let region = coords.coordinateRegion()

        #expect(abs(region.center.latitude - 40.0) < 0.0001)
        #expect(abs(region.center.longitude - -100.0) < 0.0001)
    }

    @Test func `coordinate region two coordinates`() {
        let coords = [
            CLLocationCoordinate2D(40.0, -100.0),
            CLLocationCoordinate2D(42.0, -98.0)
        ]
        let region = coords.coordinateRegion()

        #expect(abs(region.center.latitude - 41.0) < 0.0001)
        #expect(abs(region.center.longitude - -99.0) < 0.0001)
    }

    @Test func `coordinate region with padding`() {
        let coords = [
            CLLocationCoordinate2D(40.0, -100.0),
            CLLocationCoordinate2D(42.0, -98.0)
        ]
        let regionWithPadding = coords.coordinateRegion(padding: 1000)
        let regionWithoutPadding = coords.coordinateRegion(padding: 0)

        // Region with padding should have larger span
        #expect(regionWithPadding.span.latitudeDelta >= regionWithoutPadding.span.latitudeDelta)
    }

    @Test func `coordinate region multiple coordinates`() {
        let coords = [
            CLLocationCoordinate2D(50.0, -110.0),
            CLLocationCoordinate2D(50.0, -90.0),
            CLLocationCoordinate2D(30.0, -110.0),
            CLLocationCoordinate2D(30.0, -90.0)
        ]
        let region = coords.coordinateRegion()

        #expect(abs(region.center.latitude - 40.0) < 0.0001)
        #expect(abs(region.center.longitude - -100.0) < 0.0001)
    }

    // MARK: - Sequence<CLLocation> coordinateRegion Tests

    @Test func `coordinate region locations`() {
        let locations = [
            CLLocation(latitude: 40.0, longitude: -100.0),
            CLLocation(latitude: 42.0, longitude: -98.0)
        ]
        let region = locations.coordinateRegion()

        #expect(abs(region.center.latitude - 41.0) < 0.0001)
        #expect(abs(region.center.longitude - -99.0) < 0.0001)
    }

    @Test func `coordinate region locations with padding`() {
        let locations = [
            CLLocation(latitude: 40.0, longitude: -100.0),
            CLLocation(latitude: 42.0, longitude: -98.0)
        ]
        let region = locations.coordinateRegion(padding: 5000)

        #expect(region.span.latitudeDelta > 0)
        #expect(region.span.longitudeDelta > 0)
    }
}
#endif
