//  Created by Axel Ancona Esselmann on 10/31/24.
//

import Foundation
import Combine

public enum ObservationType {
    case void, id(UUID)
}

public protocol LoadableViewObservable {
    associatedtype Change
        where Change: Hashable
    nonisolated func publisher(for observableChange: Set<Change>) -> AnyPublisher<ObservationType, Never>
}

public extension Publisher where Output == Void, Failure == Never {
    var viewModelObservable: AnyPublisher<ObservationType, Never> {
        map { .void }
            .eraseToAnyPublisher()
    }
}

public extension Publisher where Output == UUID, Failure == Never {
    func viewModelObservable(_ id: UUID) -> AnyPublisher<ObservationType, Never> {
        map { .id($0) }
            .eraseToAnyPublisher()
    }
}
