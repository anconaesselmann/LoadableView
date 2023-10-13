//  Created by Axel Ancona Esselmann on 10/12/23.
//

import SwiftUI

@MainActor
public protocol LoadableView: View {
    associatedtype T
        where T: Identifiable
    associatedtype Loaded
        where Loaded: View
    associatedtype Loading
        where Loading: View
    associatedtype ErrorView
        where ErrorView: View
    associatedtype ErrorWhenRefreshingView
        where ErrorWhenRefreshingView: View
    associatedtype RefreshingView
        where RefreshingView: View
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
    func errorWhenRefreshingView(_ old: T, error: Error) -> ErrorWhenRefreshingView

    @ViewBuilder
    func refreshing(_ old: T) -> RefreshingView

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
        Group {
            switch vm.viewState {
            case .loading:
                loading()
            case .loaded(let item):
                loaded(item: item)
            case .refreshing(let old):
                refreshing(old)
            case .error(let error):
                errorView(error)
            case .errorWhenRefreshing(let error, let old):
                errorWhenRefreshingView(old, error: error)
            }
        }.task {
            do {
                vm.viewState = .loading
                let item = try await vm.load(id: id)
                if let reloadsWhenForegrounding = vm as? (any ReloadsWhenForegrounding) {
                    reloadsWhenForegrounding.setLastLoaded()
                }
                vm.viewState = .loaded(item)
            } catch {
                vm.viewState = .error(error)
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
    }

    func onAppear() { }

    func onDisappear() { }
}

@MainActor
public protocol DefaultLoadableView: LoadableView { }

public extension DefaultLoadableView {

    @ViewBuilder
    func loading() -> some View {
        ProgressView()
    }

    @ViewBuilder
    func errorView(_ error: Error) -> some View {
        VStack {
            Text(error.localizedDescription)
            Button("retry") {
                vm.refresh()
            }
        }.padding()
    }

    @ViewBuilder
    func refreshing(_ old: T) -> some View {
        ZStack {
            loaded(item: old)
            Color.gray.opacity(0.2).ignoresSafeArea()
            ProgressView()
        }
    }

    @ViewBuilder
    func errorWhenRefreshingView(_ old: T, error: Error) -> some View {
        ZStack {
            loaded(item: old)
                .alert(
                    error.localizedDescription,
                    isPresented: Binding(get: { true }, set: { _ in }),
                    actions: {
                        Button("ok") {}
                    }
                )
        }
    }
}
