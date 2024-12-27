// Copyright © 2024 Andrei (Andy) Iakovlev. See LICENSE file for details.

import Dependencies
import Foundation

private enum NotificationCenterKey: DependencyKey {
    static let liveValue = NotificationCenter.default
}

extension DependencyValues {
    var notificationCenter: NotificationCenter {
        get { self[NotificationCenterKey.self] }
        set { self[NotificationCenterKey.self] = newValue }
    }
}
