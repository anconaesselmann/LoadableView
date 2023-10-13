//  Created by Axel Ancona Esselmann on 10/12/23.
//

import Foundation

public enum ViewState<T> {
    case loading
    case refreshing(T)
    case loaded(T)
    case error(Error)
    case errorWhenRefreshing(Error, T)
}
