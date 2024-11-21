//  Created by Axel Ancona Esselmann on 10/29/23.
//

import SwiftUI

@MainActor
public protocol BaseLoadableView: View {
    associatedtype Element
    associatedtype NotLoadedView
        where NotLoadedView: View
    associatedtype LoadedView
        where LoadedView: View
    associatedtype LoadingView
        where LoadingView: View
    associatedtype ErrorView
        where ErrorView: View
    associatedtype ViewModel
        where ViewModel: BaseLoadableViewModel, ViewModel.Element == Element

    // MARK: - Required
    var vm: ViewModel { get }

    // MARK: - View states
    @ViewBuilder
    func loaded(_ element: Element) -> LoadedView

    @ViewBuilder
    func loading() -> LoadingView

    @ViewBuilder
    func errorView(_ error: Error) -> ErrorView

    @ViewBuilder
    func notLoaded() -> NotLoadedView

    // MARK: Optional
    func onAppear()
    func onDisappear()

    // Note:
    //    Has default implementation. Must call respective initialLoad method
    //    on view model in custom implementation
    func initialLoadAction() async
}

public extension BaseLoadableView {
    func onAppear() { }

    func onDisappear() { }
}

internal extension BaseLoadableView {
    @ViewBuilder
    func _buildBody(_ id: Any? = nil) -> some View {
        ZStack {
            if !vm.viewState.hasLoaded, let cached = vm._cached(id) {
                loaded(cached)
            } else {
                switch vm.viewState {
                case .notLoaded:
                    notLoaded()
                case .loaded(let element):
                    loaded(element)
                }
            }
            InternalLoadingView(vm.overlayState) {
                loading()
            }
            InternalErrorView(vm.overlayState) {
                errorView($0)
            }
        }.task {
            await initialLoadAction()
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
