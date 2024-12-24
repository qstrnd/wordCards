// Copyright © 2024 Andrei (Andy) Iakovlev. See LICENSE file for details.

import ComposableArchitecture
import SwiftData
import SwiftUI

@main
struct WordCardsApp: App {
    static let homeStore = Store(
        initialState: HomeFeature.State()
    ) {
        HomeFeature()
    }

    static let selectorStore = Store(
        initialState: SelectorFeature.State()
    ) {
        SelectorFeature()
            ._printChanges()
    }

    static let contactsStore = Store(
        initialState: ContactsFeature.State()
    ) {
        ContactsFeature()
            ._printChanges()
    }

    static let entryListStore = Store(
        initialState: EntryListFeature.State()
    ) {
        EntryListFeature()
            ._printChanges()
    }

    var body: some Scene {
        WindowGroup {
            TabView {
                HomeView(store: Self.homeStore)
                    .tabItem {
                        Label("Card", systemImage: "menucard.fill")
                    }

                SelectorView(store: Self.selectorStore)
                    .tabItem {
                        Label("Home", systemImage: "house.fill")
                    }

                ContactsView(store: Self.contactsStore)
                    .tabItem {
                        Label("Contacts", systemImage: "person.2.fill")
                    }
            }
        }
    }
}
