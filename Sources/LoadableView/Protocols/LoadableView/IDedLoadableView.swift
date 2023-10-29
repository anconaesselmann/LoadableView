//  Created by Axel Ancona Esselmann on 10/29/23.
//

import SwiftUI

@MainActor
public protocol IDedLoadableView: LoadableBaseView
    where
        Element: Identifiable,
        ViewModel: IDedLoadableViewModel,
        ViewModel.Element == Element
{
    // MARK: - Required implementation
    var id: Element.ID { get set }

    // MARK: - Initializers
    init(id: Element.ID, _vm: StateObject<ViewModel>)
}

public extension IDedLoadableView {
    init(id: Element.ID) {
        let vm = ViewModel(id)
        self.init(id: id, _vm: StateObject(wrappedValue: vm))
    }

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
            await vm.initialLoad()
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
        .onChange(of: id) { _, newValue in
            vm.idHasChanged(newValue)
        }
    }
}
