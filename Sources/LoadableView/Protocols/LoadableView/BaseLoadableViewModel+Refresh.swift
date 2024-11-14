//  Created by Axel Ancona Esselmann on 10/31/24.
//

import Foundation
import Combine

public extension BaseLoadableViewModel {

    func refresh() {
        self.refresh(showLoading: false)
    }

    func refresh(with item: Element) {
        update(with: item)
        refresh()
    }

    func refresh(on changePublisher: AnyPublisher<ObservationType, Never>, showLoading: Bool) -> AnyCancellable {
        changePublisher.sink { [weak self] observationType in
            switch observationType {
            case .void:
                self?.refresh(showLoading: showLoading)
            case .id(let id):
                self?._refresh(ifID: id, showLoading: showLoading)
            }
        }
    }

    func refresh(on changePublisher: AnyPublisher<ObservationType, Never>) -> AnyCancellable {
        refresh(on: changePublisher, showLoading: false)
    }

    func refresh(on changePublishers: [AnyPublisher<ObservationType, Never>], showLoading: Bool = false) -> AnyCancellable {
        refresh(on: Publishers.MergeMany(changePublishers).eraseToAnyPublisher(), showLoading: showLoading)
    }

    func refresh(on changePublisher: AnyPublisher<ObservationType, Never>..., showLoading: Bool = false) -> AnyCancellable {
        refresh(on: changePublisher, showLoading: showLoading)
    }

    func observe<Observable>(
        _ change: Set<Observable.Change>,
        on observable: Observable,
        showLoading: Bool = false
    ) -> AnyCancellable
        where Observable: LoadableViewObservable
    {
        refresh(on: observable.publisher(for: change), showLoading: showLoading)
    }

    func observe<Observable>(
        _ change: Observable.Change...,
        on observable: Observable,
        showLoading: Bool = false
    ) -> AnyCancellable
        where Observable: LoadableViewObservable
    {
        observe(Set(change), on: observable, showLoading: showLoading)
    }
}
