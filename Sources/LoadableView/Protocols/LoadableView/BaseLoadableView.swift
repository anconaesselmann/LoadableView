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
}

public extension BaseLoadableView {
    func onAppear() { }

    func onDisappear() { }
}
