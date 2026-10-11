# ``CalderUIKit``

UIKit and AppKit extensions, controllers, animations, layout helpers, and framework adapters.

Platform guards keep APIs available only where their system frameworks exist.

## Behavior and migration notes

Clustering requests now finish their map updates in submission order. Consecutive requests observe all changes made by preceding requests.

`MapClusteringController` now honors an explicitly supplied `minLongitudeDeltaToCluster`; omit the argument to retain the device-dependent default.

`UserNotificationService` and `UserNotificationServiceDelegate` are main-actor isolated. Access service state and implement delegate methods on the main actor; background callers must hop to that actor. System notification callbacks automatically deliver to the delegate on the main actor.

Notification callbacks complete even when the service's weak delegate has been released or cleared. Foreground notifications use no presentation options in that case.

A child transition with no previous child now inserts the new child into the supplied container and pins it to that container, matching subsequent transitions.

`BarcodeGenerator.qr` encodes payloads as UTF-8, so non-ASCII text such as "Café" produces a QR code. Code 128 and PDF417 barcodes still require ASCII payloads and return `nil` otherwise.

Generated barcodes use whole-number scale factors with nearest-neighbour sampling, and `BarcodeGenerator.createImage(barcode:quietSpace:)` returns an image with interpolation disabled so bars stay sharp at 2x and 3x. Code 128 barcodes now scale by 2 instead of 1.5, so they are wider than before.

The `center()` helpers on sequences of coordinates, locations, and annotations now return the spherical mean instead of the bounding-box midpoint, so centers across the antimeridian are correct. Results for other inputs shift slightly toward where the points are concentrated. Empty sequences, and sequences whose mean is undefined such as two antipodal points, now return `kCLLocationCoordinate2DInvalid` instead of `(0, 0)`; check the result with `CLLocationCoordinate2DIsValid(_:)`.
