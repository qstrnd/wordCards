// Copyright © 2024 Andrei (Andy) Iakovlev. See LICENSE file for details.

import ComposableArchitecture
import SwiftUI

// MARK: - Feature

@Reducer
struct HomeFeature {
    @ObservableState
    struct State: Equatable {
        var newEntry = NewEntryFeature.State()
        var entryList = EntryListFeature.State()
    }

    enum Action {
        case newEntry(NewEntryFeature.Action)
        case entryList(EntryListFeature.Action)
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
        Reduce { _, action in
            switch action {
            case .newEntry:
                .none
            case .entryList:
                .none
            }
        }
    }
}

// MARK: - View

struct HomeView: View {
    @Bindable var store: StoreOf<HomeFeature>

    var body: some View {
        List {
            NewEntryView(
                store: store.scope(state: \.newEntry, action: \.newEntry)
            )

            EntryListView(
                store: store.scope(state: \.entryList, action: \.entryList)
            )
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
