//  Created by Axel Ancona Esselmann on 10/11/23.
//

import SwiftUI
import DebugSwiftUI

@main
struct LoadableViewTestsApp: App {

    @StateObject
    var appLoader = AppLoader()

    init() {
        SwiftUIDebugManager.shared.isDebugging = true
    }

    var body: some Scene {
        WindowGroup {
            switch appLoader.initializationState {
            case .loading:
                ProgressView()
                    .task {
                        await appLoader.initialize()
                    }
            case .error(let error):
                Text("Error: \(error.localizedDescription)")
            case .loaded(_):
                ContentView()
            }
        }
    }
}
