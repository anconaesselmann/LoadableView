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
    func refresh()
}

public extension BaseLoadableViewModel {
    func cancel() async {
        // Implement to cancel loading
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
        Task {
            await cancel()
        }
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
