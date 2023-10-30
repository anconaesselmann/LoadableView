//  Created by Axel Ancona Esselmann on 10/13/23.
//

import SwiftUI
import DebugSwiftUI
import LoadableView

struct ItemsView: DefaultLoadableView {

    @StateObject
    var vm = ItemsViewModel()

    func loaded(_ previews: [ItemPreview]) -> some View {
        VStack {
            DebugView(self)
            List {
                ForEach(previews) { preview in
                    NavigationLink(preview.text, value: preview.id)
                }
            }
            .navigationDestination(for: UUID.self) { id in
                ItemView(id: id)
            }
        }
    }
}

#Preview {
    @StateObject var vm = ItemsViewModel(service: MockService())
    return ItemsView(vm: vm).frame(width: 150, height: 150)
}
