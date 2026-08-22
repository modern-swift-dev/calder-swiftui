import Synchronization

/// Serializes asynchronous UI operations on the main actor.
final class AsyncOperationSerialQueue: Sendable {
    private struct State: Sendable {
        var tail: Task<Void, Never>?
    }

    private let state = Mutex(State())

    init() {}

    /// Schedules an operation after every operation submitted before it.
    /// - Parameter operation: Main-actor work to execute serially.
    func enqueue(
        _ operation: @escaping @MainActor @Sendable () async -> Void
    ) {
        state.withLock { state in
            let predecessor = state.tail
            state.tail = Task {
                await predecessor?.value
                await operation()
            }
        }
    }
}
