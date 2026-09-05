# ``CalderUIKit``

UIKit and AppKit extensions, controllers, animations, layout helpers, and framework adapters.

Platform guards keep APIs available only where their system frameworks exist.

## Behavior and migration notes

Clustering requests now finish their map updates in submission order. Consecutive requests observe all changes made by preceding requests.

`MapClusteringController` now honors an explicitly supplied `minLongitudeDeltaToCluster`; omit the argument to retain the device-dependent default.

`UserNotificationService` and `UserNotificationServiceDelegate` are main-actor isolated. Access service state and implement delegate methods on the main actor; background callers must hop to that actor. System notification callbacks automatically deliver to the delegate on the main actor.
