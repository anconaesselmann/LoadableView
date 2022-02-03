//  Created by Axel Ancona Esselmann on 2/3/22.
//

import LoadableView

struct MockNetworking {

    enum Error: UserFacingError {
        case mockError

        var errorString: String { "\(self)" }
    }

    func fetchWidgets() async throws -> Widget {
        try await Task.sleep(nanoseconds: 1_000_000_000)
        guard Bool.random() else {
            throw Error.mockError
        }
        return Widget(name: "Cats rule the world")
    }
}
