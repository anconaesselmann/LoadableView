# LoadableView

`LoadableView` reduces boilerplate when creating SwiftUI views that have loading/loaded/error states.

## Author

Axel Ancona Esselmann, axel@anconaesselmann.com

## License

LoadableView is available under the MIT license. See the LICENSE file for more info.

## Usage

For a none-trivial example take a look at the example app [Books](https://github.com/anconaesselmann/Books), which demostrates the usage of LoadableView using the [OpenLibrary API](https://openlibrary.org/dev/docs/restful_api)


`LoadableView` is great for fetching lists of things:

```swift
import SwiftUI
import LoadableView

struct Book {
    let name: String
}

struct BooksView: DefaultLoadableView {
    @StateObject
    var vm = BooksViewModel()

    func loaded(_ books: [Book]) -> some View {
        List {
            ForEach(books) { book in
                Text(book.name)
            }
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

Resources that have an ID use `IDedLoadableView`:

```swift
import SwiftUI
import LoadableView

struct BookView: IDedDefaultLoadableView {

    var id: UUID

    @StateObject
    var vm = BookViewModel()

    func loaded(_ book: Book) -> some View {
        VStack {
            Text(book.name)
        }
    }
}

@MainActor
final class BookViewModel: IDedLoadableViewModel {

    var id: UUID?

    @Published
    var viewState: ViewState<Book> = .notLoaded

    var overlayState: OverlayState = .none

    private let service = BookService()

    func load(id: UUID) async throws -> Book {
        try await service.fetchBook(withId: id)
    }
}
```
