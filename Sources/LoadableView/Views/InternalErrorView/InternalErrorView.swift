//  Created by Axel Ancona Esselmann on 10/26/23.
//

import SwiftUI
import Combine

internal struct InternalErrorView<ErrorView>: View
    where ErrorView: View
{

    @StateObject
    private var viewModel: InternalErrorViewModel

    private let overlayState: CurrentValueSubject<Overlay, Never>

    private var errorView: (Error) -> ErrorView

    internal init(
        _ overlayState: CurrentValueSubject<Overlay, Never>,
        errorView: @escaping (Error) -> ErrorView
    ) {
        self.overlayState = overlayState
        self.errorView = errorView
        let vm = InternalErrorViewModel(overlayState)
        _viewModel = StateObject(wrappedValue: vm)
    }

    internal var body: some View {
        if let error = viewModel.error {
            errorView(error)
        }
    }
}
