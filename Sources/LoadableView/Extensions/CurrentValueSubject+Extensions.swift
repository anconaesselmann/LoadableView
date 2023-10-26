//  Created by Axel Ancona Esselmann on 10/26/23.
//

import Combine

public extension CurrentValueSubject where Output == Overlay, Failure == Never {
    static var none: Self {
        Self(.none)
    }
}
