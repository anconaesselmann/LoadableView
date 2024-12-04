# LoadableView

LoadableViews reduces boilerplate when creating SwiftUI views that have loading/loaded/error states.

## Author

Axel Ancona Esselmann, axel@anconaesselmann.com

## License

LoadableView is available under the MIT license. See the LICENSE file for more info.

## Usage

```swift
import SwiftUI
import LoadableView

struct Book {
    let name: String
}

struct BooksView: DefaultLoadableView {
    @StateObject
    var vm = BooksViewModel()

    func loaded(_ viewData: [Book]) -> some View {
        VStack {

        }
    }
}

@MainActor
final class BooksViewModel: LoadableViewModel {

    @Published
    var viewState: ViewState<[Book]> = .notLoaded

    var overlayState: OverlayState = .none

    private let service = BookService()

    func load() async throws -> [Book] {
        try await service.fetchAll()
    }
}
```

For a none-trivial example app take a look at the example app [Books](https://github.com/anconaesselmann/Books), which demostrates the usage of LoadableView using the [OpenLibrary API](https://openlibrary.org/dev/docs/restful_api)
