//  Created by Axel Ancona Esselmann on 10/29/23.
//

import SwiftUI

@MainActor
public protocol LoadableBaseView: View {
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
        where ViewModel: LoadableBaseViewModel, ViewModel.Element == Element

    // MARK: - Required
    var _vm: StateObject<ViewModel> { get set }
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
}

public extension LoadableBaseView {

    var vm: ViewModel {
        _vm.wrappedValue
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

    func onAppear() { }

    func onDisappear() { }
}
