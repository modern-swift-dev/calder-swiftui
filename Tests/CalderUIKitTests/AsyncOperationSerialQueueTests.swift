@testable import CalderUIKit
import Testing

@MainActor struct AsyncOperationSerialQueueTests {
    @MainActor private final class Recorder {
        private(set) var completed: [Int] = []
        private(set) var overlapped = false
        private var isRunning = false

        func run(_ id: Int, yields: Int) async {
            if isRunning {
                overlapped = true
            }
            isRunning = true
            for _ in 0 ..< yields {
                await Task.yield()
            }
            completed.append(id)
            isRunning = false
        }
    }

    /// Waits until every operation enqueued before this call has finished.
    private func drain(_ queue: AsyncOperationSerialQueue) async {
        await withCheckedContinuation { continuation in
            queue.enqueue { continuation.resume() }
        }
    }

    @Test func `operations run one at a time in submission order`() async {
        let queue = AsyncOperationSerialQueue()
        let recorder = Recorder()

        // Earlier operations suspend longer, so they would finish last if they ran concurrently.
        for id in 0 ..< 10 {
            queue.enqueue { await recorder.run(id, yields: 10 - id) }
        }
        await drain(queue)

        #expect(recorder.completed == Array(0 ..< 10))
        #expect(!recorder.overlapped)
    }

    @Test func `operations enqueued from a cancelled task still run uncancelled`() async {
        let queue = AsyncOperationSerialQueue()
        let recorder = Recorder()
        var operationSawCancellation: Bool?

        let submitter = Task { @MainActor in
            try? await Task.sleep(for: .seconds(60))
            #expect(Task.isCancelled)
            queue.enqueue {
                operationSawCancellation = Task.isCancelled
                await recorder.run(1, yields: 1)
            }
        }
        submitter.cancel()
        await submitter.value
        await drain(queue)

        #expect(recorder.completed == [1])
        #expect(operationSawCancellation == false)
    }

    @Test func `concurrent enqueueing runs every operation exactly once without overlap`() async {
        let queue = AsyncOperationSerialQueue()
        let recorder = Recorder()

        await withTaskGroup(of: Void.self) { group in
            for id in 0 ..< 100 {
                group.addTask {
                    queue.enqueue { await recorder.run(id, yields: 2) }
                }
            }
        }
        await drain(queue)

        #expect(recorder.completed.sorted() == Array(0 ..< 100))
        #expect(!recorder.overlapped)
    }
}
