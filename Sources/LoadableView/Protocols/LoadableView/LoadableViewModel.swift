//  Created by Axel Ancona Esselmann on 10/29/23.
//

import Foundation

@MainActor
public protocol LoadableViewModel: BaseLoadableViewModel {
    func load() async throws -> Element
    
    // MARK: - Optional implementation
    func cancel() async
}

public extension LoadableViewModel {
    func initialLoad() async {
        do {
            guard case .notLoaded = viewState else {
                return
            }
            setIsLoading(true)
            let item = try await load()
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

    func refresh() async {
        setIsLoading(true)
        do {
            let item = try await load()
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
            await refresh()
        }
    }
}
