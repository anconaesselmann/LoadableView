//  Created by Axel Ancona Esselmann on 10/12/23.
//

import SwiftUI
import Combine

@MainActor
public protocol LoadableViewModel: ObservableObject, AnyObject {

    associatedtype OverlayState = CurrentValueSubject<Overlay, Never>

    associatedtype T
        where T: Identifiable

    // MARK: - Required implementation
    var id: T.ID { get set }

    var viewState: ViewState<T> { get set }
    var overlayState: CurrentValueSubject<Overlay, Never> { get }

    init(_ id: T.ID)

    func load(id: T.ID) async throws -> T

    // MARK: - Optional implementation
    func cancel(id: T.ID) async

    func onAppear()
    func onDisappear()

    func setError(_ error: Error?)
    func setIsLoading(_ isLoading: Bool)
}

public extension LoadableViewModel {

    func idHasChanged(oldId: T.ID, newId: T.ID, showNotLoadedState: Bool = true) {
        setIsLoading(false)
        setError(nil)
        Task {
            await cancel(id: oldId)
            await MainActor.run {
                if showNotLoadedState {
                    viewState = .notLoaded
                }
                id = newId
                refresh()
            }
        }
    }

    func refresh() async {
        setIsLoading(true)
        do {
            let id = self.id
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
        catch is CancellationError {} // { print("cancelled") }
        catch {
            setError(error)
            return
        }
    }

    func cancel(id: T.ID) async {
        // Implement to cancel loading
    }

    func refresh() {
        Task { @MainActor in
            await refresh()
        }
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
        setIsLoading(false)
    }

    func setError(_ error: Error?) {
        if let error = error {
            overlayState.send(.error(error))
        } else {
            overlayState.send(.none)
        }
    }

    func setIsLoading(_ isLoading: Bool) {
        if isLoading {
            overlayState.send(.loading)
        } else {
            overlayState.send(.none)
        }
    }
}
