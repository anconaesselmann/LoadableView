//  Created by Axel Ancona Esselmann on 10/12/23.
//

import SwiftUI

@MainActor
public protocol LoadableView: LoadableBaseView 
    where ViewModel: LoadableViewModel
{
    // MARK: - Initializers
    init(_vm: StateObject<ViewModel>)
}

public extension LoadableView {
    init() {
        let vm = ViewModel()
        self.init(_vm: StateObject(wrappedValue: vm))
    }
}
