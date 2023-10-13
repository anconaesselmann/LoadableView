//  Created by Axel Ancona Esselmann on 10/13/23.
//

import Foundation

enum Route: Identifiable {
    case itemPreviews

    var url: URL {
        switch self {
        case .itemPreviews: return URL(string: "https://www.anconaesselmann.com/item_previews")!
        }
    }

    var id: String {
        url.path()
    }
}
