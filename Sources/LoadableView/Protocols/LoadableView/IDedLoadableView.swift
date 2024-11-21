//  Created by Axel Ancona Esselmann on 10/29/23.
//

import SwiftUI

@MainActor
public protocol IDedLoadableView: BaseLoadableView
    where
        ViewModel: IDedLoadableViewModel,
        ViewModel.Element == Element,
        ViewModel.ID == ID
{
    associatedtype ID
        where
            ID: Hashable,
            ID: Equatable

    // MARK: - Required implementation
    var id: ID { get }
}

public extension IDedLoadableView {
    func initialLoadAction() async {
        do {
            try await vm.initialLoad(id: id)
        } catch {
            assertionFailure("\(error)")
        }
    }
}

public extension IDedLoadableView {
    @ViewBuilder
    var body: some View {
        _buildBody(id)
            .onChange(of: id) { oldValue, newValue in
                vm.idHasChanged(newValue, showLoading: true)
            }
    }
}
