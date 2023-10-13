//  Created by Axel Ancona Esselmann on 10/12/23.
//

import SwiftUI
import DebugSwiftUI
import LoadableView

final class ShowAfterLoadingViewModel: LoadableViewModel, ReloadsWhenForegrounding {
    let id: Item.ID

    var reloadTimerInterval: TimeInterval = 5

    @Published
    var viewState: ViewState<Item> = .loading

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

struct ShowAfterLoading: DefaultLoadableView, Identifiable {

    var id: Item.ID

    var _vm: StateObject<ShowAfterLoadingViewModel>

    init(id: Item.ID, _vm: StateObject<ShowAfterLoadingViewModel>) {
        self.id = id
        self._vm = _vm
        SwiftUIDebugManager.shared.increment(initCountFor: self)
    }

    func loaded(item: Item) -> some View {
        VStack {
            HStack {
                Text(item.text)
                DebugView(self)
            }
            Button("refresh") {
                vm.refresh()
            }
        }.frame(maxWidth: .infinity)
    }
}
