//  Created by Axel Ancona Esselmann on 10/12/23.
//

import Foundation

public enum ViewState<T> {
    case notLoaded
    case loaded(T)
}

public enum Overlay {
    case none
    case loading
    case error(Error)
}
