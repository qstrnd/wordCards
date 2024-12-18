// Copyright © 2024 Andrei (Andy) Iakovlev. See LICENSE file for details.

import Dependencies
import Foundation
import SwiftData

@MainActor
protocol EntryListItemRepositoryProtocol: Sendable {
    func fetchEntryListItems() async throws -> [EntryListItem]
}

@MainActor
struct EntryListItemRepository: EntryListItemRepositoryProtocol {
    @Dependency(\.modelContainer) var modelContainer

    func fetchEntryListItems() async throws -> [EntryListItem] {
        let fetchDescriptor = FetchDescriptor<StoredEntry>(
            sortBy: [
                SortDescriptor(\.creationDate, order: .reverse),
            ]
        )

        let entries = try modelContainer.mainContext.fetch(fetchDescriptor, batchSize: 40)

        return entries.map {
            EntryListItem(id: $0.uuid, sourceText: $0.term, translation: $0.translation)
        }
    }
}

#if DEBUG
struct EntryListItemRepositoryMock: EntryListItemRepositoryProtocol {
    var fetchEntryListItems: @Sendable () async throws -> [EntryListItem]

    func fetchEntryListItems() async throws -> [EntryListItem] {
        try await fetchEntryListItems()
    }
}
#endif

private enum EntryListItemRepositoryKey: DependencyKey {
    static let liveValue: any EntryListItemRepositoryProtocol = EntryListItemRepository()
}

extension DependencyValues {
    var entryListItemRepository: EntryListItemRepositoryProtocol {
        get { self[EntryListItemRepositoryKey.self] }
        set { self[EntryListItemRepositoryKey.self] = newValue }
    }
}
