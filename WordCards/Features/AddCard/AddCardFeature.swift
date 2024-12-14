// Copyright © 2024 Andrei (Andy) Iakovlev. See LICENSE file for details.

import ComposableArchitecture
import SwiftUI

@Reducer
struct AddCardFeature {
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
        case selectSourceLanguage(LocalePickerFeature)
        case selectTargetLanguage(LocalePickerFeature)
    }

    @Dependency(\.newCardFetcher) var client
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

extension AddCardFeature.Destination.State: Equatable {}
