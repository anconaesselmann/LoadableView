//  Created by Axel Ancona Esselmann on 2/3/22.
//

import SwiftUI
import LoadableView

struct DefaultLoadingView: View {
    var body: some View {
        ProgressView()
    }
}

struct DefaultErrorView: View {
    let error: UserFacingError

    var body: some View {
        Text("Error: \(error.errorString)")
    }
}

struct DefaultErrorWithRetryView: View {
    let error: UserFacingError
    let retry: () -> Void

    var body: some View {
        VStack {
            Text("Error: \(error.errorString)").padding()
            Button("Retry") {
                retry()
            }.padding()
        }
    }
}
