// Copyright © 2024 Andrei (Andy) Iakovlev. See LICENSE file for details.

import ComposableArchitecture
import SwiftUI

// MARK: - Feature

@Reducer
struct EntryListFeature {
    @ObservableState
    struct State: Equatable {
        var entries: [EntryListItem] = []
    }

    enum Action {
        case viewAppeared
        case entriesLoaded([EntryListItem])
        case loadingFailed
        case deleteEntryItemButtonTapped(itemID: UUID)
        case deletionFailed
    }

    @Dependency(\.entryListItemRepository) var entryListItemRepository
    @Dependency(\.deleteEntryHandler) var deleteEntryHandler

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .viewAppeared:
                return .run { send in
                    do {
                        let entriesStream = await entryListItemRepository.fetchEntryListItems()
                        for try await entries in entriesStream {
                            await send(.entriesLoaded(entries))
                        }
                    } catch {
                        await send(.loadingFailed)
                    }
                }
            case let .deleteEntryItemButtonTapped(itemID: id):
                return .run { send in
                    do {
                        try await deleteEntryHandler.deleteEntry(id: id)
                    } catch {
                        await send(.deletionFailed)
                    }
                }
            case let .entriesLoaded(entries):
                state.entries = entries
                return .none
            case .loadingFailed:
                // TODO: Show some kind of retry button
                return .none
            case .deletionFailed:
                return .none
            }
        }
    }
}

// MARK: - View

struct EntryListView: View {
    @Bindable var store: StoreOf<EntryListFeature>

    var body: some View {
        Section("All Entries") {
            ForEach(store.entries, id: \.self) { entry in
                NavigationLink(state: CardDetailFeature.State(cardID: entry.id)) {
                    entryListItem(for: entry)
                }
            }
        }
        .onAppear {
            store.send(.viewAppeared)
        }
    }

    @ViewBuilder
    func entryListItem(for entry: EntryListItem) -> some View {
        VStack(alignment: .leading) {
            Text(entry.sourceText)
                .bold()
            Text(entry.translation)
        }
        .swipeActions {
            Button(role: .destructive) {
                store.send(.deleteEntryItemButtonTapped(itemID: entry.id))
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }
}

// MARK: - Preview

#Preview("Default") {
    List {
        EntryListView(
            store: Store(
                initialState: EntryListFeature.State(
                    entries: EntryListItem.mock
                )
            ) {
                EntryListFeature()
            } withDependencies: {
                $0.entryListItemRepository = EntryListItemRepositoryMock {
                    EntryListItem.mock
                }
            }
        )
    }
}
