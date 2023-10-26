//  Created by Axel Ancona Esselmann on 10/26/23.
//

import Foundation
import Combine

@MainActor
final internal class InternalErrorViewModel: ObservableObject {

    private let errorManager = ErrorManager.shared
    private var bag = Set<AnyCancellable>()
    private let contextId: UUID
    private let overlayState: CurrentValueSubject<Overlay, Never>

    @MainActor
    var error: Error? {
        didSet {
            objectWillChange.send()
        }
    }

    @MainActor
    init(_ overlayState: CurrentValueSubject<Overlay, Never>) {
        let contextId = UUID()
        self.contextId = contextId
        self.overlayState = overlayState
        error = errorManager.error(contextId)
        errorManager
            .errorState
            .filter { $0.id == contextId }
            .sink { @MainActor [weak self] state in
                self?.error = state.error
            }
            .store(in: &bag)

        overlayState.sink { @MainActor [weak self] overlay in
            switch overlay {
            case .none, .loading:
                self?.setError(nil)
            case .error(let error):
                self?.setError(error)
            }
        }
        .store(in: &bag)
    }

    private func setError(_ error: Error?) {
        if let error = error {
            self.errorManager.setError(contextId, error: error)
        } else {
            self.errorManager.setNoError(contextId)
        }
    }

    deinit {
        let contextId = self.contextId
        Task { @MainActor in
            ErrorManager.shared.setNoError(contextId)
        }
    }
}
