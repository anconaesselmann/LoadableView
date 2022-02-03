//  Created by Axel Ancona Esselmann on 1/28/22.
//

import SwiftUI

public protocol LoadableView where
    LoadedView: View,
    LoadingView: View,
    ErrorView: View,
    ViewModel: LoadableViewModelProtocol,
    ErrorWithRetryView: View,
    ViewModel.Element == LoadedType
{
    associatedtype LoadedView
    associatedtype LoadingView
    associatedtype ErrorView
    associatedtype ErrorWithRetryView
    associatedtype LoadedType
    associatedtype ViewModel
    
    var viewModel: ViewModel { get }
    
    var loadingView: LoadingView { get }
    
    func errorView(_ error: UserFacingError) -> ErrorView
    func errorView(_ error: UserFacingError, retry: @escaping (() -> Void)) -> ErrorWithRetryView
    
    func loadedView(_ element: LoadedType) -> LoadedView
}

public extension LoadableView {
    func subscribe(viewModel: ViewModel, allowRetryOnError: Bool = true) -> some View {
        ZStack {
            switch viewModel.state {
            case .loading: loadingView
            case .error(let error): allowRetryOnError ? AnyView(errorView(error, retry: viewModel.retry)) : AnyView(errorView(error))
            case .success(let predictions): loadedView(predictions)
            }
        }
        .onAppear(perform: viewModel.didAppear)
        .onDisappear(perform: viewModel.didDisappear)
    }
}
