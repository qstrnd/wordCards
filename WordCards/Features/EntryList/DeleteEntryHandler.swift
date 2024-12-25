// Copyright © 2024 Andrei (Andy) Iakovlev. See LICENSE file for details.

import Combine
import Dependencies
import Foundation
import SwiftData

protocol DeleteEntryHandling: Sendable {
    func deleteEntry(id: UUID) async throws
}

@MainActor
final class DeleteEntryHandler: Sendable, DeleteEntryHandling {
    @Dependency(\.modelContainer) var modelContainer
    @Dependency(\.notificationCenter) var notificationCenter

    nonisolated init() {}

    func deleteEntry(id: UUID) async throws {
        try modelContainer.mainContext.delete(
            model: StoredEntry.self,
            where: #Predicate<StoredEntry> {
                $0.uuid == id
            }
        )

        try modelContainer.mainContext.save()

        notificationCenter.post(name: .didUpdateStoredEntries, object: nil)
    }
}

#if DEBUG
struct DeleteEntryHandlerMock: DeleteEntryHandling {
    func deleteEntry(id _: UUID) async throws {}
}
#endif

private enum DeleteEntryHandlerKey: DependencyKey {
    static let liveValue: any DeleteEntryHandling = DeleteEntryHandler()
    static let previewValue: any DeleteEntryHandling = DeleteEntryHandlerMock()
}

extension DependencyValues {
    var deleteEntryHandler: DeleteEntryHandling {
        get { self[DeleteEntryHandlerKey.self] }
        set { self[DeleteEntryHandlerKey.self] = newValue }
    }
}
