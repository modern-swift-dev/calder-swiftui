#if canImport(SwiftUI) || canImport(UIKit) || canImport(AppKit)
    #if canImport(MapKit) && !os(watchOS) && canImport(UIKit)
        import CalderUIKit
        import CoreLocation
        import Foundation
        import MapKit
        import Testing
        import UIKit

        /// Runs a test with an MKMapView, ensuring proper cleanup to prevent
        /// CLLocationManager from hanging the test process.
        /// MKMapView internally creates CLLocationManager which can hang indefinitely
        /// waiting for authorization. This function ensures proper cleanup using autoreleasepool.
        @MainActor private func withTestMapView<T>(_ body: (MKMapView) throws -> T) rethrows -> T {
            try autoreleasepool {
                let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 320, height: 480))
                let mapView = MKMapView(frame: window.bounds)
                mapView.showsUserLocation = false
                window.addSubview(mapView)

                defer {
                    mapView.showsUserLocation = false
                    mapView.removeAnnotations(mapView.annotations)
                    mapView.removeOverlays(mapView.overlays)
                    mapView.delegate = nil
                    mapView.removeFromSuperview()
                    // Force cleanup by spinning the run loop
                    RunLoop.current.run(until: Date(timeIntervalSinceNow: 0.01))
                }

                return try body(mapView)
            }
        }

        /// MKMapView can create a CLLocationManager that waits for authorization in test
        /// environments; the time limit fails the suite instead of hanging the test process.
        @Suite(.serialized, .timeLimit(.minutes(1)))
        @MainActor struct MKMapViewExtTests {

            /// Legacy helper for backwards compatibility
            private func createMapView() -> MKMapView {
                let mapView = MKMapView(frame: CGRect(x: 0, y: 0, width: 320, height: 480))
                mapView.showsUserLocation = false
                return mapView
            }

            /// Cleans up an MKMapView to prevent hanging on CLLocationManager authorization.
            private func cleanupMapView(_ mapView: MKMapView) {
                mapView.showsUserLocation = false
                mapView.removeAnnotations(mapView.annotations)
                mapView.removeOverlays(mapView.overlays)
                mapView.delegate = nil
            }

            private func identifiers(_ overlays: [any MKOverlay]) -> [ObjectIdentifier] {
                overlays.map { ObjectIdentifier($0) }
            }

            private func circle() -> MKCircle {
                MKCircle(center: CLLocationCoordinate2D(40, -100), radius: 1000)
            }

            private func polyline() -> MKPolyline {
                MKPolyline(coordinates: [CLLocationCoordinate2D(40, -100), CLLocationCoordinate2D(41, -101)], count: 2)
            }

            /// Adds overlays to the `.aboveRoads` level so all-level indices differ from `.aboveLabels` indices.
            private func addRoadOverlays(to mapView: MKMapView) {
                mapView.addOverlays([polyline(), polyline()], level: .aboveRoads)
            }

            // MARK: - firstIndexOf Tests

            @Test func `first index of no overlays`() {
                let mapView = createMapView()
                let index = mapView.firstIndexOf(overlayType: MKCircle.self)
                #expect(index == 0)
            }

            @Test func `first index of with overlay`() {
                let mapView = createMapView()
                let circle = MKCircle(center: CLLocationCoordinate2D(40, -100), radius: 1000)
                mapView.addOverlay(circle)
                let index = mapView.firstIndexOf(overlayType: MKCircle.self)
                #expect(index == 0)
                cleanupMapView(mapView)
            }

            // MARK: - lastIndexOf Tests

            @Test func `last index of no overlays`() {
                let mapView = createMapView()
                let index = mapView.lastIndexOf(overlayType: MKCircle.self)
                #expect(index == Int.max)
            }

            @Test func `last index of with overlay`() {
                let mapView = createMapView()
                let circle = MKCircle(center: CLLocationCoordinate2D(40, -100), radius: 1000)
                mapView.addOverlay(circle)
                let index = mapView.lastIndexOf(overlayType: MKCircle.self)
                #expect(index == 0)
                cleanupMapView(mapView)
            }

            // MARK: - overlaysOf Tests

            @Test func `overlays of empty`() {
                let mapView = createMapView()
                let circles = mapView.overlaysOf(type: MKCircle.self)
                #expect(circles.isEmpty)
            }

            @Test func `overlays of with matching overlay`() {
                let mapView = createMapView()
                let circle = MKCircle(center: CLLocationCoordinate2D(40, -100), radius: 1000)
                mapView.addOverlay(circle)
                let circles = mapView.overlaysOf(type: MKCircle.self)
                #expect(circles.count == 1)
                cleanupMapView(mapView)
            }

            @Test func `overlays of with different overlay`() {
                let mapView = createMapView()
                let circle = MKCircle(center: CLLocationCoordinate2D(40, -100), radius: 1000)
                mapView.addOverlay(circle)
                let polygons = mapView.overlaysOf(type: MKPolygon.self)
                #expect(polygons.isEmpty)
                cleanupMapView(mapView)
            }

            // MARK: - annotationsOf Tests

            @Test func `annotations of empty`() {
                let mapView = createMapView()
                let pointAnnotations = mapView.annotationsOf(type: MKPointAnnotation.self)
                #expect(pointAnnotations.isEmpty)
            }

            @Test func `annotations of with annotation`() {
                let mapView = createMapView()
                let annotation = MKPointAnnotation()
                annotation.coordinate = CLLocationCoordinate2D(40, -100)
                mapView.addAnnotation(annotation)
                let pointAnnotations = mapView.annotationsOf(type: MKPointAnnotation.self)
                #expect(pointAnnotations.count == 1)
                cleanupMapView(mapView)
            }

            // MARK: - insertOverlays Tests

            @Test func `insert overlays at index`() {
                let mapView = createMapView()
                let circle = circle()
                mapView.insertOverlays([circle], at: 0, level: .aboveRoads)
                #expect(identifiers(mapView.overlays(in: .aboveRoads)) == identifiers([circle]))
                cleanupMapView(mapView)
            }

            @Test func `insert overlays multiple at index keeps their order`() {
                let mapView = createMapView()
                let base = circle()
                mapView.addOverlay(base, level: .aboveLabels)
                let first = polyline()
                let second = polyline()
                mapView.insertOverlays([first, second], at: 0, level: .aboveLabels)
                #expect(identifiers(mapView.overlays(in: .aboveLabels)) == identifiers([first, second, base]))
                cleanupMapView(mapView)
            }

            @Test func `insert overlays above keeps their order`() {
                let mapView = createMapView()
                let base = circle()
                let top = circle()
                mapView.addOverlays([base, top], level: .aboveLabels)
                let first = polyline()
                let second = polyline()
                mapView.insertOverlays([first, second], above: base)
                #expect(identifiers(mapView.overlays(in: .aboveLabels)) == identifiers([base, first, second, top]))
                cleanupMapView(mapView)
            }

            @Test func `insert overlays below keeps their order`() {
                let mapView = createMapView()
                let bottom = circle()
                let base = circle()
                mapView.addOverlays([bottom, base], level: .aboveLabels)
                let first = polyline()
                let second = polyline()
                mapView.insertOverlays([first, second], below: base)
                #expect(identifiers(mapView.overlays(in: .aboveLabels)) == identifiers([bottom, first, second, base]))
                cleanupMapView(mapView)
            }

            @Test func `insert overlays below type uses the index within the level`() {
                let mapView = createMapView()
                addRoadOverlays(to: mapView)
                let polygon = MKPolygon(coordinates: [], count: 0)
                let base = circle()
                mapView.addOverlays([polygon, base], level: .aboveLabels)
                let first = polyline()
                let second = polyline()
                mapView.insertOverlays([first, second], below: MKCircle.self, level: .aboveLabels)
                #expect(identifiers(mapView.overlays(in: .aboveLabels)) == identifiers([polygon, first, second, base]))
                cleanupMapView(mapView)
            }

            @Test func `insert overlays above type inserts above the last occurrence within the level`() {
                let mapView = createMapView()
                addRoadOverlays(to: mapView)
                let firstCircle = circle()
                let lastCircle = circle()
                let polygon = MKPolygon(coordinates: [], count: 0)
                mapView.addOverlays([firstCircle, lastCircle, polygon], level: .aboveLabels)
                let first = polyline()
                let second = polyline()
                mapView.insertOverlays([first, second], above: MKCircle.self, level: .aboveLabels)
                #expect(identifiers(mapView.overlays(in: .aboveLabels)) == identifiers([firstCircle, lastCircle, first, second, polygon]))
                cleanupMapView(mapView)
            }

            @Test func `insert overlays above missing type appends to the level`() {
                let mapView = createMapView()
                let polygon = MKPolygon(coordinates: [], count: 0)
                mapView.addOverlay(polygon, level: .aboveLabels)
                let first = polyline()
                let second = polyline()
                mapView.insertOverlays([first, second], above: MKCircle.self, level: .aboveLabels)
                #expect(identifiers(mapView.overlays(in: .aboveLabels)) == identifiers([polygon, first, second]))
                cleanupMapView(mapView)
            }

            @Test func `insert overlays below missing type inserts at the bottom of the level`() {
                let mapView = createMapView()
                let polygon = MKPolygon(coordinates: [], count: 0)
                mapView.addOverlay(polygon, level: .aboveLabels)
                let first = polyline()
                let second = polyline()
                mapView.insertOverlays([first, second], below: MKCircle.self, level: .aboveLabels)
                #expect(identifiers(mapView.overlays(in: .aboveLabels)) == identifiers([first, second, polygon]))
                cleanupMapView(mapView)
            }

            @Test func `insert overlay below type uses the index within the level`() {
                let mapView = createMapView()
                addRoadOverlays(to: mapView)
                let polygon = MKPolygon(coordinates: [], count: 0)
                let base = circle()
                mapView.addOverlays([polygon, base], level: .aboveLabels)
                let newOverlay = polyline()
                mapView.insertOverlay(newOverlay, below: MKCircle.self, level: .aboveLabels)
                #expect(identifiers(mapView.overlays(in: .aboveLabels)) == identifiers([polygon, newOverlay, base]))
                cleanupMapView(mapView)
            }

            @Test func `insert overlay above type inserts above the last occurrence within the level`() {
                let mapView = createMapView()
                addRoadOverlays(to: mapView)
                let base = circle()
                let polygon = MKPolygon(coordinates: [], count: 0)
                mapView.addOverlays([base, polygon], level: .aboveLabels)
                let newOverlay = polyline()
                mapView.insertOverlay(newOverlay, above: MKCircle.self, level: .aboveLabels)
                #expect(identifiers(mapView.overlays(in: .aboveLabels)) == identifiers([base, newOverlay, polygon]))
                cleanupMapView(mapView)
            }

            // MARK: - Center and Zoom Tests

            @Test func `center and zoom on locations empty`() {
                let mapView = createMapView()
                mapView.centerAndZoomOnLocations(coordinates: [], padding: 1000, animated: false)
                // Should not crash
                #expect(true)
            }

            @Test func `center and zoom on locations with coordinates`() {
                let mapView = createMapView()
                let coords = [
                    CLLocationCoordinate2D(40, -100),
                    CLLocationCoordinate2D(41, -99)
                ]
                mapView.centerAndZoomOnLocations(coordinates: coords, padding: 1000, animated: false)
                #expect(true)
            }

            @Test func `center and zoom on annotations empty`() {
                let mapView = createMapView()
                mapView.centerAndZoomOnAnnotations(annotations: [], padding: 1000, animated: false)
                #expect(true)
            }

            @Test func `center and zoom on annotations with annotations`() {
                let mapView = createMapView()
                let ann1 = MKPointAnnotation()
                ann1.coordinate = CLLocationCoordinate2D(40, -100)
                let ann2 = MKPointAnnotation()
                ann2.coordinate = CLLocationCoordinate2D(41, -99)
                mapView.addAnnotation(ann1)
                mapView.addAnnotation(ann2)
                mapView.centerAndZoomOnAnnotations(annotations: [ann1, ann2], padding: 1000, animated: false)
                #expect(true)
                cleanupMapView(mapView)
            }

            @Test func `center and zoom on annotation type`() {
                let mapView = createMapView()
                let ann = MKPointAnnotation()
                ann.coordinate = CLLocationCoordinate2D(40, -100)
                mapView.addAnnotation(ann)
                mapView.centerAndZoomOnAnnotationType(type: MKPointAnnotation.self, padding: 1000, animated: false)
                #expect(true)
                cleanupMapView(mapView)
            }

            // MARK: - Center on Overlays Tests

            @Test func `center on overlays nil`() {
                let mapView = createMapView()
                mapView.center(on: nil)
                #expect(true)
            }

            @Test func `center on overlays empty`() {
                let mapView = createMapView()
                mapView.center(on: [])
                #expect(true)
            }

            @Test func `center on overlays with overlay`() {
                let mapView = createMapView()
                let circle = MKCircle(center: CLLocationCoordinate2D(40, -100), radius: 1000)
                mapView.center(on: [circle])
                #expect(true)
                cleanupMapView(mapView)
            }

            @Test func `center on overlays with edges nil`() {
                let mapView = createMapView()
                mapView.center(on: nil, edges: .zero)
                #expect(true)
            }

            @Test func `center on overlays with edges empty`() {
                let mapView = createMapView()
                mapView.center(on: [], edges: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10))
                #expect(true)
            }

            @Test func `center on overlays with edges with overlay`() {
                let mapView = createMapView()
                let circle = MKCircle(center: CLLocationCoordinate2D(40, -100), radius: 1000)
                mapView.center(on: [circle], edges: UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20))
                #expect(true)
                cleanupMapView(mapView)
            }
        }
    #endif

#endif
