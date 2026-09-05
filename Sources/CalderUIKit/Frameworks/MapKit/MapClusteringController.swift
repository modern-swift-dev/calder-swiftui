#if canImport(Darwin)
#if canImport(MapKit) && canImport(UIKit) && !os(watchOS)

import CalderStdLib
import Foundation
import MapKit
import os
import UIKit

/**
 * Protocol for clusters
 */
@MainActor public protocol MapCluster: MKAnnotation {

    /// A unique identifier for the cluster.
    var id: String { get }
    /// The array of `MapClusterable` annotations contained within this cluster.
    var annotations: [any MapClusterable] { get }
    /// The number of annotations currently in the cluster.
    var annotationCount: Int { get }

    /// Adds a new `MapClusterable` annotation to the cluster.
    /// - Parameter annotation: The new annotation to add.
    func add(annotation: any MapClusterable)

    /// Removes an annotation from the cluster.
    /// - Parameter annotation: The annotation to remove.
    /// - Returns: `true` if the annotation was successfully removed, `false` otherwise.
    @discardableResult func remove(annotation: any MapClusterable) -> Bool

    /// Replaces all existing annotations in the cluster with a new set of annotations.
    /// - Parameter annotations: The new array of `MapClusterable` annotations.
    func replace(annotations: [any MapClusterable])

    /// Invoked by the `MapClusteringController` to update the cluster's visual representation (e.g., title/subtitle).
    func update()

    /// Updates an existing annotation within the cluster with new data.
    /// The update is based on matching `id` and type.
    /// - Parameter annotation: The `MapClusterable` annotation with updated values.
    /// - Returns: `true` if the annotation was successfully updated, `false` otherwise.
    @discardableResult func update(annotation: any MapClusterable) -> Bool

}

/**
 Protocol to implement for all clusterable
 */
@MainActor public protocol MapClusterable: MKAnnotation {

    /// A unique identifier for the clusterable annotation.
    var id: String { get }

    /// Updates the `MapClusterable` with the latest data.
    /// The update occurs only if the `id` and type match.
    /// - Parameter value: The `MapClusterable` instance containing the latest data.
    /// - Returns: `true` if the annotation was successfully updated, `false` otherwise.
    @discardableResult func update(value: any MapClusterable) -> Bool

    /// Creates a new empty cluster for clusterization purposes.
    /// - Parameter center: The `CLLocationCoordinate2D` for the new cluster's center.
    /// - Returns: A new empty `MapCluster` instance.
    func newCluster(center: CLLocationCoordinate2D) -> any MapCluster
}

/// A class to help with the clustering of annotations
@MainActor open class MapClusteringController {

    /// Defines the mode for exploding (retrieving) clusterable annotations.
    public enum ExplodingMode {
        /// Return only individual, non-clustered annotations.
        case clusterable
        /// Return only clustered annotations (the cluster objects themselves).
        case clustered
        /// Return both individual and clustered annotations (with clustered annotations' internal members included).
        case both
    }

    /// Minimal Longitude Delta to consider for clusterization
    let minLongitudeDeltaToCluster: CLLocationDegrees

    /// Size of a cluster
    fileprivate let clusterSize: CLLocationDegrees

    /// Longitude Delta Tolerance factor, usign when the viewport moves on the map
    fileprivate let longitudeDeltaDiffToleranceFactor: CLLocationDegrees

    /// Batch size of pins to show on the map at the same time
    fileprivate let batchSize: Int

    /// The map view
    private weak var map: (any MapClusteringMap)?

    /// The Last Delta of the map
    fileprivate var lastLongitudeDeltaUsedForClustering: CLLocationDegrees = 0.0

    /// The serial q
    private lazy var serialQ = AsyncOperationSerialQueue()

    /// Initializer methods
    /// - parameter mapView: The Map
    /// - parameter clusterSize: Cluster Size in degrees
    /// - parameter longitudeDeltaDiffToleranceFactor: The tolerance of the delta when the viewport moves
    /// - parameter minLongitudeDeltaToCluster: Minimal Longitude Delta to cluster
    public init(
        mapView: MKMapView,
        clusterSize: CLLocationDegrees? = nil,
        longitudeDeltaDiffToleranceFactor: CLLocationDegrees = 0.015,
        minLongitudeDeltaToCluster: CLLocationDegrees? = nil,
        batchSize: Int = 100
    ) {
        map = mapView
        self.minLongitudeDeltaToCluster = minLongitudeDeltaToCluster ?? Self.getMinLongitudeDeltaToCluster(mapView)
        self.batchSize = batchSize
        self.longitudeDeltaDiffToleranceFactor = longitudeDeltaDiffToleranceFactor
        self.clusterSize = clusterSize ?? Self.getDefaultClusterSize(mapView)
    }

    init(
        map: any MapClusteringMap,
        clusterSize: CLLocationDegrees,
        minLongitudeDeltaToCluster: CLLocationDegrees,
        longitudeDeltaDiffToleranceFactor: CLLocationDegrees = 0.015
    ) {
        self.map = map
        self.clusterSize = clusterSize
        self.minLongitudeDeltaToCluster = minLongitudeDeltaToCluster
        self.longitudeDeltaDiffToleranceFactor = longitudeDeltaDiffToleranceFactor
        batchSize = 100
    }

    /// Return the default cluster size in degrees
    class func getDefaultClusterSize(_ view: MKMapView) -> CLLocationDegrees {
        let sizeClasses = (view.traitCollection.horizontalSizeClass, view.traitCollection.verticalSizeClass)
        switch sizeClasses {
            case (.compact, .compact):
                return 2750.metersToDegrees
            case (.compact, .regular):
                return 2750.metersToDegrees
            case (.regular, .compact):
                return 2750.metersToDegrees
            case (.regular, .regular):
                return 5500.metersToDegrees
            default:
                return 2750.metersToDegrees
        }
    }

    /// Return the minimal longitude delta in degrees
    class func getMinLongitudeDeltaToCluster(_ view: MKMapView) -> CLLocationDegrees {
        let sizeClasses = (view.traitCollection.horizontalSizeClass, view.traitCollection.verticalSizeClass)
        switch sizeClasses {
            case (.compact, .compact):
                return 2750.metersToDegrees
            case (.compact, .regular):
                return 2750.metersToDegrees
            case (.regular, .compact):
                return 2750.metersToDegrees
            case (.regular, .regular):
                return 5500.metersToDegrees
            default:
                return 2750.metersToDegrees
        }
    }

    /// Returns a list of `MapClusterable` annotations currently displayed on the map.
    /// - Parameter mode: The `ExplodingMode` to determine which types of annotations (clusterable, clustered, or both) to include. Defaults to `.clusterable`.
    /// - Returns: An array of `MapClusterable` annotations.
    public func clusterables(mode: ExplodingMode = .clusterable) -> [any MapClusterable] {
        var clusterables = [any MapClusterable]()
        if let map {
            for annotation in map.annotations {

                if let clusterable = annotation as? (any MapClusterable), mode == .clusterable || mode == .both {
                    clusterables.append(clusterable)
                }

                if let cluster = annotation as? (any MapCluster), mode == .clustered || mode == .both {
                    for clusterable in cluster.annotations {
                        clusterables.append(clusterable)
                    }
                }
            }
        }
        return clusterables
    }

    /// Returns a list of `MapCluster` objects (clusters) currently displayed on the map.
    /// - Returns: An array of `MapCluster` objects.
    public func clusters() -> [any MapCluster] {
        var clusters = [any MapCluster]()
        if let map {
            for annotation in map.annotations {
                if let cluster = annotation as? any MapCluster {
                    clusters.append(cluster)
                }
            }
        }
        return clusters
    }

    /// Callback for when the MapView's region changes.
    /// This method triggers re-clustering if the longitude delta difference exceeds the tolerance factor.
    /// - Parameter completion: An optional closure to be called after the clustering process is complete.
    public func mapViewRegionDidChange(completion: (() -> Void)?) {
        guard let map else {
            return
        }

        // Prevent re-clustering on a simple map view pan
        let diff = fabs(lastLongitudeDeltaUsedForClustering - map.region.span.longitudeDelta)
        if diff > longitudeDeltaDiffToleranceFactor {
            clusterize(completion: completion)
        }
    }

    /// Performs the clustering logic on the map.
    /// Requests execute in submission order on the main actor, including their state updates.
    /// - Parameters:
    ///   - newAnnotations: An array of new `MapClusterable` annotations to add to the map. Defaults to an empty array.
    ///   - removedAnnotations: An array of `MapClusterable` annotations to remove from the map. Defaults to an empty array.
    ///   - clusterOnlyIfMoreThan: The minimum number of clusterable annotations required to initiate clustering. Defaults to 20.
    ///   - completion: An optional closure to be called after the clustering process is complete.
    public func clusterize(
        newAnnotations: [any MapClusterable] = [any MapClusterable](),
        removedAnnotations: [any MapClusterable] = [any MapClusterable](),
        clusterOnlyIfMoreThan: Int = 20,
        completion: (() -> Void)?
    ) {

        serialQ.enqueue { [weak self] in

            // Generic Validation, check if the map is still displayed
            guard let self, let map = self.map, map.superview != nil else {
                return
            }

            // --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
            // Step 1 - Extract the current MapView state (Thread-bound to the main-thread)
            // --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
            var allClusterables = self.clusterables(mode: .both).hashMap { ($0.id, $0) }
            var allRemoved = [any MKAnnotation]()
            for cluster in self.clusters() {
                allRemoved.append(cluster)
            }

            guard !allClusterables.isEmpty || !newAnnotations.isEmpty || !removedAnnotations.isEmpty else {
                return
            }

            let longitudeDelta = map.region.span.longitudeDelta
            let minDelta = self.minLongitudeDeltaToCluster
            let radius = longitudeDelta * self.clusterSize
            let center = map.region.center

            for removedAnnotation in removedAnnotations {
                allClusterables.removeValue(forKey: removedAnnotation.id)
                allRemoved.append(removedAnnotation)
            }

            for newAnnotation in newAnnotations {
                if let previous = allClusterables[newAnnotation.id] {
                    allRemoved.append(previous)
                }
                allClusterables[newAnnotation.id] = newAnnotation
            }

            var newClusters = [any MapCluster]()
            if allClusterables.count >= clusterOnlyIfMoreThan {
                self.resolveClusters(
                    clusterables: &allClusterables,
                    removed: &allRemoved,
                    newClusters: &newClusters,
                    center: center,
                    longitudeDelta: longitudeDelta,
                    minDelta: minDelta,
                    radius: radius
                )
            }

            map.removeAnnotations(allRemoved)
            map.addAnnotations(Array(allClusterables.values))
            map.addAnnotations(Array(newClusters))
            self.lastLongitudeDeltaUsedForClustering = longitudeDelta
            completion?()
        }
    }

    /// Resolves and creates new clusters from a given set of clusterable annotations.
    /// This method is designed to be called internally during the clustering process.
    /// - Parameters:
    ///   - clusterables: An in-out dictionary of `MapClusterable` annotations, which will be modified as annotations are moved into clusters.
    ///   - removed: An in-out array of `MKAnnotation` objects that will be removed from the map (includes original clustered annotations).
    ///   - newClusters: An in-out array where newly formed `MapCluster` objects will be appended.
    ///   - center: The center coordinate of the map region (currently unused in logic but kept for context).
    ///   - longitudeDelta: The current longitude delta of the map region.
    ///   - minDelta: The minimum longitude delta at which clustering should occur.
    ///   - radius: The clustering radius in degrees.
    fileprivate func resolveClusters(
        clusterables: inout [String: any MapClusterable],
        removed: inout [any MKAnnotation],
        newClusters: inout [any MapCluster],
        center _: CLLocationCoordinate2D,
        longitudeDelta: CLLocationDegrees,
        minDelta: CLLocationDegrees,
        radius: CLLocationDegrees
    ) {

        // Step 1: If the zoom level is too narrow, no clustering to be had.
        // we will remove all clusters
        guard longitudeDelta > minDelta else {
            return
        }

        // Step 2: Build the full clusterable arrays, and sort according to lat/lon
        var allClusterables = [any MapClusterable]()
        allClusterables.append(contentsOf: clusterables.values)
        allClusterables.sort { first, second -> Bool in
            let loc1 = first.coordinate
            let loc2 = second.coordinate
            if loc1.latitude < loc2.latitude {
                return true
            }
            if loc1.latitude > loc2.latitude {
                return false
            }
            if loc1.longitude < loc2.longitude {
                return true
            }
            if loc1.longitude > loc2.longitude {
                return false
            }
            return true
        }

        // Step 3: Compute all the candidate  clusters.
        var candidateClusters = [any MapCluster]()
        for candidate in allClusterables {

            var isContaining = false
            for candidateCluster in candidateClusters where candidate.coordinate.isNear(candidateCluster.coordinate, threshold: radius) && !isContaining {
                isContaining = true
                candidateCluster.add(annotation: candidate)
            }

            // If the annotation is not in a Cluster make it to a new one
            if !isContaining {
                let newCluster = candidate.newCluster(center: candidate.coordinate)
                newCluster.add(annotation: candidate)
                candidateClusters.append(newCluster)
            }
        }

        // Step 4: Filter out all candidate clusters with 1 annotation or less.
        // Remove

        candidateClusters.filter {
            $0.annotationCount > 1
        }.forEach { candidateCluster in
            for ann in candidateCluster.annotations {
                clusterables.removeValue(forKey: ann.id)
                removed.append(ann)
            }
            candidateCluster.update()
            newClusters.append(candidateCluster)
        }
    }
}
#endif

#endif
