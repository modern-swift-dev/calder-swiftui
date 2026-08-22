#if canImport(MapKit)
import CalderUIKit
import CoreLocation
import Foundation
import MapKit
import Testing

/// Test annotation class
final class TestAnnotation: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D

    init(coordinate: CLLocationCoordinate2D) {
        self.coordinate = coordinate
    }
}

@Suite(.serialized) struct MKAnnotationExtTests {

    // MARK: - latitude/longitude Properties Tests

    @Test func `latitude property`() {
        let annotation = TestAnnotation(coordinate: CLLocationCoordinate2D(40.7128, -74.0060))
        #expect(abs(annotation.latitude - 40.7128) < 0.0001)
    }

    @Test func `longitude property`() {
        let annotation = TestAnnotation(coordinate: CLLocationCoordinate2D(40.7128, -74.0060))
        #expect(abs(annotation.longitude - -74.0060) < 0.0001)
    }

    @Test func `latitude negative value`() {
        let annotation = TestAnnotation(coordinate: CLLocationCoordinate2D(-33.8688, 151.2093))
        #expect(abs(annotation.latitude - -33.8688) < 0.0001)
    }

    @Test func `longitude negative value`() {
        let annotation = TestAnnotation(coordinate: CLLocationCoordinate2D(51.5074, -0.1278))
        #expect(abs(annotation.longitude - -0.1278) < 0.0001)
    }

    // MARK: - Sequence<MKAnnotation> center() Tests

    @Test func `center single annotation`() {
        let annotations: [MKAnnotation] = [
            TestAnnotation(coordinate: CLLocationCoordinate2D(40.0, -100.0))
        ]
        let center = annotations.center()

        #expect(abs(center.latitude - 40.0) < 0.0001)
        #expect(abs(center.longitude - -100.0) < 0.0001)
    }

    @Test func `center two annotations`() {
        let annotations: [MKAnnotation] = [
            TestAnnotation(coordinate: CLLocationCoordinate2D(40.0, -100.0)),
            TestAnnotation(coordinate: CLLocationCoordinate2D(42.0, -98.0))
        ]
        let center = annotations.center()

        #expect(abs(center.latitude - 41.0) < 0.0001)
        #expect(abs(center.longitude - -99.0) < 0.0001)
    }

    @Test func `center four annotations`() {
        let annotations: [MKAnnotation] = [
            TestAnnotation(coordinate: CLLocationCoordinate2D(50.0, -110.0)),
            TestAnnotation(coordinate: CLLocationCoordinate2D(50.0, -90.0)),
            TestAnnotation(coordinate: CLLocationCoordinate2D(30.0, -110.0)),
            TestAnnotation(coordinate: CLLocationCoordinate2D(30.0, -90.0))
        ]
        let center = annotations.center()

        #expect(abs(center.latitude - 40.0) < 0.0001)
        #expect(abs(center.longitude - -100.0) < 0.0001)
    }

    @Test func `center negative coordinates`() {
        let annotations: [MKAnnotation] = [
            TestAnnotation(coordinate: CLLocationCoordinate2D(-34.6037, -58.3816)),
            TestAnnotation(coordinate: CLLocationCoordinate2D(-33.8688, 151.2093))
        ]
        let center = annotations.center()

        #expect(center.latitude < 0) // Should be in southern hemisphere
    }

    // MARK: - Sequence<MKAnnotation> coordinateRegion Tests

    @Test func `coordinate region annotations`() {
        let annotations: [MKAnnotation] = [
            TestAnnotation(coordinate: CLLocationCoordinate2D(40.0, -100.0)),
            TestAnnotation(coordinate: CLLocationCoordinate2D(42.0, -98.0))
        ]
        let region = annotations.coordinateRegion()

        #expect(abs(region.center.latitude - 41.0) < 0.0001)
        #expect(abs(region.center.longitude - -99.0) < 0.0001)
    }

    @Test func `coordinate region annotations with padding`() {
        let annotations: [MKAnnotation] = [
            TestAnnotation(coordinate: CLLocationCoordinate2D(40.0, -100.0)),
            TestAnnotation(coordinate: CLLocationCoordinate2D(42.0, -98.0))
        ]
        let region = annotations.coordinateRegion(padding: 5000)

        #expect(region.span.latitudeDelta > 0)
        #expect(region.span.longitudeDelta > 0)
    }
}
#endif
