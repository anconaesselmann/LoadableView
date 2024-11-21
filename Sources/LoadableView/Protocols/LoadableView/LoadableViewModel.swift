//  Created by Axel Ancona Esselmann on 10/29/23.
//

import Foundation
import SwiftUI

@MainActor
public protocol LoadableViewModel: BaseLoadableViewModel {
    func load() async throws -> Element
}

public extension LoadableViewModel {
    func cancel() async {
        // Implement to cancel loading
    }

    func _cached(_ id: Any?) -> Element? {
        return nil
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
        catch {
            if !error.isCancellation {
                setError(error)
                return
            }
        }
        setIsLoading(false)
    }

    func refresh(showLoading: Bool) async {
        setIsLoading(showLoading)
        do {
            let item = try await load()
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
            }
            setIsLoading(false)
        }
        catch {
            setError(error)
        }
    }

    func refresh(showLoading: Bool) {
        Task { @MainActor in
            await refresh(showLoading: showLoading)
        }
    }

    func shouldRefresh(_ oldItem: Element?, newItem: Element) async -> Bool {
        return true
    }

    func shouldAnimate(_ oldItem: Element?, newItem: Element) async -> Bool {
        return true
    }

    func _refresh(ifID id: UUID, showLoading: Bool) {
        self.refresh(showLoading: showLoading)
    }
}
