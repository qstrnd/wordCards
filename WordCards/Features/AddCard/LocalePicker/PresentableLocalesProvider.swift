// Copyright © 2024 Andrei (Andy) Iakovlev. See LICENSE file for details.

import ComposableArchitecture
import Foundation

struct PresentableLocale: Equatable, Codable, Identifiable {
    let id: String
    let name: String
}

private extension PresentableLocale {
    // TODO: Allow only explicitly supported set of locales
    static let live = Locale.availableIdentifiers
        .filter { identifier in
            !identifier.contains("_")
        }
        .map { identifier in
            PresentableLocale(
                id: identifier.uppercased(),
                name: Locale.current.localizedString(forIdentifier: identifier) ?? ""
            )
        }
        .sorted {
            $0.name < $1.name
        }
}

struct PresentableLocalesProvider {
    let allLocales: @Sendable () async -> [PresentableLocale]
}

extension PresentableLocalesProvider: DependencyKey {
    static let liveValue = Self {
        PresentableLocale.live
    }
}

extension DependencyValues {
    var presentableLocalesProvider: PresentableLocalesProvider {
        get { self[PresentableLocalesProvider.self] }
        set { self[PresentableLocalesProvider.self] = newValue }
    }
}
