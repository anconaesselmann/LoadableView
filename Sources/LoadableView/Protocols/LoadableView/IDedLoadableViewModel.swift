//  Created by Axel Ancona Esselmann on 10/29/23.
//

import SwiftUI
import Combine

@MainActor
public protocol IDedLoadableViewModel: LoadableBaseViewModel
    where Element: Identifiable
{
    // MARK: - Required implementation
    var id: Element.ID { get set }

    // MARK: - Initializers
    init(_ id: Element.ID)
}

public extension IDedLoadableViewModel {
    func idHasChanged(
        _ newId: Element.ID,
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
