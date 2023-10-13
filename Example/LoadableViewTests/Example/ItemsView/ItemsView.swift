//  Created by Axel Ancona Esselmann on 10/13/23.
//

import SwiftUI
import DebugSwiftUI
import LoadableView

struct ItemsView: DefaultLoadableView {

    var id: ItemsViewData.ID

    var _vm: StateObject<ItemsViewModel>

    func loaded(item: ItemsViewData) -> some View {
        List {
            ForEach(item.previews) { item in
                NavigationLink(item.text, value: item.id)
            }
        }
        .navigationDestination(for: UUID.self) { id in
            ItemView(id: id)
        }
    }
}
