//  Created by Axel Ancona Esselmann on 10/29/23.
//

import Foundation

@MainActor
public protocol LoadableViewModel: BaseLoadableViewModel {
    func load() async throws -> Element
}

public extension LoadableViewModel {
    func cancel() async {
        // Implement to cancel loading
    }
    
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

    func refresh(showLoading: Bool) async {
        setIsLoading(showLoading)
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

    func refresh(showLoading: Bool) {
        Task { @MainActor in
            await refresh(showLoading: showLoading)
        }
    }
}
