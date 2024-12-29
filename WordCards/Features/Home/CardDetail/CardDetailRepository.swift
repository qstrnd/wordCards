// Copyright © 2024 Andrei (Andy) Iakovlev. See LICENSE file for details.

import Dependencies
import Foundation
import SwiftData

enum CardDetailRepositoryError: Error {
    case noCardWithGivenID
}

protocol CardDetailRepositoryProtocol: Sendable {
    func fetchCardDetail(for id: UUID) async throws -> Card
}

@MainActor
final class CardDetailRepository: CardDetailRepositoryProtocol {
    @Dependency(\.modelContainer) var modelContainer

    func fetchCardDetail(for id: UUID) async throws -> Card {
        let fetchDescriptor = FetchDescriptor<StoredEntry>(
            predicate: #Predicate {
                $0.uuid == id
            }
        )

        guard let storedEntry = try modelContainer.mainContext.fetch(fetchDescriptor).first else {
            throw CardDetailRepositoryError.noCardWithGivenID
        }

        return Card(
            input: storedEntry.term,
            definition: storedEntry.definition,
            definitionTranslation: storedEntry.definitionTranslation,
            translation: storedEntry.translation,
            sentence: storedEntry.sentence,
            sentenceTranslation: storedEntry.sentenceTranslation,
            cerfLevel: storedEntry.cerfLevel,
            grammaticalFeatures: .init(partOfSpeech: storedEntry.partOfSpeech),
            domain: storedEntry.domain
        )
    }
}

#if DEBUG
struct CardDetailRepositoryMock: CardDetailRepositoryProtocol {
    var fetchCardDetail: @Sendable (UUID) async throws -> Card

    func fetchCardDetail(for id: UUID) async throws -> Card {
        try await fetchCardDetail(id)
    }
}
#endif

private enum CardDetailRepositoryKey: DependencyKey {
    static let liveValue: any CardDetailRepositoryProtocol = CardDetailRepository()
}

extension DependencyValues {
    var cardDetailRepository: CardDetailRepositoryProtocol {
        get { self[CardDetailRepositoryKey.self] }
        set { self[CardDetailRepositoryKey.self] = newValue }
    }
}
