//  Created by Axel Ancona Esselmann on 1/28/22.
//

import Foundation

public protocol UserFacingError: Error {
    var errorString: String { get }
}

public enum DefaultUserFacingError: Error, UserFacingError {
    case unknown(Swift.Error)

    public var errorString: String {
        switch self {
        case .unknown: return "Unknown error"
        }
    }
}

public extension Swift.Error {
    var asUserFacing: UserFacingError {
        self as? UserFacingError ?? DefaultUserFacingError.unknown(self)
    }
}
