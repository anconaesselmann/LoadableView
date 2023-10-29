//  Created by Axel Ancona Esselmann on 10/12/23.
//

import SwiftUI
import DebugSwiftUI
import LoadableView

struct ItemView: IDedDefaultLoadableView {

    var id: Item.ID
    var _vm: StateObject<ItemViewModel>

    func loaded(_ item: Item) -> some View {
        VStack {
            HStack {
                VStack {
                    Text(item.short)
                    Text(item.text)
                }
                DebugView(self)
            }
            Button("refresh") {
                vm.refresh()
            }
        }.frame(maxWidth: .infinity)
    }
}
