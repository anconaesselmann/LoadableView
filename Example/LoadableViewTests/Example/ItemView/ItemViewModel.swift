//  Created by Axel Ancona Esselmann on 10/13/23.
//

import SwiftUI
import LoadableView

final class ItemViewModel: IDedLoadableViewModel {

    var id: UUID?

    @Published
    var viewState: ViewState<Item> = .notLoaded

    var overlayState: OverlayState = .none

    private let service: ServiceProtocol

    convenience init() {
        self.init(service: AppState.shared.service)
    }

    init(service: ServiceProtocol) {
        self.service = service
    }

    func load(id: UUID) async throws -> Item {
        try await service.fetch(itemWithId: id)
    }

    func cancel(id: UUID) async {
        await service.cancel(itemWithId: id)
    }

    func willEnterForeground() {
        print("foregrounding", screenId.uuidString)
    }

    func didEnterBackground() {
        print("backgrounding", screenId.uuidString)
    }
}

extension ItemViewModel: ReloadsWhenForegrounding {
    var reloadTimerInterval: TimeInterval { 5 }
}
