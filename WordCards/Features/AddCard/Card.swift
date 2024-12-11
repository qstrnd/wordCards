// Copyright © 2024 Andrei (Andy) Iakovlev. See LICENSE file for details.

import Foundation

struct Card: Equatable, Decodable {
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
        static let mock = Card(
            definition: "Etwas sicher aufbewahren oder schützen, um es vor Schaden oder Verlust zu bewahren.",
            definitionTranslation: "To keep something safe or protect it to prevent damage or loss.",
            translation: "Preserve",
            sentence: "Es ist wichtig, alte Dokumente gut zu **bewahren**.",
            sentenceTranslation: "It is important to **preserve** old documents well.",
            cerfLevel: "B1",
            grammaticalFeatures: .init(partOfSpeech: "Verb"),
            domain: "General"
        )
    }

#endif
