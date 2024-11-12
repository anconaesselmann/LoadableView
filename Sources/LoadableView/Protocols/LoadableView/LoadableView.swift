//  Created by Axel Ancona Esselmann on 10/29/23.
//

import SwiftUI

@MainActor
public protocol LoadableView: BaseLoadableView 
    where ViewModel: LoadableViewModel
{
    // MARK: - Optional implementation
    func cancel() async
}

public extension LoadableView {
    func initialLoadAction() async {
        await vm.initialLoad()
    }
}

public extension LoadableView {

    func cancel() async {
        // Implement to cancel loading
    }

    @ViewBuilder
    var body: some View {
        _buildBody()
    }
}
