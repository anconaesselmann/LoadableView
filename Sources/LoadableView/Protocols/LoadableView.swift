//  Created by Axel Ancona Esselmann on 10/12/23.
//

import SwiftUI

@MainActor
public protocol LoadableView: View {
    associatedtype T
        where T: Identifiable
    associatedtype NotLoadedView
        where NotLoadedView: View
    associatedtype Loaded
        where Loaded: View
    associatedtype Loading
        where Loading: View
    associatedtype ErrorView
        where ErrorView: View
    associatedtype VM
        where VM: LoadableViewModel, VM.T == T

    var _vm: StateObject<VM> { get set }

    var vm: VM { get }

    var id: T.ID { get set }

    init(id: T.ID, _vm: StateObject<VM>)

    @ViewBuilder
    func loaded(item: T) -> Loaded

    @ViewBuilder
    func loading() -> Loading

    @ViewBuilder
    func errorView(_ error: Error) -> ErrorView

    @ViewBuilder
    func notLoaded() -> NotLoadedView

    func onAppear()

    func onDisappear()
}

public extension LoadableView {
    init(id: T.ID) {
        let vm = VM(id)
        self.init(id: id, _vm: StateObject(wrappedValue: vm))
    }

    var vm: VM {
        _vm.wrappedValue
    }

    var viewStateAnimation: Animation? { .default }

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
                let item = try await vm.load(id: id)
                if let reloadsWhenForegrounding = vm as? (any ReloadsWhenForegrounding) {
                    reloadsWhenForegrounding.setLastLoaded()
                }
                vm.viewState = .loaded(item)
            } catch {
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
        }
        .refreshable {
            vm.refresh()
        }
    }

    func onAppear() { }

    func onDisappear() { }
}
