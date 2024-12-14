// Copyright © 2024 Andrei (Andy) Iakovlev. See LICENSE file for details.

import ComposableArchitecture
import SwiftUI

@Reducer
struct AddCardFeature {
    @ObservableState
    struct State: Equatable {
        var input = ""
        var card = CardState.empty
        var errorNotification: String?
        var isLoadButtonEnabled = false

        @CasePathable
        enum CardState: Equatable {
            case empty
            case isLoading
            case loaded(Card)
        }
    }

    enum Action {
        case setInput(String)
        case loadButtonTapped
        case cardLoaded(Card)
        case cardLoadingFailed(Error)
        case errorNotificationDismissed
    }

    enum CancelID {
        case cardLoading
        case errorNotification
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
            case .loadButtonTapped:
                state.card = .isLoading
                state.isLoadButtonEnabled = false

                return .run { [input = state.input] send in
                    do {
                        let card = try await client.getCard(for: input)
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
            }
        }
    }
}
