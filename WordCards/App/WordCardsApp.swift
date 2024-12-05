// Copyright © 2024 Andrei (Andy) Iakovlev. See LICENSE file for details.

import ComposableArchitecture
import SwiftData
import SwiftUI

@main
struct WordCardsApp: App {
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

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        let myURL = "url"
        print("myUrl: \(myURL)")

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            TabView {
                SelectorView(store: Self.selectorStore)
                    .tabItem {
                        Label("Home", systemImage: "house.fill")
                    }

                ContactsView(store: Self.contactsStore)
                    .tabItem {
                        Label("Contacts", systemImage: "person.2.fill")
                    }

                ContentView()
                    .tabItem {
                        Label("SwiftData", systemImage: "swiftdata")
                    }
            }
        }
        .modelContainer(sharedModelContainer)
    }
}
