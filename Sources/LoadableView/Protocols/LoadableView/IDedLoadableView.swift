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
    var id: ID { get set }
}

public extension IDedLoadableView {

    @ViewBuilder
    var body: some View {
        ZStack {
            switch vm.viewState {
            case .notLoaded:
                notLoaded()
            case .loaded(let element):
                loaded(element)
            }
            InternalLoadingView(vm.overlayState) {
                loading()
            }
            InternalErrorView(vm.overlayState) {
                errorView($0)
            }
        }.task {
            do {
                try await vm.initialLoad(id: id)
            } catch {
                assertionFailure("\(error)")
            }
        }
        .onAppear {
            vm.onAppear()
            onAppear()
        }
        .onDisappear {
            vm.onDisappear()
            onDisappear()

        }
        .refreshable {
            vm.refresh()
        }
        .onChange(of: id) { oldValue, newValue in
            vm.idHasChanged(newValue, showLoading: true)
        }
    }
}
