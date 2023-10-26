//  Created by Axel Ancona Esselmann on 10/26/23.
//

import SwiftUI
import Combine

internal struct InternalLoadingView<LoadingView>: View
    where LoadingView: View
{

    @StateObject
    private var viewModel: InternalLoadingViewModel

    private let overlayState: CurrentValueSubject<Overlay, Never>

    private var loadingView: () -> LoadingView

    internal init(
        _ overlayState: CurrentValueSubject<Overlay, Never>,
        loadingView: @escaping () -> LoadingView
    ) {
        self.overlayState = overlayState
        self.loadingView = loadingView
        let vm = InternalLoadingViewModel(overlayState)
        _viewModel = StateObject(wrappedValue: vm)
    }

    internal var body: some View {
        if viewModel.isLoading {
            loadingView()
        }
    }
}
