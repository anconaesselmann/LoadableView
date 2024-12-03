//  Created by Axel Ancona Esselmann on 10/12/23.
//

import Foundation

public enum ViewState<T> {
    case invalidated
    case notLoaded
    case loaded(T)
}

public extension ViewState {
    var loaded: T? {
        switch self {
        case .loaded(let loaded): return loaded
        case .notLoaded, .invalidated: return nil
        }
    }

    var hasLoaded: Bool {
        loaded != nil
    }

    var isInvalid: Bool {
        switch self {
        case .invalidated: return true
        case .loaded, .notLoaded: return false
        }
    }
}

public enum Overlay {
    case none
    case loading
    case error(Error)
}
