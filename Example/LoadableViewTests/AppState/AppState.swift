//  Created by Axel Ancona Esselmann on 10/13/23.
//

import Foundation

struct AppState {
    let service: Service

    // The only force-unwrapped property is the singleton.
    static var shared: AppState!
}
