//  Created by Axel Ancona Esselmann on 10/13/23.
//

import Foundation

@MainActor
public protocol ForegroundEnteringAware {
    associatedtype ID
        where ID: Hashable

    var id: ID { get }
    func willEnterForeground()
    func didEnterBackground()
}
