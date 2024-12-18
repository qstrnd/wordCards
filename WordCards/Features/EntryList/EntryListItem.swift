// Copyright © 2024 Andrei (Andy) Iakovlev. See LICENSE file for details.

import Foundation

struct EntryListItem: Identifiable, Equatable, Hashable {
    let id: UUID
    let sourceText: String
    let translation: String
}
