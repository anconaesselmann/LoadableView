//  Created by Axel Ancona Esselmann on 2/3/22.
//

import SwiftUI
import LoadableView

struct ExampleView: View, LoadableView {

    @StateObject var viewModel = RoutesViewModel()

    var body: some View {
        subscribe(viewModel: viewModel)
    }

    func loadedView(_ widget: Widget) -> some View {
        VStack {
            Text(widget.name).padding()
            Button("again!") {
                viewModel.retry()
            }
        }
    }
}

class RoutesViewModel: BaseLoadableViewModel<Widget>, LoadableViewModelProtocol {

    let service: MockNetworking

    init(
        service: MockNetworking = MockNetworking(),
        startState: ViewState<Element> = .loading
    ) {
        self.service = service
        super.init(startState: startState)
    }

    func fetch() {
        updateViewState {
            try await self.service.fetchWidgets()
        }
    }
}
