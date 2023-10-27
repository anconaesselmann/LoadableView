//  Created by Axel Ancona Esselmann on 10/12/23.
//

import SwiftUI

@MainActor
public protocol LoadableView: View {
    associatedtype Element
        where Element: Identifiable
    associatedtype NotLoadedView
        where NotLoadedView: View
    associatedtype LoadedView
        where LoadedView: View
    associatedtype LoadingView
        where LoadingView: View
    associatedtype ErrorView
        where ErrorView: View
    associatedtype ViewModel
        where ViewModel: LoadableViewModel, ViewModel.Element == Element

    var id: Element.ID { get set }

    var _vm: StateObject<ViewModel> { get set }
    var vm: ViewModel { get }

    // MARK: - Initializers
    init(id: Element.ID, _vm: StateObject<ViewModel>)

    // MARK: - View states
    @ViewBuilder
    func loaded(item: Element) -> LoadedView

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

public extension LoadableView {

    var vm: ViewModel {
        _vm.wrappedValue
    }

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
            case .loaded(let item):
                loaded(item: item)
            }
            InternalLoadingView(vm.overlayState) {
                loading()
            }
            InternalErrorView(vm.overlayState) {
                errorView($0)
            }
        }.task {
            do {
                guard case .notLoaded = vm.viewState else {
                    return
                }
                vm.setIsLoading(true)
                let id = self.id
                let item = try await vm.load(id: id)
                if let reloadsWhenForegrounding = vm as? (any ReloadsWhenForegrounding) {
                    reloadsWhenForegrounding.setLastLoaded()
                }
                vm.viewState = .loaded(item)
            } 
            catch is CancellationError {} // { print("cancelled") }
            catch {
                vm.setError(error)
                return
            }
            vm.setIsLoading(false)
        }
        .onAppear {
            vm.onAppear()
            onAppear()
        }
        .onDisappear {
            vm.onDisappear()
            onDisappear()
            Task {
                await vm.cancel(id: id)
            }
        }
        .refreshable {
            vm.refresh()
        }
        .onChange(of: id) { oldValue, newValue in
            vm.idHasChanged(oldId: oldValue, newId: newValue)
        }
    }

    func onAppear() { }

    func onDisappear() { }
}
