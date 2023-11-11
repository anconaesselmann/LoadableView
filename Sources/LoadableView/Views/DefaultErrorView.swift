//  Created by Axel Ancona Esselmann on 10/26/23.
//

import SwiftUI

public struct DefaultErrorView: View {

    let error: Error

    @State 
    private var showingAlert = true

    public init(error: Error, refresh: @escaping () -> Void) {
        self.error = error
        self.refresh = refresh
    }

    var refresh: () -> Void

    public var body: some View {
        VStack {}
            .alert(isPresented: $showingAlert) {
                Alert(
                    title: Text("Error"),
                    message: Text(error.localizedDescription),
                    primaryButton:  .default(Text("Reload")) {
                        refresh()
                    },
                    secondaryButton: .cancel()
                )
            }
    }
}
