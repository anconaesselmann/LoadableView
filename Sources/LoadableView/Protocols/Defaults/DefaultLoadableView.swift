//  Created by Axel Ancona Esselmann on 10/26/23.
//

import SwiftUI

@MainActor
public protocol DefaultLoadableView: LoadableView { }

public extension DefaultLoadableView {

    @ViewBuilder
    func notLoaded() -> some View {
        EmptyView()
    }

    @ViewBuilder
    func loading() -> some View {
        ProgressView()
    }

    @ViewBuilder
    func errorView(_ error: Error) -> some View {
        DefaultErrorView(error: error) {
            vm.refresh()
        }
    }
}
