//  Created by Axel Ancona Esselmann on 10/13/23.
//

import SwiftUI

@MainActor
final internal class ForegroundingDetector {

    internal static let shared = ForegroundingDetector()

    private var observers: [AnyHashable: any ForegroundEnteringAware] = [:]

    internal func observe(_ observer: any ForegroundEnteringAware) {
        observers[AnyHashable(observer.id)] = observer
    }

    internal func stopObserving(_ observer: any ForegroundEnteringAware) {
        observers[AnyHashable(observer.id)] = nil
    }

    internal init() {
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

    @objc 
    internal func hasEnteredForeground(_ notification: Notification) {
        for (_, observer) in observers {
            observer.willEnterForeground()
            if let reloading = observer as? (any ReloadsWhenForegrounding) {
                reloading.foregroundReload()
            }
        }
    }

    @objc
    internal func didEnterBackgroundNotification(_ notification: Notification) {
        for (_, observer) in observers {
            observer.didEnterBackground()
        }
    }
}
