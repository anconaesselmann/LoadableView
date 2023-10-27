//  Created by Axel Ancona Esselmann on 10/12/23.
//

import SwiftUI
import Combine

@MainActor
public protocol LoadableViewModel: ObservableObject, AnyObject {

    associatedtype OverlayState = CurrentValueSubject<Overlay, Never>

    associatedtype Element
        where Element: Identifiable

    // MARK: - Required implementation
    var id: Element.ID { get set }

    var viewState: ViewState<Element> { get set }
    var overlayState: CurrentValueSubject<Overlay, Never> { get }

    init(_ id: Element.ID)

    func load() async throws -> Element

    // MARK: - Optional implementation
    func cancel() async

    func onAppear()
    func onDisappear()

    func setError(_ error: Error?)
    func setIsLoading(_ isLoading: Bool)
}

public extension LoadableViewModel {

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
        catch is CancellationError {} // { print("cancelled") }
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
        catch is CancellationError {} // { print("cancelled") }
        catch {
            setError(error)
            return
        }
    }

    func cancel() async {
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
