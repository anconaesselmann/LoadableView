//  Created by Axel Ancona Esselmann on 10/26/23.
//

import Combine

public extension CurrentValueSubject where Output == Overlay, Failure == Never {
    static var none: Self {
        Self(.none)
    }

    func error(_ error: Error) {
        send(.error(error))
    }

    func none() {
        send(.none)
    }

    func loading() {
        send(.loading)
    }
}
