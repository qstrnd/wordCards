// Copyright © 2024 Andrei (Andy) Iakovlev. See LICENSE file for details.

import Dependencies
import Foundation

struct AddCardClient: Sendable {
    var fetch: @Sendable (_ input: String) async throws -> Card
}

extension AddCardClient: DependencyKey {
    static let liveValue = Self { input in
        let url = URL(string: "http://localhost:8080/card")!

        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        struct Body: Encodable {
            let word: String
            let sourceLanguage: String
            let destinationLanguage: String
        }
        let body = Body(word: input, sourceLanguage: "de", destinationLanguage: "en")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(body)

        let (data, _) = try await URLSession.shared
            .data(for: request)

        struct Response: Decodable {
            let entries: Entries

            struct Entries: Decodable {
                let entries: [Card]
            }
        }

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let response = try decoder.decode(Response.self, from: data)

        return response.entries.entries.first!
    }
}

extension DependencyValues {
    var addCardClient: AddCardClient {
        get { self[AddCardClient.self] }
        set { self[AddCardClient.self] = newValue }
    }
}
