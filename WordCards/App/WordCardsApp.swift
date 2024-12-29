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

    var body: some Scene {
        WindowGroup {
            TabView {
                HomeView(store: Self.homeStore)
                    .tabItem {
                        Label("Cards", systemImage: "menucard.fill")
                    }
            }
        }
    }
}
