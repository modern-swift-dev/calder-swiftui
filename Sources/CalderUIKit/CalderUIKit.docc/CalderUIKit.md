# ``CalderUIKit``

UIKit and AppKit extensions, controllers, animations, layout helpers, and framework adapters.

Platform guards keep APIs available only where their system frameworks exist.

## Behavior and migration notes

Clustering requests now finish their map updates in submission order. Consecutive requests observe all changes made by preceding requests.

`MapClusteringController` now honors an explicitly supplied `minLongitudeDeltaToCluster`; omit the argument to retain the device-dependent default.

`MapClusteringController.clusterize(newAnnotations:removedAnnotations:clusterOnlyIfMoreThan:completion:)` and `mapViewRegionDidChange(completion:)` now call their completion exactly once on every path, including when the map has been released or removed from its superview, when there is nothing to cluster, and when a region change does not require re-clustering. Completions run on the main actor after previously submitted requests.

`UserNotificationService` and `UserNotificationServiceDelegate` are main-actor isolated. Access service state and implement delegate methods on the main actor; background callers must hop to that actor. System notification callbacks automatically deliver to the delegate on the main actor.

Notification callbacks complete even when the service's weak delegate has been released or cleared. Foreground notifications use no presentation options in that case.

`UIContentSizeCategory.adjust(webView:)` now scales web text with the category. It sets `-webkit-text-size-adjust` to the body text style's size for the category relative to its size at `large`, such as `124%` for `extraExtraLarge`, instead of always `100%`.

A child transition with no previous child now inserts the new child into the supplied container and pins it to that container, matching subsequent transitions.

`BarcodeGenerator.qr` encodes payloads as UTF-8, so non-ASCII text such as "Café" produces a QR code. Code 128 and PDF417 barcodes still require ASCII payloads and return `nil` otherwise.

Generated barcodes use whole-number scale factors with nearest-neighbour sampling, and `BarcodeGenerator.createImage(barcode:quietSpace:)` returns an image with interpolation disabled so bars stay sharp at 2x and 3x. Code 128 barcodes now scale by 2 instead of 1.5, so they are wider than before.

The `center()` helpers on sequences of coordinates, locations, and annotations now return the spherical mean instead of the bounding-box midpoint, so centers across the antimeridian are correct. Results for other inputs shift slightly toward where the points are concentrated. Empty sequences, and sequences whose mean is undefined such as two antipodal points, now return `kCLLocationCoordinate2DInvalid` instead of `(0, 0)`; check the result with `CLLocationCoordinate2DIsValid(_:)`.

The `coordinateRegion(padding:)` helpers now size each axis independently: the latitude delta spans the latitudes and the longitude delta spans the longitudes, each extended by `padding`. They previously produced a square region sized by the larger axis. Empty sequences now return `MKCoordinateRegion()`, which has a zero center and a zero span, instead of a region spanning the whole globe.

`CLLocationCoordinate2D.distanceInMeters(from:)` now scales longitude differences by the cosine of the mean latitude, so it matches `CLLocation.distance(from:)` for short distances. East-west distances away from the equator are shorter than before, which makes `isNear(_:thresholdInMeters:)` match more coordinates at high latitudes.

The `MKMapView` overlay insertion helpers now keep overlays in the order given instead of reversing them. Type-based helpers find the overlay type within the requested level rather than across all levels, and the `above:` variants insert above the last matching overlay instead of below it.

`SwiftUISceneDelegate.createRootView(_:)` now returns `AnyView`, so subclasses can override it to supply their root view; wrap the view in `AnyView`. The default root view is SwiftUI's `EmptyView`.

Child view controller helpers send each containment callback once, in the order UIKit documents. `transition(fromChild:toNewChild:inContainerView:duration:delay:completion:)` and `fadeOut(duration:delay:completion:)` remove the outgoing view controller before calling `completion`. `UIViewController.CompletionHandler` is now `@MainActor () -> Void` instead of `@Sendable () -> Void`.

The system-spacing anchor helpers (`eqAfter`, `leqAfter`, `geqAfter`, `eqBelow`, `leqBelow`, and `geqBelow`) default `multiplier` to `1`, producing one system spacing. Pass `multiplier: 0` to keep the previous zero spacing.

CalderUIKit no longer declares retroactive `Sendable` conformances for `UNUserNotificationCenter`, `UNNotificationSettings`, `WKWebsiteDataStore`, or `WKHTTPCookieStore`. Code that relied on them must keep these values in one isolation domain; the WebKit types are main-actor isolated. `UNUserNotificationCenter.settings` now reads the settings of the center it is called on instead of always using `UNUserNotificationCenter.current()`.

`UIApplication.suspendApplication()` and `UIApplication.exitApplication(_:code:)` are deprecated. `suspendApplication()` no longer sends a private selector and does nothing. `exitApplication(_:code:)` waits without blocking the main thread and no longer suspends the app before exiting. Apps should let the user leave instead of suspending or terminating themselves.

`UITableView.indexPathForLastRow(inSection:)`, `UICollectionView.indexPathForLastItem(inSection:)`, `indexPathForLastRow`, and `indexPathForLastItem` return `nil` for empty or out-of-range sections instead of row or item 0. `UITableView.safeScrollToRow(at:at:animated:)` ignores negative indices.

The `CGRect` corner, mid-edge, and `center` helpers now account for the rectangle's origin. `topLeft` returns `(minX, minY)` instead of `.zero`, `topRight` and `bottomLeft` use `minY` and `minX`, and `center` returns `(midX, midY)` instead of `(minX, midY)`.

`CGContext.drawText(text:rect:font:color:)` now draws into the receiving context instead of the current UIKit or AppKit graphics context.

`CGContext.drawStar(rect:color:nbPoint:)` now centres the star in `rect`, sizes it to the shorter side, and draws a star with `nbPoint` tips for both odd and even counts. `CGContext.drawSquare(frame:fillColor:strokeWidth:strokeColor:)` now fills before stroking, so the whole stroke is visible.

`UIImage.resize(_:_:_:)` now scales the whole image to the target size when the aspect ratio is not kept, instead of cropping it. `resize(_:_:_:)` and `resizeToFit(_:_:)` account for orientation overrides that swap width and height, and render with `UIGraphicsImageRenderer` at the preferred format scale instead of `UIScreen.main.scale`.

`ColorRanges(_:_:)` and `ColorRanges(_:_:_:)` now convert color components to the 0–255 scale used by `ColorRange`, so `fuzz` is likewise expressed on the 0–255 scale. They also normalize each component range when the two colors are not ordered instead of crashing. `UIImage.withColorMasked(_:_:)` now masks images that have an alpha channel instead of returning `nil`.

`UIImage.base64URLJpg()` now encodes JPEG data (at compression quality `1.0`) instead of labelling PNG data as `image/jpeg`. `base64URLPng()` and `base64URLJpg()` no longer insert line breaks into the Base64 payload. `base64()` and `base64String()` are unchanged and still wrap at 64 characters.

`CIImage.writePNG(uiImage:)` and `CIImage.writeJpeg(uiImage:compression:)` now throw `CIImage.WriteError.encodingFailed` when the image cannot be encoded, instead of returning a URL to a file that was never written.
