// Copyright © 2024 Andrei (Andy) Iakovlev. See LICENSE file for details.

import Dependencies
import Foundation

struct AppEnvironment: Decodable {
    let apiBaseURL: URL
}

extension AppEnvironment: DependencyKey {
    static let liveValue: Self = {
        guard let url = Bundle.main.url(forResource: "env", withExtension: "json") else {
            fatalError("Config file not found")
        }

        let data = try! Data(contentsOf: url)

        struct AppConfig: Decodable {
            let device: AppEnvironment
            let simulator: AppEnvironment
        }
        let config = try! JSONDecoder().decode(AppConfig.self, from: data)

        #if targetEnvironment(simulator)
        return config.simulator
        #else
        return config.device
        #endif
    }()
}

extension DependencyValues {
    var appEnvironment: AppEnvironment {
        get { self[AppEnvironment.self] }
        set { self[AppEnvironment.self] = newValue }
    }
}
