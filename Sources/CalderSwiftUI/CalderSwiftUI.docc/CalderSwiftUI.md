# ``CalderSwiftUI``

SwiftUI values, views, environment support, and extensions.

The module includes async-value rendering, color conversion, gradients, image conversion, and view helpers.

On platforms that support keyboard observation, `KeyboardObserver` and the `keyboardObserver` environment value are main-actor isolated. Create observers and access their state from `@MainActor` code. The environment retains a shared default observer; supplying a custom observer through `.environment(\.keyboardObserver, observer)` overrides it for that environment. Each observer maintains its notification subscriptions for its lifetime.
