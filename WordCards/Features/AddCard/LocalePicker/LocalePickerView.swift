// Copyright © 2024 Andrei (Andy) Iakovlev. See LICENSE file for details.

import ComposableArchitecture
import SwiftUI

// MARK: - Feature

@Reducer
struct LocalePickerFeature {
    @ObservableState
    struct State: Equatable {
        @Shared(.fileStorage(.recentLocales)) var recentLocales: [PresentableLocale] = []
        var allAvailableLocales: [PresentableLocale] = []

        var filteredLocales: [PresentableLocale] = []
        var searchText = ""

        let selectionIdentifier: String
        var selectedLocaleID: String?
    }

    enum Action {
        case setSearchText(String)

        case viewAppeared
        case cancelButtonTapped
        case availableLocalesLoaded([PresentableLocale])
        case localeCellTapped(PresentableLocale)
        case delegate(Delegate)

        @CasePathable
        enum Delegate: Equatable {
            case select(localeID: String, selectionIdentifier: String)
        }
    }

    @Dependency(\.presentableLocalesProvider) var presentableLocalesProvider
    @Dependency(\.dismiss) var dismiss

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .viewAppeared:
                return .run(priority: .userInitiated) { send in
                    let locales = await presentableLocalesProvider.allLocales()
                    await send(.availableLocalesLoaded(locales))
                }
            case .cancelButtonTapped:
                return .run { _ in
                    await self.dismiss()
                }
            case let .availableLocalesLoaded(availableLocales):
                state.allAvailableLocales = availableLocales
                return .none
            case let .setSearchText(text):
                state.searchText = text

                if text.isEmpty {
                    state.filteredLocales = []
                } else {
                    let normalizedSearchText = text.uppercased()
                    state.filteredLocales = state.allAvailableLocales.filter { locale in
                        locale.name.uppercased().contains(normalizedSearchText) || locale.id.uppercased().contains(normalizedSearchText)
                    }
                }

                return .none
            case let .localeCellTapped(locale):
                state.recentLocales.insert(locale, at: 0)
                state.recentLocales = Array(state.recentLocales.prefix(5))
                state.selectedLocaleID = locale.id

                return .run { [selectionIdentifier = state.selectionIdentifier] send in
                    await send(
                        .delegate(
                            .select(
                                localeID: locale.id,
                                selectionIdentifier: selectionIdentifier
                            )
                        )
                    )
                    await self.dismiss()
                }
            case .delegate:
                return .none
            }
        }
    }
}

private extension URL {
    static var recentLocales: URL {
        URL.documentsDirectory.appending(component: "recent_locales.json")
    }
}

// MARK: - View

struct LocalePickerView: View {
    @Bindable var store: StoreOf<LocalePickerFeature>
    @State private var searchIsActive = false
    
    var navigationTitle: String
    
    var body: some View {
        List {
            if store.searchText.isEmpty {
                if !store.recentLocales.isEmpty {
                    Section(header: Text("Recent")) {
                        ForEach(store.recentLocales) { locale in
                            localeRow(for: locale)
                        }
                    }
                }

                Section(header: Text("All")) {
                    ForEach(store.allAvailableLocales) { locale in
                        localeRow(for: locale)
                    }
                }
            } else {
                Section {
                    ForEach(store.filteredLocales) { locale in
                        localeRow(for: locale)
                    }
                }
            }
        }
        .searchable(text: $store.searchText.sending(\.setSearchText), isPresented: $searchIsActive)
        .navigationTitle(navigationTitle)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("Cancel") {
                    store.send(.cancelButtonTapped)
                }
            }
        }
        .onAppear {
            store.send(.viewAppeared)
        }
    }

    @ViewBuilder
    private func localeRow(for locale: PresentableLocale) -> some View {
        HStack {
            Text(locale.id)
                .bold()
            Text(locale.name)
            Spacer()

            if store.selectedLocaleID == locale.id {
                Image(systemName: "checkmark")
                    .foregroundColor(.accentColor)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            store.send(.localeCellTapped(locale))
        }
    }
}

// MARK: - Preview

#Preview("All Available") {
    NavigationView {
        LocalePickerView(
            store: Store(
                initialState: LocalePickerFeature.State(
                    selectionIdentifier: "",
                    selectedLocaleID: "HY"
                )
            ) {
                LocalePickerFeature()
            },
            navigationTitle: "Source Language"
        )
    }
}

#Preview("All Available + Recent") {
    NavigationView {
        LocalePickerView(
            store: Store(
                initialState: LocalePickerFeature.State(
                    recentLocales: [
                        PresentableLocale(id: "EN", name: "English"),
                        PresentableLocale(id: "DE", name: "German"),
                    ],
                    selectionIdentifier: "",
                    selectedLocaleID: "EN"
                )
            ) {
                LocalePickerFeature()
            },
            navigationTitle: "Source Language"
        )
    }
}
