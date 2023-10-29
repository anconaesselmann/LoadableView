//  Created by Axel Ancona Esselmann on 10/29/23.
//

import SwiftUI
import Combine

@MainActor
public protocol IDedLoadableViewModel: LoadableBaseViewModel {
    associatedtype ID
        where
            ID: Hashable,
            ID: Equatable

    // MARK: - Required implementation
    var id: ID { get set }

    // MARK: - Initializers
    init(id: ID)
}

public extension IDedLoadableViewModel {
    func idHasChanged(
        _ newId: ID,
        showNotLoadedState: Bool = true
    ) {
        setIsLoading(false)
        setError(nil)
        Task {
            await cancel()
            await MainActor.run {
                if showNotLoadedState {
                    viewState = .notLoaded
                }
                id = newId
                refresh()
            }
        }
    }
}
