//  Created by Axel Ancona Esselmann on 12/3/24.
//

import Combine

public extension IDedLoadableViewModel {
    func invalidate<P: Publisher>(on publisher: P) -> AnyCancellable
        where P.Failure == Never, P.Output == ID
    {
        publisher
            .eraseToAnyPublisher()
            .filter { [weak self] observedId in
                guard let id = self?.id else {
                    return false
                }
                return observedId == id
            }
            .map { _ in return}
            .sink { [weak self] in
                self?.invalidate()
            }
    }
}

public extension BaseLoadableViewModel {
    func invalidate<P: Publisher>(on publisher: P) -> AnyCancellable
        where P.Failure == Never, P.Output == Void
    {
        publisher
            .eraseToAnyPublisher()
            .sink { [weak self] in
                self?.invalidate()
            }
    }
}
