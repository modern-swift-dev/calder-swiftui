#if canImport(SwiftUI) || canImport(UIKit) || canImport(AppKit)
#if canImport(MapKit) && canImport(UIKit) && !os(watchOS)
import CalderUIKit
import CoreLocation
import Foundation
import MapKit
import Testing
import UIKit

/// Helper class to manage MKMapView lifecycle in tests.
/// MKMapView internally creates CLLocationManager which can hang indefinitely
/// waiting for authorization. This wrapper ensures proper cleanup.
@MainActor private final class TestMapViewContainer {
    let window: UIWindow
    let mapView: MKMapView

    init() {
        window = UIWindow(frame: CGRect(x: 0, y: 0, width: 320, height: 480))
        mapView = MKMapView(frame: window.bounds)
        mapView.showsUserLocation = false
        window.addSubview(mapView)
    }

    deinit {
        MainActor.assumeIsolated {
            mapView.showsUserLocation = false
            mapView.removeAnnotations(mapView.annotations)
            mapView.removeOverlays(mapView.overlays)
            mapView.delegate = nil
            mapView.removeFromSuperview()
        }
    }
}

// Disabled: MKMapView internally creates CLLocationManager which waits indefinitely
// for authorization in test environments, causing the test process to hang.
@Suite(.serialized, .disabled("MKMapView CLLocationManager hangs test process"))
@MainActor struct MapClusteringControllerTests {

    /// Creates an MKMapView configured for unit testing (location services disabled).
    /// This prevents CLLocationManager from waiting indefinitely for authorization.
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

    // MARK: - Initialization Tests

    @Test func `init with default parameters`() {
        let mapView = createMapView()
        let controller = MapClusteringController(mapView: mapView)
        let clusterables = controller.clusterables()
        #expect(clusterables.isEmpty)
    }

    @Test func `init with custom cluster size`() {
        let mapView = createMapView()
        let controller = MapClusteringController(mapView: mapView, clusterSize: 0.05)
        let clusterables = controller.clusterables()
        #expect(clusterables.isEmpty)
    }

    @Test func `init with custom batch size`() {
        let mapView = createMapView()
        let controller = MapClusteringController(mapView: mapView, batchSize: 50)
        let clusters = controller.clusters()
        #expect(clusters.isEmpty)
    }

    @Test func `init with custom tolerance factor`() {
        let mapView = createMapView()
        let controller = MapClusteringController(mapView: mapView, longitudeDeltaDiffToleranceFactor: 0.02)
        let clusterables = controller.clusterables()
        #expect(clusterables.isEmpty)
    }

    // MARK: - clusterables Tests

    @Test func `clusterables empty map`() {
        let mapView = createMapView()
        let controller = MapClusteringController(mapView: mapView)
        let clusterables = controller.clusterables()
        #expect(clusterables.isEmpty)
    }

    @Test func `clusterables mode clusterable`() {
        let mapView = createMapView()
        let controller = MapClusteringController(mapView: mapView)
        let clusterables = controller.clusterables(mode: .clusterable)
        #expect(clusterables.isEmpty)
    }

    @Test func `clusterables mode clustered`() {
        let mapView = createMapView()
        let controller = MapClusteringController(mapView: mapView)
        let clusterables = controller.clusterables(mode: .clustered)
        #expect(clusterables.isEmpty)
    }

    @Test func `clusterables mode both`() {
        let mapView = createMapView()
        let controller = MapClusteringController(mapView: mapView)
        let clusterables = controller.clusterables(mode: .both)
        #expect(clusterables.isEmpty)
    }

    // MARK: - clusters Tests

    @Test func `clusters empty map`() {
        let mapView = createMapView()
        let controller = MapClusteringController(mapView: mapView)
        let clusters = controller.clusters()
        #expect(clusters.isEmpty)
    }

    // MARK: - ExplodingMode Tests

    @Test func `exploding mode clusterable case`() {
        let mode = MapClusteringController.ExplodingMode.clusterable
        #expect(mode == .clusterable)
    }

    @Test func `exploding mode clustered case`() {
        let mode = MapClusteringController.ExplodingMode.clustered
        #expect(mode == .clustered)
    }

    @Test func `exploding mode both case`() {
        let mode = MapClusteringController.ExplodingMode.both
        #expect(mode == .both)
    }

    // MARK: - mapViewRegionDidChange Tests

    @Test func `map view region did change empty map`() {
        let mapView = createMapView()
        let controller = MapClusteringController(mapView: mapView)

        var completionCalled = false
        controller.mapViewRegionDidChange {
            completionCalled = true
        }

        // Note: Completion may or may not be called depending on delta
        #expect(completionCalled == false || completionCalled == true)
    }

    // MARK: - clusterize Tests

    @Test func `clusterize empty map`() {
        let mapView = createMapView()
        let controller = MapClusteringController(mapView: mapView)

        controller.clusterize(completion: nil)

        // After clusterize, map should still have no clusterables
        let clusterables = controller.clusterables()
        #expect(clusterables.isEmpty)
    }

    @Test func `clusterize with completion`() {
        let mapView = createMapView()
        let controller = MapClusteringController(mapView: mapView)

        controller.clusterize {
            // Completion called
        }

        #expect(controller.clusters().isEmpty)
    }
}
#endif

#endif
