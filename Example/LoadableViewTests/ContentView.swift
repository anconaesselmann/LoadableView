//  Created by Axel Ancona Esselmann on 10/11/23.
//

import SwiftUI
import DebugSwiftUI
import LoadableView

struct ContentView: View {

    @State 
    private var path: [UUID] = []

    @State
    private var useNavStack = false

    var body: some View {
        VStack {
            DebugView(self)
            if useNavStack {
                VStack {
                    NavigationStack(path: $path) {
                        ItemsView(id: .itemPreviews)
                    }
                }
            } else {
                NavigationSplitView {
                    ItemsView(id: .itemPreviews)
                } detail: {
                    if let detailId = path.first {
                        ItemView(id: detailId)
                    }
                }
            }
        }.toolbar {
            HStack {
                Text("Simulate failures")
                Toggle(isOn: Binding(
                    get: {
                        AppState.shared.debug.simulateFailures
                    },
                    set: {
                        AppState.shared.debug.simulateFailures = $0
                    }
                )) { }
                .toggleStyle(.switch)
            }
            HStack {
                Text("Use NavigationStack")
                Toggle(isOn: $useNavStack) { }
                    .toggleStyle(.switch)
            }
        }
    }
}
