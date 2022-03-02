//  Created by Axel Ancona Esselmann on 1/30/22.
//

import SwiftUI

open class BaseLoadableViewModel<Element>: ObservableObject {
    
    @Published private(set) public var state: ViewState<Element> = .loading
    public var statePublished: Published<ViewState<Element>> { _state }
    public var statePublisher: Published<ViewState<Element>>.Publisher { $state }
    
    public init(startState state: ViewState<Element>) {
        self.state = state
        
        if self is ForegroundEnteringAware {
            NotificationCenter.default.addObserver(self, selector: #selector(hasEnteredForeground(_:)), name: UIApplication.willEnterForegroundNotification, object: nil)
        }
        if self is BackgroundEnteringAware {
            NotificationCenter.default.addObserver(self, selector: #selector(didEnterBackgroundNotification(_:)), name: UIApplication.didEnterBackgroundNotification, object: nil)
        }
    }
    
    public func updateViewState(_ state: ViewState<Element>, withAnimation isAnimated: Bool = false) {
        DispatchQueue.main.async { [weak self] in
            if isAnimated {
                withAnimation {
                    self?.state = state
                }
            } else {
                self?.state = state
            }
        }
    }
    
    public func updateViewState(withAnimation isAnimated: Bool = false, with asyncBlock: @escaping () async throws -> Element) {
        Task {
            let state: Loadable<Element, UserFacingError>
            do {
                let element = try await asyncBlock()
                state = .success(element)
            } catch {
                state = .error(error.asUserFacing)
            }
            updateViewState(state, withAnimation: isAnimated)
        }
    }
    
    @objc func hasEnteredForeground(_ notification: Notification) {
        if let foregroundEnteringAware = self as? ForegroundEnteringAware {
            foregroundEnteringAware.willEnterForeground()
        }
    }
    
    @objc func didEnterBackgroundNotification(_ notification: Notification) {
        if let backgroundEnteringAware = self as? BackgroundEnteringAware {
            backgroundEnteringAware.didEnterBackground()
        }
    }
}
