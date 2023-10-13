//  Created by Axel Ancona Esselmann on 10/13/23.
//

import Foundation

@MainActor
class AppLoader: ObservableObject {

    enum InitializationState {
        case error(Error)
        case loading
        case loaded(AppState)
    }

    var initializationState: InitializationState = .loading

    func initialize() async {
        guard AppState.shared == nil else {
            return
        }
        let service = Service()
        let appState = AppState(
            service: service
        )
        AppState.shared = appState
        initializationState = .loaded(appState)
        self.objectWillChange.send()
    }
}
