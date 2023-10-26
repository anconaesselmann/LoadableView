//  Created by Axel Ancona Esselmann on 10/12/23.
//

import SwiftUI
import Combine

@MainActor
public protocol LoadableViewModel: ObservableObject, AnyObject {

    associatedtype OverlayState = CurrentValueSubject<Overlay, Never>

    associatedtype T
        where T: Identifiable

    var id: T.ID { get }

    var viewState: ViewState<T> { get set }
    var overlayState: CurrentValueSubject<Overlay, Never> { get }

    init(_ id: T.ID)

    func load(id: T.ID) async throws -> T

    func onAppear()
    func onDisappear()

    func setError(_ error: Error?)
    func setIsLoading(_ isLoading: Bool)
}

public extension LoadableViewModel {

    func refresh() async {
        setIsLoading(true)
        do {
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
        } catch {
            setError(error)
            return
        }
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
