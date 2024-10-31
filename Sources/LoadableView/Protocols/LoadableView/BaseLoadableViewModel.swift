//  Created by Axel Ancona Esselmann on 10/29/23.
//

import SwiftUI
import Combine

@MainActor
public protocol BaseLoadableViewModel: ObservableObject, AnyObject {
    associatedtype OverlayState = CurrentValueSubject<Overlay, Never>
    associatedtype Element

    // MARK: - Required implementation
    var viewState: ViewState<Element> { get set }
    var overlayState: CurrentValueSubject<Overlay, Never> { get }

    // MARK: - Don't implement
    func onAppear()
    func onDisappear()
    func setError(_ error: Error?)
    func setIsLoading(_ isLoading: Bool)

    // MARK: - Don't implement
    func refresh(showLoading: Bool)
    func refresh(on changePublisher: AnyPublisher<Void, Never>, showLoading: Bool) -> AnyCancellable

    // MARK: - Optional implementation
    func cancel() async

    func onLoadingChange(isLoading: Bool)
}

public extension BaseLoadableViewModel {

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
        Task {
            await cancel()
        }
    }

    func setError(_ error: Error?) {
        if let error = error, !error.isCancellation {
            overlayState.send(.error(error))
        } else {
            overlayState.send(.none)
        }
    }

    func setIsLoading(_ isLoading: Bool) {
        onLoadingChange(isLoading: isLoading)
        if isLoading {
            overlayState.send(.loading)
        } else {
            overlayState.send(.none)
        }
    }

    func update(with item: Element) {
        switch viewState {
        case .notLoaded:
            viewState = .loaded(item)
        case .loaded(let oldItem):
            if !equal(oldItem, item) {
                viewState = .loaded(item)
            }
        }
    }

    func update<ArrayElement>(with item: ArrayElement) where Element == Array<ArrayElement> {
        switch viewState {
        case .notLoaded:
            viewState = .loaded([item])
        case .loaded(let oldItem):
            let newItem = oldItem + [item]
            if !equal(oldItem, item) {
                viewState = .loaded(newItem)
            }
        }
    }

    @MainActor
    func setLoaded(_ newValue: Element) {
        viewState = .loaded(newValue)
    }

    func onLoadingChange(isLoading: Bool) {

    }
}
