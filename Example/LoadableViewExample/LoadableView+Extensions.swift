//  Created by Axel Ancona Esselmann on 2/3/22.
//

import SwiftUI
import LoadableView

extension LoadableView where LoadingView == DefaultLoadingView {
    var loadingView: DefaultLoadingView {
        DefaultLoadingView()
    }
}

extension LoadableView where ErrorView == DefaultErrorView {
    func errorView(_ error: UserFacingError) -> DefaultErrorView {
        DefaultErrorView(error: error)
    }
}

extension LoadableView where ErrorWithRetryView == DefaultErrorWithRetryView {
    func errorView(_ error: UserFacingError, retry: @escaping (() -> Void)) -> DefaultErrorWithRetryView {
        DefaultErrorWithRetryView(error: error, retry: retry)
    }
}
