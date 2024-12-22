// Copyright © 2024 Andrei (Andy) Iakovlev. See LICENSE file for details.

import ComposableArchitecture
import SwiftData
import SwiftUI

@main
struct WordCardsApp: App {
    static let addCardStore = Store(
        initialState: NewEntryFeature.State()
    ) {
        NewEntryFeature()
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
                NewEntryView(store: Self.addCardStore)
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

                EntryListView(store: Self.entryListStore)
                    .tabItem {
                        Label("SwiftData", systemImage: "swiftdata")
                    }
            }
        }
    }
}
