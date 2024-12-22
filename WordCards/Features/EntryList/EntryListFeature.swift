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
    }

    @Dependency(\.entryListItemRepository) var entryListItemRepository

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .viewAppeared:
                return .run { send in
                    let entries = try await entryListItemRepository.fetchEntryListItems()
                    await send(.entriesLoaded(entries))
                }
            case let .entriesLoaded(entries):
                state.entries = entries
                return .none
            }
        }
    }
}

// MARK: - View

struct EntryListView: View {
    @Bindable var store: StoreOf<EntryListFeature>

    var body: some View {
        List {
            ForEach(store.entries, id: \.self) { entry in
                entryListItem(for: entry)
                    .scaleEffect(x: 1, y: -1, anchor: .center)
            }
        }
        .scaleEffect(x: 1, y: -1, anchor: .center)
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
    }
}

// MARK: - Preview

#Preview("Default") {
    NavigationView {
        EntryListView(
            store: Store(
                initialState: EntryListFeature.State(
                    entries: [Card.mock1, Card.mock2, Card.mock3].enumerated().map {
                        EntryListItem(
                            id: UUID($0.offset),
                            sourceText: $0.element.input ?? "",
                            translation: $0.element.translation
                        )
                    }
                )
            ) {
                EntryListFeature()
            }
        )
    }
}
