//  Created by Axel Ancona Esselmann on 10/13/23.
//

import Foundation
import LoremSwiftum
import LoadableView
import Combine

@globalActor
actor Service {

    enum ServiceError: Error {
        case randomError
        case itemDoesNotExist
    }

    private var items: [UUID: Item]
    private let listData: [ItemPreview]
    private var fetchCount: [UUID: Int] = [:]

    static let shared = Service()

    private var fetchItemTasks: [Item.ID: AnyCancellable] = [:]

    init() {
        items = (0..<10).map { _ in
            Item(id: UUID(), short: Lorem.title, text: Lorem.shortTweet)
        }.reduce(into: [UUID: Item]()) {
            $0[$1.id] = $1
        }
        listData = items.map {
            ItemPreview(id: $0.key, text: $0.value.short)
        }
    }

    func fetchPreviews() async throws -> ItemsViewData {
        try await Task.sleep(nanoseconds: UInt64.random(in: 1000000000..<2000000000))
        return ItemsViewData(id: .itemPreviews, previews: listData)
    }

    func fetch(itemWithId id: Item.ID) async throws -> Item {
        let task = Task {
            // Simulating a complex fetch hat can be checked for
            // cancellation at multiple points during execution
            try Task.checkCancellation()
            try await Task.sleep(nanoseconds: UInt64.random(in: 1000000000..<2000000000))
            try Task.checkCancellation()

            // When turned on fetching fails with a chance of 1 in 3
            if AppState.shared.debug.simulateFailures, Int.random(in: 0..<3) == 0 {
                throw ServiceError.randomError
            }

            try await Task.sleep(nanoseconds: UInt64.random(in: 1000000000..<2000000000))
            try Task.checkCancellation()

            guard let item = items[id] else {
                throw ServiceError.itemDoesNotExist
            }
            // Every 5 fetches the item's text has an update
            fetchCount[id] = (fetchCount[id] ?? 0) + 1
            if (fetchCount[id] ?? 0) > 5 {
                items[id] = Item(id:id, short: items[id]?.short ?? "NA", text: Lorem.shortTweet)
                fetchCount[id] = 0
            }
            try Task.checkCancellation()
            return item
        }
        fetchItemTasks[id] = task.eraseToAnyCancellable()
        return try await task.value
    }

    func cancel(itemWithId id: Item.ID) async {
        fetchItemTasks[id] = nil
    }
}
