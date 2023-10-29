//  Created by Axel Ancona Esselmann on 10/13/23.
//

import Foundation

@MainActor
final internal class ReloadManager {
    internal static let shared = ReloadManager()

    private var lastLoaded: [AnyHashable: Date] = [:]

    internal func setLastLoaded(for item: any ReloadsWhenForegrounding) {
        lastLoaded[AnyHashable(item.id)] = Date()
    }

    internal func durationSinceLastReload(for item: any ReloadsWhenForegrounding) -> TimeInterval {
        let lastLoaded = lastLoaded[AnyHashable(item.id)] ?? .now
        return abs(Date.now.timeIntervalSince(lastLoaded))
    }
}
