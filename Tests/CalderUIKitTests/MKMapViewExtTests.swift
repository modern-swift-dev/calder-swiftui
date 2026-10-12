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
        /// The limit allows for MapKit's slow first start on a newly created CI simulator.
        @Suite(.serialized, .timeLimit(.minutes(5)))
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

            @Test func `center and zoom on locations empty leaves the region unchanged`() {
                let mapView = createMapView()
                let initial = mapView.region
                mapView.centerAndZoomOnLocations(coordinates: [], padding: 1000, animated: false)
                expectRegion(mapView.region, equals: initial)
            }

            @Test func `center and zoom on locations with coordinates`() {
                let mapView = createMapView()
                let coords = [
                    CLLocationCoordinate2D(40, -100),
                    CLLocationCoordinate2D(41, -99)
                ]
                mapView.centerAndZoomOnLocations(coordinates: coords, padding: 1000, animated: false)
                expectRegion(mapView.region, contains: coords)
            }

            @Test func `center and zoom on annotations empty leaves the region unchanged`() {
                let mapView = createMapView()
                let initial = mapView.region
                mapView.centerAndZoomOnAnnotations(annotations: [], padding: 1000, animated: false)
                expectRegion(mapView.region, equals: initial)
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
                expectRegion(mapView.region, contains: [ann1.coordinate, ann2.coordinate])
                cleanupMapView(mapView)
            }

            @Test func `center and zoom on annotation type`() {
                let mapView = createMapView()
                let ann = MKPointAnnotation()
                ann.coordinate = CLLocationCoordinate2D(40, -100)
                mapView.addAnnotation(ann)
                mapView.centerAndZoomOnAnnotationType(type: MKPointAnnotation.self, padding: 1000, animated: false)
                expectRegion(mapView.region, contains: [ann.coordinate])
                #expect(abs(mapView.region.center.latitude - 40) < 0.01)
                #expect(abs(mapView.region.center.longitude + 100) < 0.01)
                cleanupMapView(mapView)
            }

            // MARK: - Center on Overlays Tests

            @Test func `center on overlays nil leaves the visible rect unchanged`() async throws {
                let mapView = createMapView()
                let initial = mapView.visibleMapRect
                mapView.center(on: nil)
                // Centering animates, so give a change the time to land before checking.
                try await Task.sleep(for: .milliseconds(300))
                #expect(MKMapRectEqualToRect(mapView.visibleMapRect, initial))
            }

            @Test func `center on overlays empty leaves the visible rect unchanged`() async throws {
                let mapView = createMapView()
                let initial = mapView.visibleMapRect
                mapView.center(on: [])
                // Centering animates, so give a change the time to land before checking.
                try await Task.sleep(for: .milliseconds(300))
                #expect(MKMapRectEqualToRect(mapView.visibleMapRect, initial))
            }

            @Test func `center on overlays with overlay`() async throws {
                let mapView = createMapView()
                let circle = MKCircle(center: CLLocationCoordinate2D(40, -100), radius: 1000)
                mapView.center(on: [circle])
                try await waitUntil { Self.fits(circle.boundingMapRect, in: mapView.visibleMapRect) }
                cleanupMapView(mapView)
            }

            @Test func `center on overlays with edges nil leaves the visible rect unchanged`() async throws {
                let mapView = createMapView()
                let initial = mapView.visibleMapRect
                mapView.center(on: nil, edges: .zero)
                // Centering animates, so give a change the time to land before checking.
                try await Task.sleep(for: .milliseconds(300))
                #expect(MKMapRectEqualToRect(mapView.visibleMapRect, initial))
            }

            @Test func `center on overlays with edges empty leaves the visible rect unchanged`() async throws {
                let mapView = createMapView()
                let initial = mapView.visibleMapRect
                mapView.center(on: [], edges: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10))
                // Centering animates, so give a change the time to land before checking.
                try await Task.sleep(for: .milliseconds(300))
                #expect(MKMapRectEqualToRect(mapView.visibleMapRect, initial))
            }

            @Test func `center on overlays with edges with overlay`() async throws {
                let mapView = createMapView()
                let circle = MKCircle(center: CLLocationCoordinate2D(40, -100), radius: 1000)
                mapView.center(on: [circle], edges: UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20))
                try await waitUntil { Self.fits(circle.boundingMapRect, in: mapView.visibleMapRect) }
                cleanupMapView(mapView)
            }

            // MARK: - Helpers

            /// Whether `rect` lies inside `visible` and fills a meaningful part of it, so the map is zoomed on it.
            private static func fits(_ rect: MKMapRect, in visible: MKMapRect) -> Bool {
                visible.contains(rect) && rect.size.width > visible.size.width / 4
            }

            private func expectRegion(_ region: MKCoordinateRegion, equals expected: MKCoordinateRegion, sourceLocation: SourceLocation = #_sourceLocation) {
                #expect(abs(region.center.latitude - expected.center.latitude) < 1e-6, sourceLocation: sourceLocation)
                #expect(abs(region.center.longitude - expected.center.longitude) < 1e-6, sourceLocation: sourceLocation)
                #expect(abs(region.span.latitudeDelta - expected.span.latitudeDelta) < 1e-6, sourceLocation: sourceLocation)
                #expect(abs(region.span.longitudeDelta - expected.span.longitudeDelta) < 1e-6, sourceLocation: sourceLocation)
            }

            private func expectRegion(_ region: MKCoordinateRegion, contains coordinates: [CLLocationCoordinate2D], sourceLocation: SourceLocation = #_sourceLocation) {
                for coordinate in coordinates {
                    #expect(abs(coordinate.latitude - region.center.latitude) <= region.span.latitudeDelta / 2, sourceLocation: sourceLocation)
                    #expect(abs(coordinate.longitude - region.center.longitude) <= region.span.longitudeDelta / 2, sourceLocation: sourceLocation)
                }
                // Padding is in meters, so the region stays close to the coordinates rather than zooming out.
                #expect(region.span.latitudeDelta < 5, sourceLocation: sourceLocation)
                #expect(region.span.longitudeDelta < 5, sourceLocation: sourceLocation)
            }

            private func waitUntil(_ condition: () -> Bool, sourceLocation: SourceLocation = #_sourceLocation) async throws {
                let deadline = ContinuousClock.now.advanced(by: .seconds(5))
                while !condition(), ContinuousClock.now < deadline {
                    try await Task.sleep(for: .milliseconds(10))
                }
                #expect(condition(), sourceLocation: sourceLocation)
            }
        }
    #endif

#endif
