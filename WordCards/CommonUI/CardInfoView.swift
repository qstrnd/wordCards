// Copyright © 2024 Andrei (Andy) Iakovlev. See LICENSE file for details.

import SwiftUI

struct CardInfoView: View {
    var card: Card

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(card.translation)
                .font(.title2)
            Divider()
            Text(card.definition)
            Text(card.definitionTranslation)
            Divider()
            Text(card.sentence)
            Text(card.sentenceTranslation)
            Divider()
            HStack {
                Text(card.cerfLevel)
                Text("•")
                Text(card.grammaticalFeatures.partOfSpeech)
                Text("•")
                Text(card.domain)
            }
            .foregroundStyle(.secondary)
        }
    }
}

#Preview("Default") {
    List {
        CardInfoView(card: .mock1)
    }
}
