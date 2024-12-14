// Copyright © 2024 Andrei (Andy) Iakovlev. See LICENSE file for details.

import ComposableArchitecture
import SwiftUI

// MARK: - Feature

@Reducer
struct NewEntryFeature {
    @ObservableState
    struct State: Equatable {
        @CasePathable
        enum CardState: Equatable {
            case empty
            case isLoading
            case loaded(Card)
        }

        @Presents var destination: Destination.State?
        @Shared(.appStorage("addCardSourceLanguage")) var sourceLanguage = "DE"
        @Shared(.appStorage("addCardTargetLanguage")) var targetLanguage = "EN"

        var input = ""
        var card = CardState.empty
        var errorNotification: String?
        var isLoadButtonEnabled = false
    }

    enum Action {
        case setInput(String)

        case selectSourceLanguageButtonTapped
        case selectTargetLanguageButtonTapped

        case loadButtonTapped
        case cardLoaded(Card)
        case cardLoadingFailed(Error)

        case errorNotificationDismissed

        case destination(PresentationAction<Destination.Action>)
    }

    enum CancelID {
        case cardLoading
        case errorNotification
    }

    @Reducer
    enum Destination {
        case selectSourceLanguage(LanguagePickerFeature)
        case selectTargetLanguage(LanguagePickerFeature)
    }

    @Dependency(\.newEntryClient) var client
    @Dependency(\.continuousClock) var clock

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .setInput(input):
                state.input = input
                state.isLoadButtonEnabled = !input.isEmpty

                return .cancel(id: CancelID.cardLoading)
            case .selectSourceLanguageButtonTapped:
                state.destination = .selectSourceLanguage(
                    .init(
                        selectedLocaleID: state.sourceLanguage
                    )
                )

                return .none
            case .selectTargetLanguageButtonTapped:
                state.destination = .selectTargetLanguage(
                    .init(
                        selectedLocaleID: state.targetLanguage
                    )
                )

                return .none
            case .loadButtonTapped:
                state.card = .isLoading
                state.isLoadButtonEnabled = false

                return .run { [input = state.input, source = state.sourceLanguage, target = state.targetLanguage] send in
                    do {
                        let card = try await client.getCard(for: input, sourceLanguage: source, targetLanguage: target)
                        await send(.cardLoaded(card))
                    } catch {
                        await send(.cardLoadingFailed(error))
                    }
                }
                .cancellable(id: CancelID.cardLoading, cancelInFlight: true)
            case let .cardLoaded(card):
                state.card = .loaded(card)

                return .none
            case let .cardLoadingFailed(error):
                state.card = .empty
                state.errorNotification = error.localizedDescription
                state.isLoadButtonEnabled = true

                return .run { _ in
                    try await clock.sleep(for: .seconds(5))
                }
                .cancellable(id: CancelID.errorNotification, cancelInFlight: true)
            case .errorNotificationDismissed:
                state.errorNotification = nil

                return .none
            case let .destination(.presented(.selectSourceLanguage(.delegate(.select(localeID: newSourceLanguageID))))):
                if state.targetLanguage == newSourceLanguageID {
                    state.targetLanguage = state.sourceLanguage
                }
                state.sourceLanguage = newSourceLanguageID

                return .none
            case let .destination(.presented(.selectTargetLanguage(.delegate(.select(localeID: newTargetLanguageID))))):
                if state.sourceLanguage == newTargetLanguageID {
                    state.sourceLanguage = state.targetLanguage
                }
                state.targetLanguage = newTargetLanguageID

                return .none
            case .destination:
                return .none
            }
        }
        .ifLet(\.$destination, action: \.destination)
    }
}

extension NewEntryFeature.Destination.State: Equatable {}

// MARK: - View

struct NewEntryView: View {
    @Bindable var store: StoreOf<NewEntryFeature>

    var body: some View {
        NavigationView {
            newEntryView
        }
        .sheet(
            item: $store.scope(state: \.destination?.selectSourceLanguage, action: \.destination.selectSourceLanguage)
        ) { store in
            NavigationView {
                LanguagePickerView(
                    store: store,
                    navigationTitle: "Source Language"
                )
            }
        }
        .sheet(
            item: $store.scope(state: \.destination?.selectTargetLanguage, action: \.destination.selectTargetLanguage)
        ) { store in
            NavigationView {
                LanguagePickerView(
                    store: store,
                    navigationTitle: "Target Language"
                )
            }
        }
    }

    @ViewBuilder
    var newEntryView: some View {
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

// MARK: - Preview

#Preview("Loaded") {
    NewEntryView(
        store: Store(
            initialState: NewEntryFeature.State(
                input: "Bewahren",
                card: .loaded(.mock)
            ),
            reducer: {}
        )
    )
}

#Preview("Loading") {
    NewEntryView(
        store: Store(
            initialState: NewEntryFeature.State(
                card: .isLoading
            ),
            reducer: {}
        )
    )
}

#Preview("Interactive: Fetch Success") {
    NewEntryView(
        store: Store(
            initialState: NewEntryFeature.State(
                input: "Bewahren"
            ),
            reducer: {
                NewEntryFeature()
            },
            withDependencies: {
                $0.newEntryClient = NewCardFetchingMock { _ in
                    try await Task.sleep(for: .seconds(1))

                    return .mock
                }
            }
        )
    )
}

#Preview("Interactive: Fetch Failure") {
    NewEntryView(
        store: Store(
            initialState: NewEntryFeature.State(),
            reducer: {
                NewEntryFeature()
            },
            withDependencies: {
                $0.newEntryClient = NewCardFetchingMock { _ in
                    try await Task.sleep(for: .seconds(1))

                    throw NSError(domain: "com.example.app", code: 1, userInfo: [NSLocalizedDescriptionKey: "Something went wrong."])
                }
            }
        )
    )
}
