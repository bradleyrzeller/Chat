import XCTest
@testable import ExyteChat

final class UpdateQueueTests: XCTestCase {
    func testEnqueueRunsWorkInFIFOOrder() async {
        let queue = UpdateQueue()
        let values = LockedValues<Int>()

        await withTaskGroup(of: Void.self) { group in
            for value in 0..<50 {
                group.addTask {
                    await queue.enqueue {
                        await values.append(value)
                    }
                }
            }
        }

        let appendedValues = await values.values
        XCTAssertEqual(appendedValues, Array(0..<50))
    }
}

actor LockedValues<T: Sendable> {
    private(set) var values: [T] = []

    func append(_ value: T) {
        values.append(value)
    }
}
