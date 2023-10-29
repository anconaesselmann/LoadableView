//  Created by Axel Ancona Esselmann on 10/13/23.
//

import SwiftUI
import LoadableView

final class ItemViewModel: IDedLoadableViewModel {

    var id: Item.ID

    @Published
    var viewState: ViewState<Item> = .notLoaded

    var overlayState: OverlayState = .none

    private let service: Service

    convenience init(id: Item.ID) {
        self.init(id: id, service: AppState.shared.service)
    }

    init(id: Item.ID, service: Service) {
        self.id = id
        self.service = service
    }

    func load() async throws -> Item {
        try await service.fetch(itemWithId: id)
    }

    func cancel() async {
        await service.cancel(itemWithId: id)
    }

    func willEnterForeground() {
        print("foregrounding", id.uuidString)
    }

    func didEnterBackground() {
        print("backgrounding", id.uuidString)
    }
}

extension ItemViewModel: ReloadsWhenForegrounding {

    var reloadTimerInterval: TimeInterval { 5 }
}
