// Copyright © 2024 Andrei (Andy) Iakovlev. See LICENSE file for details.

import Foundation
import SwiftData

@Model
final class StoredEntry: Equatable {
    @Attribute(.unique) var uuid: UUID
    var term: String
    var context: String?
    var definition: String
    var definitionTranslation: String
    var translation: String
    var sentence: String
    var sentenceTranslation: String
    var cerfLevel: String
    var domain: String
    var partOfSpeech: String
    var sourceType: SourceType
    var creationDate: Date
    var mostRecentUpdateDate: Date

    enum SourceType: String, Codable {
        case userGenerated
        case aiGenerated
        case curated
    }

    init(
        uuid: UUID,
        term: String,
        context: String? = nil,
        definition: String,
        definitionTranslation: String,
        translation: String,
        sentence: String,
        sentenceTranslation: String,
        cerfLevel: String,
        partOfSpeech: String,
        domain: String,
        sourceType: SourceType,
        creationDate: Date,
        mostRecentUpdateDate: Date
    ) {
        self.uuid = uuid
        self.term = term
        self.context = context
        self.definition = definition
        self.definitionTranslation = definitionTranslation
        self.translation = translation
        self.sentence = sentence
        self.sentenceTranslation = sentenceTranslation
        self.cerfLevel = cerfLevel
        self.partOfSpeech = partOfSpeech
        self.domain = domain
        self.sourceType = sourceType
        self.creationDate = creationDate
        self.mostRecentUpdateDate = mostRecentUpdateDate
    }
}

extension Notification.Name {
    static let didUpdateStoredEntries = Notification.Name("io.github.qstrnd.WordCards.didUpdateStoredEntries")
}
