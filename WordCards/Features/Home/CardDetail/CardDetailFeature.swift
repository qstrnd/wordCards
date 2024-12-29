// Copyright © 2024 Andrei (Andy) Iakovlev. See LICENSE file for details.

import ComposableArchitecture
import SwiftUI

// MARK: - Feature

@Reducer
struct CardDetailFeature {
    @ObservableState
    struct State: Equatable {
        var cardID: UUID
        var card: Card?
    }

    @Dependency(\.cardDetailRepository) var cardDetailRepository

    enum Action {
        case viewAppeared
        case cardLoaded(Card)
        case cardLoadFailed(Error)
    }

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .viewAppeared:
                return .run(priority: .high) { [cardID = state.cardID] send in
                    do {
                        let card = try await cardDetailRepository.fetchCardDetail(for: cardID)
                        await send(.cardLoaded(card))
                    } catch {
                        await send(.cardLoadFailed(error))
                    }
                }
            case let .cardLoaded(card):
                state.card = card

                return .none
            case .cardLoadFailed:
                return .none
            }
        }
    }
}

// MARK: - View

struct CardDetailView: View {
    @Bindable var store: StoreOf<CardDetailFeature>

    var body: some View {
        List {
            if let card = store.card {
                CardInfoView(card: card)
            } else {
                EmptyView()
            }
        }
        .onAppear {
            store.send(.viewAppeared)
        }
    }
}

// MARK: - Preview

#Preview("Default") {
    CardDetailView(
        store: Store(
            initialState: CardDetailFeature.State(cardID: UUID(0), card: .mock1)
        ) {
            CardDetailFeature()
        } withDependencies: {
            $0.cardDetailRepository = CardDetailRepositoryMock(fetchCardDetail: { _ in
                .mock1
            })
        }
    )
}
