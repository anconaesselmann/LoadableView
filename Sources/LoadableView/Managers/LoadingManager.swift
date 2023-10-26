//  Created by Axel Ancona Esselmann on 10/26/23.
//

import Foundation
import Combine

@MainActor
final internal class LoadingManager: ObservableObject {

    internal struct LoadingState {
        let id: UUID
        let isLoading: Bool
        
        static func isLoading(_ id: UUID) -> Self {
            return .init(id: id, isLoading: true)
        }
        
        static func notLoading(_ id: UUID) -> Self {
            return .init(id: id, isLoading: false)
        }
    }
    
    @MainActor
    internal let isLoading = PassthroughSubject<LoadingState, Never>()

    @MainActor
    internal static let shared = LoadingManager()

    @MainActor
    private var loading = Set<UUID>()
    
    @MainActor
    internal func setLoading(_ id: UUID) {
        loading.insert(id)
        isLoading.send(.isLoading(id))
    }
    
    @MainActor
    internal func setNotLoading(_ id: UUID) {
        loading.remove(id)
        isLoading.send(.notLoading(id))
    }
    
    @MainActor
    internal func isLoading(_ id: UUID) -> Bool {
        loading.contains(id)
    }
}
