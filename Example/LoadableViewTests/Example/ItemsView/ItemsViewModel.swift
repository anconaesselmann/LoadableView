//  Created by Axel Ancona Esselmann on 10/13/23.
//

import SwiftUI
import LoadableView

@MainActor
final class ItemsViewModel: LoadableViewModel, ReloadsWhenForegrounding {
    var id: ItemsViewData.ID

    var reloadTimerInterval: TimeInterval = 5

    @Published
    var viewState: ViewState<ItemsViewData> = .notLoaded

    var overlayState: OverlayState = .none

    private let service: Service

    convenience init(_ id: ItemsViewData.ID) {
        self.init(id: id)
    }

    init(id: ItemsViewData.ID, service: Service = AppState.shared.service) {
        self.id = id
        self.service = service
    }

    func load(id: ItemsViewData.ID) async throws -> ItemsViewData {
        try await service.fetchPreviews()
    }
}
