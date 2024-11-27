// Copyright © 2024 Andrei (Andy) Iakovlev. See LICENSE file for details.

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date

    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
