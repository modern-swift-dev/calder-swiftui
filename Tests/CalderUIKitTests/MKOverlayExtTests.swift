#if canImport(MapKit) && !os(watchOS)
import CalderUIKit
import CoreLocation
import Foundation
import MapKit
import Testing

@Suite(.serialized) struct MKOverlayExtTests {

    // MARK: - boundingRect Tests

    @Test func `bounding rect empty sequence`() {
        let overlays: [MKOverlay] = []
        let rect = overlays.boundingRect()
        #expect(rect == nil)
    }

    @Test func `bounding rect single overlay`() {
        let circle = MKCircle(center: CLLocationCoordinate2D(40, -100), radius: 1000)
        let overlays: [MKOverlay] = [circle]
        let rect = overlays.boundingRect()
        #expect(rect != nil)
        if let rect {
            #expect(rect.width > 0)
            #expect(rect.height > 0)
        }
    }

    @Test func `bounding rect multiple overlays`() {
        let circle1 = MKCircle(center: CLLocationCoordinate2D(40, -100), radius: 1000)
        let circle2 = MKCircle(center: CLLocationCoordinate2D(41, -99), radius: 2000)
        let overlays: [MKOverlay] = [circle1, circle2]
        let rect = overlays.boundingRect()
        #expect(rect != nil)
        if let rect {
            #expect(rect.width > circle1.boundingMapRect.width)
            #expect(rect.height > circle1.boundingMapRect.height)
        }
    }

    @Test func `bounding rect with polygon`() {
        var coords = [
            CLLocationCoordinate2D(40, -100),
            CLLocationCoordinate2D(41, -100),
            CLLocationCoordinate2D(41, -99),
            CLLocationCoordinate2D(40, -99)
        ]
        let polygon = MKPolygon(coordinates: &coords, count: coords.count)
        let overlays: [MKOverlay] = [polygon]
        let rect = overlays.boundingRect()
        #expect(rect != nil)
    }

    @Test func `bounding rect mixed overlays`() {
        let circle = MKCircle(center: CLLocationCoordinate2D(40, -100), radius: 1000)
        var coords = [
            CLLocationCoordinate2D(42, -98),
            CLLocationCoordinate2D(43, -98),
            CLLocationCoordinate2D(43, -97),
            CLLocationCoordinate2D(42, -97)
        ]
        let polygon = MKPolygon(coordinates: &coords, count: coords.count)
        let overlays: [MKOverlay] = [circle, polygon]
        let rect = overlays.boundingRect()
        #expect(rect != nil)
    }

    @Test func `bounding rect contains all overlays`() {
        let circle1 = MKCircle(center: CLLocationCoordinate2D(40, -100), radius: 500)
        let circle2 = MKCircle(center: CLLocationCoordinate2D(42, -98), radius: 500)
        let overlays: [MKOverlay] = [circle1, circle2]
        let rect = overlays.boundingRect()

        #expect(rect != nil)
        if let rect {
            #expect(rect.contains(circle1.boundingMapRect))
            #expect(rect.contains(circle2.boundingMapRect))
        }
    }
}
#endif
