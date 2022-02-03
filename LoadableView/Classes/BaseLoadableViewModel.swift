//  Created by Axel Ancona Esselmann on 1/30/22.
//

import SwiftUI

open class BaseLoadableViewModel<Element>: ObservableObject {
    
    @Published private(set) public var state: ViewState<Element> = .loading
    public var statePublished: Published<ViewState<Element>> { _state }
    public var statePublisher: Published<ViewState<Element>>.Publisher { $state }
    
    public init(startState state: ViewState<Element>) {
        self.state = state
    }
    
    public func updateViewState(_ state: ViewState<Element>) {
        DispatchQueue.main.async { [weak self] in
            self?.state = state
        }
    }
    
    public func updateViewState(with asyncBlock: @escaping () async throws -> Element) {
        Task {
            let state: Loadable<Element, UserFacingError>
            do {
                let element = try await asyncBlock()
                state = .success(element)
            } catch {
                state = .error(error.asUserFacing)
            }
            DispatchQueue.main.async { [weak self] in
                self?.state = state
            }
        }
    }
}
