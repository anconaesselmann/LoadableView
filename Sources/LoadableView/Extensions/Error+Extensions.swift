//  Created by Axel Ancona Esselmann on 7/9/24.
//

import Foundation

public extension Error {
    var isCancellation: Bool {
        switch self {
        case is CancellationError: return true
        default:
            let nsError = self as NSError
            if nsError.domain == NSURLErrorDomain, nsError.code == NSURLErrorCancelled {
                return true
            } else {
                return false
            }
        }
    }
}
