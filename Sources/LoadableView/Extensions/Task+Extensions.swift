//  Created by Axel Ancona Esselmann on 10/26/23.
//

import Combine

public extension Task {
  func eraseToAnyCancellable() -> AnyCancellable {
        AnyCancellable(cancel)
    }
}
