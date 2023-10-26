//  Created by Axel Ancona Esselmann on 10/26/23.
//

import Foundation
import Combine

@MainActor
final internal class ErrorManager: ObservableObject {

    internal struct ErrorState {
        let id: UUID
        let error: Error?

        static func noError(_ id: UUID) -> Self {
            return .init(id: id, error: nil)
        }

        static func error(_ id: UUID, error: Error) -> Self {
            return .init(id: id, error: error)
        }
    }

    @MainActor
    internal let errorState = PassthroughSubject<ErrorState, Never>()

    @MainActor
    internal static let shared = ErrorManager()

    @MainActor
    private var errors: [UUID: Error] = [:]

    @MainActor
    internal func setError(_ id: UUID, error: Error) {
        errors[id] = error
        errorState.send(.error(id, error: error))
    }

    @MainActor
    internal func setNoError(_ id: UUID) {
        errors[id] = nil
        errorState.send(.noError(id))
    }

    @MainActor
    internal func error(_ id: UUID) -> Error? {
        errors[id]
    }
}
