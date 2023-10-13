//  Created by Axel Ancona Esselmann on 10/13/23.
//

import Foundation
import LoremSwiftum

@globalActor
actor Service {

    enum ServiceError: Error {
        case randomError
        case itemDoesNotExist
    }

    let items: [UUID: Item]
    let listData: [ItemPreview]

    static let shared = Service()

    init() {
        items = (0..<10).map { _ in
            Item(id: UUID(), text: Lorem.shortTweet)
        }.reduce(into: [UUID: Item]()) {
            $0[$1.id] = $1
        }
        listData = items.keys.map {
            ItemPreview(id: $0, text: Lorem.title)
        }
    }

    func fetchPreviews() async throws -> ItemsViewData {
        try await Task.sleep(nanoseconds: UInt64.random(in: 1000000000..<2000000000))
        return ItemsViewData(id: .itemPreviews, previews: listData)
    }

    func fetch(itemWithId id: Item.ID) async throws -> Item {
        try await Task.sleep(nanoseconds: UInt64.random(in: 1000000000..<2000000000))
        guard Int.random(in: 0..<5) != 0 else {
            throw ServiceError.randomError
        }
        guard let item = items[id] else {
            throw ServiceError.itemDoesNotExist
        }
        return item
    }
}
