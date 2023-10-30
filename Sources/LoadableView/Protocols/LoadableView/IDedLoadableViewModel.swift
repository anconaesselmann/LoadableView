//  Created by Axel Ancona Esselmann on 10/29/23.
//

import SwiftUI
import Combine

@MainActor
public protocol IDedLoadableViewModel: BaseLoadableViewModel {
    associatedtype ID
        where
            ID: Hashable,
            ID: Equatable

    // MARK: - Required implementation
    var id: ID? { get set }

    func load(id: ID) async throws -> Element

    // MARK: - Optional implementation
    func cancel(id: ID) async
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

    func initialLoad(id: ID) async throws {
        do {
            guard case .notLoaded = viewState else {
                return
            }
            setIsLoading(true)
            let item = try await load(id: id)
            if let reloadsWhenForegrounding = self as? (any ReloadsWhenForegrounding) {
                reloadsWhenForegrounding.setLastLoaded()
            }
            viewState = .loaded(item)
        }
        catch is CancellationError {}
        catch {
            setError(error)
            return
        }
        setIsLoading(false)
    }

    func refresh() async throws {
        setIsLoading(true)
        do {
            guard let id = self.id else {
                throw LoadableViewError.noId
            }
            let item = try await load(id: id)
            if let reloadsWhenForegrounding = self as? (any ReloadsWhenForegrounding) {
                reloadsWhenForegrounding.setLastLoaded()
            }
            switch viewState {
            case .notLoaded:
                viewState = .loaded(item)
            case .loaded(let oldItem):
                if !equal(oldItem, item) {
                    viewState = .loaded(item)
                }
            }
            setIsLoading(false)
        }
        catch is CancellationError {}
        catch {
            setError(error)
            return
        }
    }

    func refresh() {
        Task { @MainActor in
            do {
                try await refresh()
            } catch {
                assertionFailure("\(error)")
            }
        }
    }
}
