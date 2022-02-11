//  Created by Axel Ancona Esselmann on 2/2/22.
//

import SwiftUI

public protocol InvalidatesTimerOnDeinit {
    func invalidateTimer()
}

public protocol ReloadingViewModel: AnyObject, LoadableViewModelProtocol, InvalidatesTimerOnDeinit, ForegroundEnteringAware, BackgroundEnteringAware {
    var timer: Timer? { get set }
    
    var reloadTimerInterval: TimeInterval { get }
    
    func willEnterForeground()
    func didEnterBackground()
}

public extension ReloadingViewModel {
    func invalidateTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    func didAppear() {
        fetch()
        timer = Timer.scheduledTimer(withTimeInterval: reloadTimerInterval, repeats: true, block: { [weak self] timer in
            self?.refresh()
        })
    }
    
    func refresh() {
        fetch()
    }
    
    func didDisappear() {
        invalidateTimer()
    }
    
    func willEnterForeground() {
        updateViewState(.loading)
        didAppear()
    }
    
    func didEnterBackground() {
        invalidateTimer()
    }
}
