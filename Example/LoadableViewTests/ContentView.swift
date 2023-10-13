//  Created by Axel Ancona Esselmann on 10/11/23.
//

import SwiftUI
import DebugSwiftUI
import LoadableView

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

struct PreviewsResponse: Identifiable {
    let id: Route
    let previews: [ItemPreview]
}

@MainActor
final class ItemPreviewsViewModel: LoadableViewModel {
    let id: PreviewsResponse.ID

    var reloadTimerInterval: TimeInterval = 5

    @Published
    var viewState: ViewState<PreviewsResponse> = .loading

    private let service: Service

    convenience init(_ id: PreviewsResponse.ID) {
        self.init(id: id)
    }

    init(id: PreviewsResponse.ID, service: Service = AppState.shared.service) {
        self.id = id
        self.service = service
    }

    func load(id: PreviewsResponse.ID) async throws -> PreviewsResponse {
        try await service.fetchPreviews()
    }
}

struct ItemPreviewsView: DefaultLoadableView, Identifiable {

    var id: PreviewsResponse.ID

    var _vm: StateObject<ItemPreviewsViewModel>

    func loaded(item: PreviewsResponse) -> some View {
        List {
            ForEach(item.previews) { item in
                NavigationLink(item.text, value: item.id)
            }
        }
        .navigationDestination(for: UUID.self) { id in
            ShowAfterLoading(id: id)
        }
    }
}

struct ContentView: View {

    @State private var path: [UUID] = []

    var body: some View {
        NavigationStack(path: $path) {
            ItemPreviewsView(id: .itemPreviews)
        }
    }
}
