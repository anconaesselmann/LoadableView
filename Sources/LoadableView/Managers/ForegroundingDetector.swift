//  Created by Axel Ancona Esselmann on 10/13/23.
//

import SwiftUI

@MainActor
final internal class ForegroundingDetector {

    static let shared = ForegroundingDetector()

    var observers: [AnyHashable: any ForegroundEnteringAware] = [:]

    func observe(_ observer: any ForegroundEnteringAware) {
        observers[AnyHashable(observer.id)] = observer
    }

    func stopObserving(_ observer: any ForegroundEnteringAware) {
        observers[AnyHashable(observer.id)] = nil
    }

    init() {
        #if os(macOS)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(hasEnteredForeground(_:)),
            name: NSApplication.willBecomeActiveNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didEnterBackgroundNotification(_:)),
            name: NSApplication.didResignActiveNotification,
            object: nil
        )
        #else
        NotificationCenter.default.addObserver(self, selector: #selector(hasEnteredForeground(_:)), name: UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didEnterBackgroundNotification(_:)), name: UIApplication.didEnterBackgroundNotification, object: nil)
        #endif
    }

    @objc func hasEnteredForeground(_ notification: Notification) {
        for (_, observer) in observers {
            observer.willEnterForeground()
            if let reloading = observer as? (any ReloadsWhenForegrounding) {
                reloading.foregroundReload()
            }
        }
    }

    @objc func didEnterBackgroundNotification(_ notification: Notification) {
        for (_, observer) in observers {
            observer.didEnterBackground()
        }
    }
}
