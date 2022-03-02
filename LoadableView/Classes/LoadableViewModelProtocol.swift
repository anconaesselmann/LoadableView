//  Created by Axel Ancona Esselmann on 1/30/22.
//

import SwiftUI

public typealias ViewState<Element> = Loadable<Element, UserFacingError>

public protocol LoadableViewModelProtocol {
    associatedtype Element

    var state: ViewState<Element> { get }
    var statePublished: Published<ViewState<Element>> { get }
    var statePublisher: Published<ViewState<Element>>.Publisher { get }

    func updateViewState(_ state: ViewState<Element>, withAnimation isAnimated: Bool)
    
    func retry()
    func fetch()
    
    func didAppear()
    func didDisappear()
}

public extension LoadableViewModelProtocol {
    func didAppear() {
        fetch()
    }
    
    func didDisappear() {
        if let invalidating = self as? InvalidatesTimerOnDeinit {
            invalidating.invalidateTimer()
        }
    }
    
    func retry() {
        updateViewState(.loading, withAnimation: false)
        fetch()
    }
}

public protocol ForegroundEnteringAware {
    func willEnterForeground()
}

public protocol BackgroundEnteringAware {
    func didEnterBackground()
}
