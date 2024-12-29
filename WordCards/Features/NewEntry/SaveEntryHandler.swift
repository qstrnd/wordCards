// Copyright © 2024 Andrei (Andy) Iakovlev. See LICENSE file for details.

import Dependencies
import Foundation

protocol SaveEntryHandling: Sendable {
    func save(card: Card, for input: String, withID id: UUID, date: Date) async throws
}

@MainActor
struct SaveEntryHandler: SaveEntryHandling {
    @Dependency(\.modelContainer) var modelContainer
    @Dependency(\.notificationCenter) var notificationCenter

    func save(card: Card, for input: String, withID id: UUID, date: Date) async throws {
        let entry = StoredEntry(
            uuid: id,
            term: input,
            definition: card.definition,
            definitionTranslation: card.definitionTranslation,
            translation: card.translation,
            sentence: card.sentence,
            sentenceTranslation: card.sentenceTranslation,
            cerfLevel: card.cerfLevel,
            partOfSpeech: card.grammaticalFeatures.partOfSpeech,
            domain: card.domain,
            sourceType: .aiGenerated,
            creationDate: date,
            mostRecentUpdateDate: date
        )

        modelContainer.mainContext.insert(entry)
        try modelContainer.mainContext.save()
        notificationCenter.post(name: .didUpdateStoredEntries, object: nil)
    }
}

private enum SaveEntryHandlerKey: DependencyKey {
    static let liveValue: any SaveEntryHandling = SaveEntryHandler()
}

extension DependencyValues {
    var saveEntryHandler: SaveEntryHandling {
        get { self[SaveEntryHandlerKey.self] }
        set { self[SaveEntryHandlerKey.self] = newValue }
    }
}
