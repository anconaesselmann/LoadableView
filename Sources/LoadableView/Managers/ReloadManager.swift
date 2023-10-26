//  Created by Axel Ancona Esselmann on 10/13/23.
//

import Foundation

@MainActor
final internal class ReloadManager {
    static let shared = ReloadManager()

    var lastLoaded: [AnyHashable: Date] = [:]

    func setLastLoaded(for item: any ReloadsWhenForegrounding) {
        lastLoaded[AnyHashable(item.id)] = Date()
    }

    func durationSinceLastReload(for item: any ReloadsWhenForegrounding) -> TimeInterval {
        let lastLoaded = lastLoaded[AnyHashable(item.id)] ?? .now
        return abs(Date.now.timeIntervalSince(lastLoaded))
    }
}
