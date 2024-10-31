//  Created by Axel Ancona Esselmann on 10/31/24.
//

import Foundation
import Combine

public protocol LoadableViewObservable {
    associatedtype Change
        where Change: Hashable
    nonisolated func publisher(for observableChange: Set<Change>) -> AnyPublisher<(), Never>
}
