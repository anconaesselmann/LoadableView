//  Created by Axel Ancona Esselmann on 11/8/24.
//

import SwiftUI

public func withAnimation<Result>(
    _ animation: Animation? = .default,
    shouldAnimate: Bool,
    body: () throws -> Result
) rethrows -> Result {
    if shouldAnimate {
        try withAnimation(animation, body)
    } else {
        try body()
    }
}
