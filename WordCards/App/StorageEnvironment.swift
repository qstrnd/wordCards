// Copyright © 2024 Andrei (Andy) Iakovlev. See LICENSE file for details.

import Dependencies
import Foundation
import SwiftData

enum ModelContainerKey: DependencyKey {
    static let sharedModelContainer = {
        let schema = Schema([
            StoredEntry.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    static let liveValue = Self.sharedModelContainer
}

extension DependencyValues {
    var modelContainer: ModelContainer {
        get { self[ModelContainerKey.self] }
        set { self[ModelContainerKey.self] = newValue }
    }
}
