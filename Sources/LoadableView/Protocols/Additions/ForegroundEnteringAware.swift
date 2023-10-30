//  Created by Axel Ancona Esselmann on 10/13/23.
//

import Foundation

@MainActor
public protocol ForegroundEnteringAware {
    associatedtype ID
        where ID: Hashable

    var screenId: ID { get }
    func willEnterForeground()
    func didEnterBackground()
}

public extension IDedLoadableViewModel
    where
        Self: ForegroundEnteringAware,
        ID == UUID
{
    var screenId: UUID {
        id ?? UUID(uuidString: "670f315b-1abc-4948-bd28-b43eabddb726")!
    }
}
