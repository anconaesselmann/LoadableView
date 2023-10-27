//  Created by Axel Ancona Esselmann on 10/12/23.
//

import Foundation

struct Item: Identifiable, Equatable {
    let id: UUID
    let short: String
    let text: String
}
