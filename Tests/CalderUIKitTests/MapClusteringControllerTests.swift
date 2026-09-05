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
        let superview: UIView? = UIView()

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

}
#endif
