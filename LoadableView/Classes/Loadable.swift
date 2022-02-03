//  Created by Axel Ancona Esselmann on 1/28/22.
//

import Foundation

public enum Loadable<Element, Error> {
    case loading
    case success(Element)
    case error(Error)
}

public extension Loadable {
    var loaded: Element? {
        if case let .success(element) = self {
            return element
        } else {
            return nil
        }
    }
    
    var error: Error? {
        if case let .error(error) = self {
            return error
        } else {
            return nil
        }
    }
}
