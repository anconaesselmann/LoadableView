//  Created by Axel Ancona Esselmann on 10/12/23.
//

import SwiftUI
import DebugSwiftUI
import LoadableView

struct ItemView: DefaultLoadableView, Identifiable {

    var id: Item.ID

    var _vm: StateObject<ItemViewModel>

    init(id: Item.ID, _vm: StateObject<ItemViewModel>) {
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
