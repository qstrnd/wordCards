// Copyright © 2024 Andrei (Andy) Iakovlev. See LICENSE file for details.

import ComposableArchitecture
import SwiftData
import SwiftUI

@main
struct WordCardsApp: App {
    static let store = Store(initialState: CounterFeature.State()) {
        CounterFeature()
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
                CounterView(store: Self.store)
                    .tabItem {
                        Label("Home", systemImage: "house.fill")
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
