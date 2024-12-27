// Copyright © 2024 Andrei (Andy) Iakovlev. See LICENSE file for details.

import Combine
import Dependencies
import Foundation
import SwiftData

typealias EntryListStream = AsyncThrowingStream<[EntryListItem], Error>

protocol EntryListItemRepositoryProtocol: Sendable {
    func fetchEntryListItems() async -> EntryListStream
}

@MainActor
final class EntryListItemRepository: Sendable, EntryListItemRepositoryProtocol {
    @Dependency(\.modelContainer) var modelContainer
    @Dependency(\.notificationCenter) var notificationCenter

    private var cancellables = Set<AnyCancellable>()
    var (stream, continuation) = EntryListStream.makeStream()

    nonisolated init() {}

    func fetchEntryListItems() -> EntryListStream {
        defer {
            updateStreamWithRecentEntryItems()
        }

        if !cancellables.isEmpty {
            cancellables = []
            (stream, continuation) = EntryListStream.makeStream()
        }

        notificationCenter
            .publisher(for: .didUpdateStoredEntries)
            .sink { [weak self] _ in
                self?.updateStreamWithRecentEntryItems()
            }
            .store(in: &cancellables)

        return stream
    }

    private func updateStreamWithRecentEntryItems() {
        let fetchDescriptor = FetchDescriptor<StoredEntry>(
            sortBy: [
                SortDescriptor(\.creationDate, order: .reverse),
            ]
        )

        do {
            let entries = try modelContainer.mainContext.fetch(fetchDescriptor)

            let entryListItems = entries.map {
                EntryListItem(id: $0.uuid, sourceText: $0.term, translation: $0.translation)
            }

            continuation.yield(with: .success(entryListItems))
        } catch {
            continuation.yield(with: .failure(error))
        }
    }
}

#if DEBUG
struct EntryListItemRepositoryMock: EntryListItemRepositoryProtocol {
    var entryListItems: @Sendable () -> [EntryListItem]

    func fetchEntryListItems() -> EntryListStream {
        AsyncThrowingStream { continuation in
            continuation.yield(entryListItems())
            continuation.finish()
        }
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
