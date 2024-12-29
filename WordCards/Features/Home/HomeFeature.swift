// Copyright © 2024 Andrei (Andy) Iakovlev. See LICENSE file for details.

import ComposableArchitecture
import SwiftUI

// MARK: - Feature

@Reducer
struct HomeFeature {
    @ObservableState
    struct State: Equatable {
        var path = StackState<CardDetailFeature.State>()
        var newEntry = NewEntryFeature.State()
        var entryList = EntryListFeature.State()
    }

    enum Action {
        case newEntry(NewEntryFeature.Action)
        case entryList(EntryListFeature.Action)
        case path(StackAction<CardDetailFeature.State, CardDetailFeature.Action>)
    }

    var body: some ReducerOf<Self> {
        Scope(
            state: \.newEntry,
            action: \.newEntry
        ) {
            NewEntryFeature()
        }
        Scope(
            state: \.entryList,
            action: \.entryList
        ) {
            EntryListFeature()
        }
        Reduce { _, _ in
            .none
        }
        .forEach(\.path, action: \.path) {
            CardDetailFeature()
        }
    }
}

// MARK: - View

struct HomeView: View {
    @Bindable var store: StoreOf<HomeFeature>

    var body: some View {
        NavigationStack(path: $store.scope(state: \.path, action: \.path)) {
            List {
                NewEntryView(
                    store: store.scope(state: \.newEntry, action: \.newEntry)
                )

                EntryListView(
                    store: store.scope(state: \.entryList, action: \.entryList)
                )
            }
        } destination: { store in
            CardDetailView(store: store)
        }
    }
}

// MARK: - Preview

#Preview("Default") {
    HomeView(
        store: Store(
            initialState: HomeFeature.State(
                newEntry: NewEntryFeature.State(
                    input: "",
                    card: .empty
                ),
                entryList: EntryListFeature.State(
                    entries: EntryListItem.mock
                )
            )
        ) {
            HomeFeature()
        } withDependencies: {
            $0.entryListItemRepository = EntryListItemRepositoryMock {
                EntryListItem.mock
            }
        }
    )
}

#Preview("Card Loaded") {
    HomeView(
        store: Store(
            initialState: HomeFeature.State(
                newEntry: NewEntryFeature.State(
                    input: "Bewahren",
                    card: .loaded(.mock1)
                ),
                entryList: EntryListFeature.State(
                    entries: EntryListItem.mock
                )
            )
        ) {
            HomeFeature()
        } withDependencies: {
            $0.entryListItemRepository = EntryListItemRepositoryMock {
                EntryListItem.mock
            }
        }
    )
}
