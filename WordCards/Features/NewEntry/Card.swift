// Copyright © 2024 Andrei (Andy) Iakovlev. See LICENSE file for details.

import Foundation

struct Card: Equatable, Decodable {
    let input: String?
    let definition: String
    let definitionTranslation: String
    let translation: String
    let sentence: String
    let sentenceTranslation: String
    let cerfLevel: String
    let grammaticalFeatures: GrammaticalFeatures
    let domain: String

    struct GrammaticalFeatures: Equatable, Decodable {
        let partOfSpeech: String
    }
}

#if DEBUG

extension Card {
    static let mock1 = Card(
        input: "Bewahren",
        definition: "Etwas sicher aufbewahren oder schützen, um es vor Schaden oder Verlust zu bewahren.",
        definitionTranslation: "To keep something safe or protect it to prevent damage or loss.",
        translation: "Preserve",
        sentence: "Es ist wichtig, alte Dokumente gut zu **bewahren**.",
        sentenceTranslation: "It is important to **preserve** old documents well.",
        cerfLevel: "B1",
        grammaticalFeatures: .init(partOfSpeech: "Verb"),
        domain: "General"
    )

    static let mock2 = Card(
        input: "Erwähnen",
        definition: "Etwas beiläufig oder kurz nennen oder darauf hinweisen.",
        definitionTranslation: "To mention something casually or briefly or to point it out.",
        translation: "To mention",
        sentence: "Er hat in seiner Rede den neuen Plan **erwähnt**.",
        sentenceTranslation: "He **mentioned** the new plan in his speech.",
        cerfLevel: "B1",
        grammaticalFeatures: .init(partOfSpeech: "verb"),
        domain: "Communication"
    )

    static let mock3 = Card(
        input: "Mensch",
        definition: "Ein Individuum der Spezies Homo sapiens, das sich durch Vernunft, Sprache und soziale Fähigkeiten auszeichnet.",
        definitionTranslation: "An individual of the species Homo sapiens, characterized by reason, language, and social skills.",
        translation: "Human",
        sentence: "Der **Mensch** ist ein soziales Wesen.",
        sentenceTranslation: "The **human** is a social being.",
        cerfLevel: "A1",
        grammaticalFeatures: .init(partOfSpeech: "Noun"),
        domain: "Anthropology"
    )
}

#endif
