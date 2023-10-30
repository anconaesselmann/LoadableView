//  Created by Axel Ancona Esselmann on 10/13/23.
//

import Foundation

@MainActor
public protocol ReloadsWhenForegrounding: ForegroundEnteringAware {
    var reloadTimerInterval: TimeInterval { get }

    func setLastLoaded()

    func foregroundReload()
}

public extension ReloadsWhenForegrounding where Self: BaseLoadableViewModel {

    var reloadTimerInterval: TimeInterval { 60 }

    func foregroundReload() {
        if ReloadManager.shared.durationSinceLastReload(for: self) > reloadTimerInterval {
            refresh()
        }
    }

    func setLastLoaded() {
        ReloadManager.shared.setLastLoaded(for: self)
    }

    func willEnterForeground() {

    }

    func didEnterBackground() {

    }
}
