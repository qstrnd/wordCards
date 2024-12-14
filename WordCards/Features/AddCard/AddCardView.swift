// Copyright © 2024 Andrei (Andy) Iakovlev. See LICENSE file for details.

import ComposableArchitecture
import SwiftUI

struct AddCardView: View {
    @Bindable var store: StoreOf<AddCardFeature>

    var body: some View {
        NavigationView {
            addCardView
        }
        .sheet(
            item: $store.scope(state: \.destination?.selectSourceLanguage, action: \.destination.selectSourceLanguage)
        ) { store in
            NavigationView {
                LocalePickerView(
                    store: store,
                    navigationTitle: "Source Language"
                )
            }
        }
        .sheet(
            item: $store.scope(state: \.destination?.selectTargetLanguage, action: \.destination.selectTargetLanguage)
        ) { store in
            NavigationView {
                LocalePickerView(
                    store: store,
                    navigationTitle: "Target Language"
                )
            }
        }
    }

    @ViewBuilder
    var addCardView: some View {
        ZStack {
            Form {
                Section {
                    TextField("Input", text: $store.input.sending(\.setInput))

                    HStack {
                        Button("Get Info") {
                            store.send(.loadButtonTapped)
                        }
                        .disabled(!store.isLoadButtonEnabled)

                        Spacer()

                        Button(store.sourceLanguage) {
                            store.send(.selectSourceLanguageButtonTapped)
                        }
                        .buttonStyle(.bordered)

                        Image(systemName: "arrow.right")
                            .foregroundStyle(.quaternary)

                        Button(store.targetLanguage) {
                            store.send(.selectTargetLanguageButtonTapped)
                        }
                        .buttonStyle(.bordered)
                    }
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
