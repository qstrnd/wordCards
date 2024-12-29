// Copyright © 2024 Andrei (Andy) Iakovlev. See LICENSE file for details.

import ComposableArchitecture
import SwiftUI

// MARK: - Feature

@Reducer
struct CardDetailFeature {
    @ObservableState
    struct State: Equatable {
        @Presents var alert: AlertState<Action.Alert>?
        var cardID: UUID
        var card: Card?
    }

    @Dependency(\.cardDetailRepository) var cardDetailRepository
    @Dependency(\.deleteEntryHandler) var deleteEntryHandler
    @Dependency(\.dismiss) var dismiss

    enum Action {
        case alert(PresentationAction<Alert>)
        case viewAppeared
        case cardLoaded(Card)
        case cardLoadFailed(Error)
        case deleteButtonTapped
        case deletionFailed

        enum Alert {
            case confirmDeletion
        }

        enum AlertDelegate {
            case confirmDeletion
        }
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
            case .deleteButtonTapped:
                state.alert = .confirmDeletion
                return .none
            case .alert(.presented(.confirmDeletion)):
                return .run { [id = state.cardID] send in
                    do {
                        try await deleteEntryHandler.deleteEntry(id: id)
                        await self.dismiss()
                    } catch {
                        await send(.deletionFailed)
                    }
                }
            case .alert:
                return .none
            case .deletionFailed:
                return .none
            }
        }
        .ifLet(\.alert, action: \.alert)
    }
}

extension AlertState where Action == CardDetailFeature.Action.Alert {
    static let confirmDeletion = Self {
        TextState("Delete the current entry?")
    } actions: {
        ButtonState(role: .destructive, action: .confirmDeletion) {
            TextState("Delete")
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

                Section {
                    Button("Delete", role: .destructive) {
                        store.send(.deleteButtonTapped)
                    }
                    .frame(maxWidth: .greatestFiniteMagnitude)
                }
            } else {
                EmptyView()
            }
        }
        .alert($store.scope(state: \.alert, action: \.alert))
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
