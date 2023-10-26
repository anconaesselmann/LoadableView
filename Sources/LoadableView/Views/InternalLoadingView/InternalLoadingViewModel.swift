//  Created by Axel Ancona Esselmann on 10/26/23.
//

import Foundation
import Combine

@MainActor
final internal class InternalLoadingViewModel: ObservableObject {

    private let loadingManager = LoadingManager.shared
    private var bag = Set<AnyCancellable>()
    private let loadingId: UUID
    private let overlayState: CurrentValueSubject<Overlay, Never>

    @MainActor
    var isLoading: Bool {
        didSet {
            objectWillChange.send()
        }
    }

    @MainActor
    init(_ overlayState: CurrentValueSubject<Overlay, Never>) {
        let loadingId = UUID()
        self.loadingId = loadingId
        self.overlayState = overlayState
        isLoading = loadingManager.isLoading(loadingId)
        loadingManager
            .isLoading
            .filter { $0.id == loadingId }
            .sink { @MainActor [weak self] state in
                guard let self = self else {
                    return
                }
                self.isLoading = state.isLoading
            }
            .store(in: &bag)

        overlayState.sink { @MainActor [weak self] overlay in
            guard let self = self else {
                return
            }
            switch overlay {
            case .none, .error:
                self.loadingManager.setNotLoading(loadingId)
            case .loading:
                self.loadingManager.setLoading(loadingId)
            }
        }
        .store(in: &bag)
    }

    deinit {
        let loadingId = self.loadingId
        Task { @MainActor in
            LoadingManager.shared.setNotLoading(loadingId)
        }
    }
}
