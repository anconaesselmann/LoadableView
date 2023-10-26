//  Created by Axel Ancona Esselmann on 10/13/23.
//

import SwiftUI
import LoadableView

final class ItemViewModel: LoadableViewModel, ReloadsWhenForegrounding {
    let id: Item.ID

    var reloadTimerInterval: TimeInterval = 5

    @Published
    var viewState: ViewState<Item> = .notLoaded

    var overlayState: OverlayState = .none

    private let service: Service

    convenience init(_ id: Item.ID) {
        self.init(id: id)
    }

    init(id: Item.ID, service: Service = AppState.shared.service) {
        self.id = id
        self.service = service
    }

    func load(id: Item.ID) async throws -> Item {
        try await service.fetch(itemWithId: id)
    }

    func willEnterForeground() {
        print("foregrounding", id.uuidString)
    }

    func didEnterBackground() {
        print("backgrounding", id.uuidString)
    }
}
