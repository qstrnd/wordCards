// Copyright © 2024 Andrei (Andy) Iakovlev. See LICENSE file for details.

import ComposableArchitecture
import SwiftUI

struct AddCardView: View {
    @Bindable var store: StoreOf<AddCardFeature>

    var body: some View {
        ZStack {
            Form {
                Section {
                    TextField("Input", text: $store.input.sending(\.setInput))

                    Button("Load") {
                        store.send(.loadButtonTapped)
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(!store.isLoadButtonEnabled)
                }

                Section {
                    switch store.card {
                    case .empty, .isLoading:
                        EmptyView()
                    case let .loaded(card):
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
            }

            switch store.card {
            case .isLoading:
                ProgressView()
            default:
                EmptyView()
            }
        }
    }
}

#Preview("Loaded") {
    AddCardView(
        store: Store(
            initialState: AddCardFeature.State(
                input: "Bewahren",
                card: .loaded(.mock)
            ),
            reducer: {}
        )
    )
}

#Preview("Loading") {
    AddCardView(
        store: Store(
            initialState: AddCardFeature.State(
                card: .isLoading
            ),
            reducer: {}
        )
    )
}

#Preview("Interactive: Fetch Success") {
    AddCardView(
        store: Store(
            initialState: AddCardFeature.State(
                input: "Bewahren"
            ),
            reducer: {
                AddCardFeature()
            },
            withDependencies: {
                $0.newCardFetcher = NewCardFetchingMock { _ in
                    try await Task.sleep(for: .seconds(1))

                    return .mock
                }
            }
        )
    )
}

#Preview("Interactive: Fetch Failure") {
    AddCardView(
        store: Store(
            initialState: AddCardFeature.State(),
            reducer: {
                AddCardFeature()
            },
            withDependencies: {
                $0.newCardFetcher = NewCardFetchingMock { _ in
                    try await Task.sleep(for: .seconds(1))

                    throw NSError(domain: "com.example.app", code: 1, userInfo: [NSLocalizedDescriptionKey: "Something went wrong."])
                }
            }
        )
    )
}
