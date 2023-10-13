//  Created by Axel Ancona Esselmann on 10/12/23.
//

import SwiftUI

@MainActor
public protocol LoadableViewModel: ObservableObject, AnyObject {
    associatedtype T
        where T: Identifiable

    var id: T.ID { get }

    var viewState: ViewState<T> { get set }

    init(_ id: T.ID)

    func load(id: T.ID) async throws -> T

    func set(error: Error)

    func onAppear()

    func onDisappear()
}

public extension LoadableViewModel {
    func refresh() async {
        switch viewState {
        case .loaded(let old), .errorWhenRefreshing(_, let old), .refreshing(let old):
            viewState = .refreshing(old)
        default:
            viewState = .loading
        }
        do {
            let item = try await load(id: id)
            if let reloadsWhenForegrounding = self as? (any ReloadsWhenForegrounding) {
                reloadsWhenForegrounding.setLastLoaded()
            }
            viewState = .loaded(item)
        } catch {
            switch viewState {
            case .refreshing(let old), .errorWhenRefreshing(_, let old):
                viewState = .errorWhenRefreshing(error, old)
            default:
                viewState = .error(error)
            }
        }
    }

    func refresh() {
        Task { @MainActor in
            await refresh()
        }
    }

    func set(error: Error) {
        viewState = .error(error)
    }

    func onAppear() { 
        if let foregroundEnteringAware = self as? (any ForegroundEnteringAware) {
            ForegroundingDetector.shared.observe(foregroundEnteringAware)
        }
    }

    func onDisappear() { 
        if let foregroundEnteringAware = self as? (any ForegroundEnteringAware) {
            ForegroundingDetector.shared.stopObserving(foregroundEnteringAware)
        }
    }
}
