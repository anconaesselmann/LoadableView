//  Created by Axel Ancona Esselmann on 11/20/24.
//

import Foundation

public protocol ViewDataCache<Key, Value> {
    associatedtype Key
        where Key: Hashable
    associatedtype Value

    func insert(_ value: Value, forKey key: Key)
    func value(forKey key: Key) -> Value?
}
