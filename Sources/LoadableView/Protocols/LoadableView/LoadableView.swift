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
    func cancel() async {
        // Implement to cancel loading
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
    }
}
