#if canImport(MapKit) && canImport(UIKit) && !os(watchOS)
    @testable import CalderUIKit
    import CoreLocation
    import MapKit
    import Testing
    import UIKit

    @Suite(.serialized, .timeLimit(.minutes(1)))
    @MainActor struct MapClusteringControllerTests {
        private final class TestMap: MapClusteringMap {
            var annotations: [any MKAnnotation] = []
            var region = MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: 45, longitude: -73),
                span: MKCoordinateSpan(latitudeDelta: 1, longitudeDelta: 1)
            )
            var superview: UIView? = UIView()

            func addAnnotations(_ annotations: [any MKAnnotation]) {
                for annotation in annotations where !self.annotations.contains(where: { $0 === annotation }) {
                    self.annotations.append(annotation)
                }
            }

            func removeAnnotations(_ annotations: [any MKAnnotation]) {
                self.annotations.removeAll { current in annotations.contains { $0 === current } }
            }
        }

        private final class Annotation: NSObject, MapClusterable {
            let id: String
            nonisolated let coordinate: CLLocationCoordinate2D

            init(id: String, latitude: Double = 45) {
                self.id = id
                coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: -73)
            }

            func update(value: any MapClusterable) -> Bool {
                false
            }

            func newCluster(center: CLLocationCoordinate2D) -> any MapCluster {
                Cluster(center: center)
            }
        }

        private final class Cluster: NSObject, MapCluster {
            let id = UUID().uuidString
            nonisolated let coordinate: CLLocationCoordinate2D
            var annotations: [any MapClusterable] = []
            var annotationCount: Int {
                annotations.count
            }

            init(center: CLLocationCoordinate2D) {
                coordinate = center
            }

            func add(annotation: any MapClusterable) {
                annotations.append(annotation)
            }

            func remove(annotation: any MapClusterable) -> Bool {
                let previous = annotations.count
                annotations.removeAll { $0.id == annotation.id }
                return annotations.count != previous
            }

            func replace(annotations: [any MapClusterable]) {
                self.annotations = annotations
            }

            func update() {}
            func update(annotation: any MapClusterable) -> Bool {
                false
            }
        }

        private func controllerWithReleasedMap() -> MapClusteringController {
            let map = TestMap()
            return MapClusteringController(map: map, clusterSize: 0.1, minLongitudeDeltaToCluster: 0)
        }

        @Test func `queued removal is visible to the following clustering request`() async {
            let map = TestMap()
            let removed = Annotation(id: "removed")
            let retained = Annotation(id: "retained")
            map.annotations = [removed, retained]
            let controller = MapClusteringController(map: map, clusterSize: 0.1, minLongitudeDeltaToCluster: 0)
            var completed: [Int] = []

            await withCheckedContinuation { continuation in
                controller.clusterize(removedAnnotations: [removed]) { completed.append(1) }
                controller.clusterize {
                    completed.append(2)
                    continuation.resume()
                }
            }

            #expect(completed == [1, 2])
            #expect(controller.clusterables(mode: .both).map(\.id) == ["retained"])
        }

        @Test func `back to back clustering replaces previously generated clusters`() async {
            let map = TestMap()
            map.annotations = [Annotation(id: "first"), Annotation(id: "second", latitude: 45.001)]
            let controller = MapClusteringController(map: map, clusterSize: 0.1, minLongitudeDeltaToCluster: 0)

            await withCheckedContinuation { continuation in
                controller.clusterize(clusterOnlyIfMoreThan: 2, completion: nil)
                controller.clusterize(clusterOnlyIfMoreThan: 2) { continuation.resume() }
            }

            #expect(controller.clusters().count == 1)
            #expect(Set(controller.clusterables(mode: .both).map(\.id)) == ["first", "second"])
        }

        @Test func `clustering a detached map calls completion once`() async {
            let map = TestMap()
            map.annotations = [Annotation(id: "first")]
            map.superview = nil
            let controller = MapClusteringController(map: map, clusterSize: 0.1, minLongitudeDeltaToCluster: 0)
            var calls = 0

            await withCheckedContinuation { continuation in
                controller.clusterize { calls += 1 }
                controller.clusterize { continuation.resume() }
            }

            #expect(calls == 1)
        }

        @Test func `clustering with nothing to cluster calls completion once`() async {
            let map = TestMap()
            let controller = MapClusteringController(map: map, clusterSize: 0.1, minLongitudeDeltaToCluster: 0)
            var calls = 0

            await withCheckedContinuation { continuation in
                controller.clusterize { calls += 1 }
                controller.clusterize { continuation.resume() }
            }

            #expect(calls == 1)
        }

        @Test func `clustering a released map calls completion once`() async {
            let controller = controllerWithReleasedMap()
            var calls = 0

            await withCheckedContinuation { continuation in
                controller.clusterize { calls += 1 }
                controller.clusterize { continuation.resume() }
            }

            #expect(calls == 1)
        }

        @Test func `region change without a significant zoom calls completion once`() async {
            let map = TestMap()
            map.annotations = [Annotation(id: "first")]
            let controller = MapClusteringController(map: map, clusterSize: 0.1, minLongitudeDeltaToCluster: 0)
            await withCheckedContinuation { continuation in
                controller.clusterize { continuation.resume() }
            }
            var calls = 0

            // The span is unchanged since the last clustering, so the change does not re-cluster.
            await withCheckedContinuation { continuation in
                controller.mapViewRegionDidChange { calls += 1 }
                controller.clusterize { continuation.resume() }
            }

            #expect(calls == 1)
        }

        @Test func `region change on a released map calls completion once`() async {
            let controller = controllerWithReleasedMap()
            var calls = 0

            await withCheckedContinuation { continuation in
                controller.mapViewRegionDidChange { calls += 1 }
                controller.clusterize { continuation.resume() }
            }

            #expect(calls == 1)
        }

        @Test func `coordinate ordering is a strict weak ordering`() {
            let coordinate = CLLocationCoordinate2D(latitude: 45, longitude: -73)
            let sameCoordinate = CLLocationCoordinate2D(latitude: 45, longitude: -73)
            let east = CLLocationCoordinate2D(latitude: 45, longitude: -72)
            let north = CLLocationCoordinate2D(latitude: 46, longitude: -74)

            #expect(!MapClusteringController.isOrderedBefore(coordinate, sameCoordinate))
            #expect(!MapClusteringController.isOrderedBefore(sameCoordinate, coordinate))
            #expect(MapClusteringController.isOrderedBefore(coordinate, east))
            #expect(!MapClusteringController.isOrderedBefore(east, coordinate))
            #expect(MapClusteringController.isOrderedBefore(east, north))
            #expect(!MapClusteringController.isOrderedBefore(north, east))
        }

        @Test func `public initializer honors the supplied minimum longitude delta`() {
            let map = MKMapView(frame: .zero)
            defer {
                map.showsUserLocation = false
                map.delegate = nil
                map.removeFromSuperview()
            }
            let controller = MapClusteringController(mapView: map, minLongitudeDeltaToCluster: 2)

            #expect(controller.minLongitudeDeltaToCluster == 2)
        }

        @Test func `minimum longitude delta prevents clustering below the configured threshold`() async {
            let map = TestMap()
            map.annotations = [Annotation(id: "first"), Annotation(id: "second", latitude: 45.001)]
            let controller = MapClusteringController(map: map, clusterSize: 0.1, minLongitudeDeltaToCluster: 2)

            await withCheckedContinuation { continuation in
                controller.clusterize(clusterOnlyIfMoreThan: 2) { continuation.resume() }
            }

            #expect(controller.clusters().isEmpty)
            #expect(controller.clusterables().count == 2)
        }
    }
#endif
