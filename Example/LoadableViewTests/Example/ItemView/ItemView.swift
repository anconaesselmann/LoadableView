//  Created by Axel Ancona Esselmann on 10/12/23.
//

import SwiftUI
import DebugSwiftUI
import LoadableView

struct ItemView: IDedDefaultLoadableView {

    var id: Item.ID
    
    @StateObject
    var vm = ItemViewModel()

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

#Preview {
    @StateObject var vm = ItemViewModel(service: MockService())
    return ItemView(id: MockService.item.id,vm: vm).frame(width: 150, height: 150)
}
