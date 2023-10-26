//  Created by Axel Ancona Esselmann on 10/26/23.
//

import Foundation

public func equal(_ a0: Any, _ a1: Any) -> Bool {
    guard
        let e0 = a0 as? any Equatable,
        let e1 = a1 as? any Equatable
    else {
        return false
    }
    return e0.isEqual(e1)
}

internal extension Equatable {
    func isEqual(_ other: any Equatable) -> Bool {
        if let other = other as? Self {
            return self == other
        } else {
            return false
        }
    }
}
