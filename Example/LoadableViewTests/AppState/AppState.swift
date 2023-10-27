//  Created by Axel Ancona Esselmann on 10/13/23.
//

import Foundation

struct AppState {
    struct Debug {
        var simulateFailures: Bool = false
    }
    let service: Service
    var debug = Debug()

    static var shared: AppState!
}
