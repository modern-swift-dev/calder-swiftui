#if canImport(Darwin)
#if canImport(MapKit) && !os(watchOS)
import Foundation
import MapKit
#if canImport(UIKit)
import UIKit
#endif

public extension MKMapView {

    /// Inserts an array of overlays at a specified index and level on the map view.
    /// - Parameters:
    ///   - overlays: An array of `MKOverlay` objects to insert.
    ///   - index: The index at which to insert the overlays.
    ///   - level: The `MKOverlayLevel` (e.g., .aboveRoads, .aboveLabels) at which to render the overlays.
    @MainActor func insertOverlays(_ overlays: [any MKOverlay], at index: Int, level: MKOverlayLevel) {
        for overlay in overlays {
            insertOverlay(overlay, at: max(0, index), level: level)
        }
    }

    /// Inserts an array of overlays above a specified existing overlay.
    /// - Parameters:
    ///   - overlays: An array of `MKOverlay` objects to insert.
    ///   - above: The `MKOverlay` object above which the new overlays will be inserted.
    @MainActor func insertOverlays(_ overlays: [any MKOverlay], above: any MKOverlay) {
        for overlay in overlays {
            insertOverlay(overlay, above: above)
        }
    }

    /// Inserts an array of overlays below a specified existing overlay.
    /// - Parameters:
    ///   - overlays: An array of `MKOverlay` objects to insert.
    ///   - below: The `MKOverlay` object below which the new overlays will be inserted.
    @MainActor func insertOverlays(_ overlays: [any MKOverlay], below: any MKOverlay) {
        for overlay in overlays {
            insertOverlay(overlay, below: below)
        }
    }

    /// Inserts an array of overlays below the first occurrence of a specified overlay type at a given level.
    /// - Parameters:
    ///   - overlays: An array of `MKOverlay` objects to insert.
    ///   - below: The type of `MKOverlay` below which the new overlays will be inserted.
    ///   - level: The `MKOverlayLevel` at which to render the overlays.
    @MainActor func insertOverlays(_ overlays: [any MKOverlay], below: (some MKOverlay).Type, level: MKOverlayLevel) {
        let index = firstIndexOf(overlayType: below)
        insertOverlays(overlays, at: index, level: level)
    }

    /// Inserts an array of overlays above the last occurrence of a specified overlay type at a given level.
    /// - Parameters:
    ///   - overlays: An array of `MKOverlay` objects to insert.
    ///   - above: The type of `MKOverlay` above which the new overlays will be inserted.
    ///   - level: The `MKOverlayLevel` at which to render the overlays.
    @MainActor func insertOverlays(_ overlays: [any MKOverlay], above: (some MKOverlay).Type, level: MKOverlayLevel) {
        let index = lastIndexOf(overlayType: above)
        insertOverlays(overlays, at: index, level: level)
    }

    /// Inserts a single overlay below the first occurrence of a specified overlay type at a given level.
    /// - Parameters:
    ///   - overlay: The `MKOverlay` object to insert.
    ///   - below: The type of `MKOverlay` below which the new overlay will be inserted.
    ///   - level: The `MKOverlayLevel` at which to render the overlay.
    @MainActor func insertOverlay(_ overlay: any MKOverlay, below: (some MKOverlay).Type, level: MKOverlayLevel) {
        let index = firstIndexOf(overlayType: below)
        insertOverlays([overlay], at: index, level: level)
    }

    /// Inserts a single overlay above the last occurrence of a specified overlay type at a given level.
    /// - Parameters:
    ///   - overlay: The `MKOverlay` object to insert.
    ///   - above: The type of `MKOverlay` above which the new overlay will be inserted.
    ///   - level: The `MKOverlayLevel` at which to render the overlay.
    @MainActor func insertOverlay(_ overlay: any MKOverlay, above: (some MKOverlay).Type, level: MKOverlayLevel) {
        let index = lastIndexOf(overlayType: above)
        insertOverlays([overlay], at: index, level: level)
    }
}

// MARK: Inspection

public extension MKMapView {

    /// Returns the first index of an overlay of the specified type, or 0 if no such overlay is found.
    /// - Parameter overlayType: The type of `MKOverlay` to search for.
    /// - Returns: The index of the first matching overlay, or 0.
    @MainActor func firstIndexOf<T: MKOverlay>(overlayType _: T.Type) -> Int {
        overlays.firstIndex { $0 is T } ?? 0
    }

    /// Returns the last index of an overlay of the specified type, or `Int.max` if no such overlay is found.
    /// - Parameter overlayType: The type of `MKOverlay` to search for.
    /// - Returns: The index of the last matching overlay, or `Int.max`.
    @MainActor func lastIndexOf<T: MKOverlay>(overlayType _: T.Type) -> Int {
        overlays.lastIndex { $0 is T } ?? Int.max
    }

    /// Returns all overlays of a specified type currently on the map.
    /// - Parameter type: The type of `MKOverlay` to filter by.
    /// - Returns: An array of `MKOverlay` objects matching the specified type.
    @MainActor func overlaysOf<T: MKOverlay>(type _: T.Type) -> [T] {
        overlays.compactMap { $0 as? T }
    }

    /// Returns all annotations of a specified type currently on the map.
    /// - Parameter type: The type of `MKAnnotation` to filter by.
    /// - Returns: An array of `MKAnnotation` objects matching the specified type.
    @MainActor func annotationsOf<T: MKAnnotation>(type _: T.Type) -> [T] {
        annotations.compactMap { $0 as? T }
    }
}

// MARK: Centering the MapView

public extension MKMapView {
    /// Centers and zooms the map view to encompass all annotations of a specified type.
    /// - Parameters:
    ///   - type: The type of `MKAnnotation` to center on.
    ///   - padding: The distance in meters to pad around the annotations.
    ///   - animated: A boolean indicating whether to animate the region change.
    @MainActor func centerAndZoomOnAnnotationType(
        type: (some MKAnnotation).Type,
        padding: CLLocationDistance,
        animated: Bool
    ) {
        centerAndZoomOnAnnotations(
            annotations: annotationsOf(type: type),
            padding: padding,
            animated: animated
        )
    }

    /// Centers and zooms the map view to encompass a given array of annotations.
    /// - Parameters:
    ///   - annotations: An array of `MKAnnotation` objects to center on.
    ///   - padding: The distance in meters to pad around the annotations.
    ///   - animated: A boolean indicating whether to animate the region change.
    @MainActor func centerAndZoomOnAnnotations(
        annotations: [any MKAnnotation],
        padding: CLLocationDistance,
        animated: Bool
    ) {
        guard !annotations.isEmpty else {
            return
        }
        let coordinates = annotations.map(\.coordinate)
        centerAndZoomOnLocations(coordinates: coordinates, padding: padding, animated: animated)
    }

    /// Centers and zooms the map view to encompass a given array of locations.
    /// - Parameters:
    ///   - locations: An array of `CLLocation` objects to center on (note: this parameter is unused in the current implementation, `annotations` is used instead).
    ///   - padding: The distance in meters to pad around the locations.
    ///   - animated: A boolean indicating whether to animate the region change.
    @MainActor func centerAndZoomOnAnnotations(
        padding: CLLocationDistance,
        animated: Bool
    ) {
        guard !annotations.isEmpty else {
            return
        }
        let coordinates = annotations.map(\.coordinate)
        centerAndZoomOnLocations(coordinates: coordinates, padding: padding, animated: animated)
    }

    /// Centers and zooms the map view to encompass a given array of coordinates.
    /// - Parameters:
    ///   - coordinates: An array of `CLLocationCoordinate2D` objects to center on.
    ///   - padding: The distance in meters to pad around the coordinates.
    ///   - animated: A boolean indicating whether to animate the region change.
    @MainActor func centerAndZoomOnLocations(
        coordinates: [CLLocationCoordinate2D],
        padding: CLLocationDistance,
        animated: Bool
    ) {
        guard !coordinates.isEmpty else {
            return
        }
        let region = coordinates.coordinateRegion(padding: padding)
        setRegion(region, animated: animated)
    }

    /// Centers the map view on a given array of overlays.
    /// The map will adjust its visible rect to fit all overlays.
    /// - Parameter overlays: An optional array of `MKOverlay` objects to center on.
    @MainActor func center(on overlays: [any MKOverlay]?) {
        guard let overlays, !overlays.isEmpty, let rect = overlays.boundingRect() else {
            return
        }
        setVisibleMapRect(rect, animated: true)
    }

    // Centers the map view on a given array of overlays with specified edge padding.
    // The map will adjust its visible rect to fit all overlays, respecting the padding.
    // - Parameters:
    //   - overlays: An optional array of `MKOverlay` objects to center on.
    //   - edges: The `UIEdgeInsets` to apply as padding around the overlays.
    #if canImport(UIKit)
    @MainActor func center(on overlays: [any MKOverlay]?, edges: UIEdgeInsets) {
        guard let overlays, !overlays.isEmpty, let rect = overlays.boundingRect() else {
            return
        }
        setVisibleMapRect(rect, edgePadding: edges, animated: true)
    }
    #endif
}
#endif

#endif
