//  Created by Axel Ancona Esselmann on 10/13/23.
//

import SwiftUI
import LoadableView

@MainActor
final class ItemsViewModel: LoadableViewModel {

    @Published
    var viewState: ViewState<[ItemPreview]> = .notLoaded

    var overlayState: OverlayState = .none

    private let service: Service

    convenience init() {
        self.init(service: AppState.shared.service)
    }

    init(service: Service) {
        self.service = service
    }

    func load() async throws -> [ItemPreview] {
        try await service.fetchPreviews()
    }
}

extension ItemsViewModel: ReloadsWhenForegrounding {
    var id: UUID { ScreenIDs.items }

    var reloadTimerInterval: TimeInterval { 5 }
}
