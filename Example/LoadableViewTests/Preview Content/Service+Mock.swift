//  Created by Axel Ancona Esselmann on 10/29/23.
//

import Foundation

struct MockService: ServiceProtocol {

    static var item: Item = {
        Item(
            id: UUID(uuidString: "53ff7051-7d84-4989-ab41-7119525e3db0")!,
            short: "short",
            text: "text"
        )
    }()

    static var itemPreview: ItemPreview = {
        ItemPreview(id: Self.item.id, text: Self.item.text)
    }()

    func fetchPreviews() async throws -> [ItemPreview] {
        return [Self.itemPreview]
    }
    
    func fetch(itemWithId id: Item.ID) async throws -> Item {
        Self.item
    }
    
    func cancel(itemWithId id: Item.ID) async {

    }
}
