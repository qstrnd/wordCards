// Copyright © 2024 Andrei (Andy) Iakovlev. See LICENSE file for details.

import Foundation

struct EntryListItem: Identifiable, Equatable, Hashable {
    let id: UUID
    let sourceText: String
    let translation: String
}

#if DEBUG

extension EntryListItem {
    static let mock = [Card.mock1, Card.mock2, Card.mock3].enumerated().map {
        EntryListItem(
            id: UUID($0.offset),
            sourceText: $0.element.input ?? "",
            translation: $0.element.translation
        )
    }
}

#endif
