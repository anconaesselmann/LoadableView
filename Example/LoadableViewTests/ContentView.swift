//  Created by Axel Ancona Esselmann on 10/11/23.
//

import SwiftUI
import DebugSwiftUI
import LoadableView

struct ContentView: View {

    @State private var path: [UUID] = []

    var body: some View {
        DebugView(self)
        VStack {
            NavigationStack(path: $path) {
                ItemsView(id: .itemPreviews)
            }
        }
    }
}
