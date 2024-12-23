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

    var cache: (any ViewDataCache<ID, Element>)? { get }
}

public extension IDedLoadableViewModel {

    func cancel(id: ID) async {
        // Implement to cancel loading
    }

    var cache: (any ViewDataCache<ID, Element>)? {
        return nil
    }

    func cancel() async {
        guard let id = self.id else {
            assertionFailure("No ID")
            return
        }
        await cancel(id: id)
    }

    @MainActor
    func idHasChanged(
        _ newId: ID,
        showLoading: Bool = false,
        showNotLoadedState: Bool = false
    ) {
        guard id != newId else {
            return
        }
        id = newId
        setIsLoading(showLoading)
        setError(nil)
        Task {
            await cancel()
        }
        if showNotLoadedState {
            viewState = .notLoaded
        }
        refresh(showLoading: showLoading)
    }

    func _cached(_ id: Any?) -> Element? {
        guard let id = self.id ?? id as? ID else {
            return nil
        }
        if let cache, let cached = cache.value(forKey: id) {
            return cached
        } else {
            return nil
        }
    }

    func initialLoad(id: ID) async throws {
        do {
            guard case .notLoaded = viewState else {
                return
            }
            if let cache, let cached = cache.value(forKey: id) {
                viewState = .loaded(cached)
            } else {
                setIsLoading(true)
            }
            self.id = id
            let item = try await load(id: id)
            cache?.insert(item, forKey: id)
            if let reloadsWhenForegrounding = self as? (any ReloadsWhenForegrounding) {
                reloadsWhenForegrounding.setLastLoaded()
            }
            viewState = .loaded(item)
        }
        catch {
            if !error.isCancellation {
                setError(error)
                return
            }
        }
        setIsLoading(false)
    }

    func refresh(showLoading: Bool) async throws {
        do {
            guard !viewState.isInvalid else {
                return
            }
            guard let id = self.id else {
                throw LoadableViewError.noId
            }
            let combinedShowLoading: Bool
            if let cache, cache.hasValue(forKey: id) {
                combinedShowLoading = showLoadingStateWhenCached()
            } else {
                combinedShowLoading = showLoading
            }
            setIsLoading(combinedShowLoading)
            let item = try await load(id: id)
            cache?.insert(item, forKey: id)
            guard await shouldRefresh(viewState.loaded, newItem: item) else {
                return
            }
            if let reloadsWhenForegrounding = self as? (any ReloadsWhenForegrounding) {
                reloadsWhenForegrounding.setLastLoaded()
            }
            switch viewState {
            case .notLoaded:
                viewState = .loaded(item)
            case .loaded(let oldItem):
                if !equal(oldItem, item) {
                    let shouldAnimate = await self.shouldAnimate(viewState.loaded, newItem: item)
                    withAnimation(shouldAnimate: shouldAnimate) {
                        viewState = .loaded(item)
                    }
                }
            case .invalidated: ()
            }
            setIsLoading(false)
        }
        catch {
            setError(error)
        }
    }

    func refresh(showLoading: Bool) {
        Task { @MainActor in
            do {
                try await refresh(showLoading: showLoading)
            } catch {
                assertionFailure("\(error)")
            }
        }
    }

    func shouldRefresh(_ oldItem: Element?, newItem: Element) async -> Bool {
        return true
    }

    func shouldAnimate(_ oldItem: Element?, newItem: Element) async -> Bool {
        return true
    }

    func invalidate() {
        viewState = .invalidated
    }

    func _refresh(ifID id: UUID, showLoading: Bool) {
        guard self.id == id as? Self.ID else {
            return
        }
        self.refresh(showLoading: showLoading)
    }
}
