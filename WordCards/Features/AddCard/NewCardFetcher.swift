// Copyright © 2024 Andrei (Andy) Iakovlev. See LICENSE file for details.

import Dependencies
import Foundation

protocol NewCardFetching: Sendable {
    func getCard(for input: String) async throws -> Card
}

struct NewCardFetcher: NewCardFetching {
    @Dependency(\.appEnvironment) var env

    func getCard(for input: String) async throws -> Card {
        let url = env.apiBaseURL.appendingPathComponent("card")

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

#if DEBUG
struct NewCardFetchingMock: NewCardFetching {
    var getCard: @Sendable (String) async throws -> Card

    func getCard(for input: String) async throws -> Card {
        try await getCard(input)
    }
}
#endif

private enum NewCardFetchingKey: DependencyKey {
    static let liveValue: any NewCardFetching = NewCardFetcher()
}

extension DependencyValues {
    var newCardFetcher: NewCardFetching {
        get { self[NewCardFetchingKey.self] }
        set { self[NewCardFetchingKey.self] = newValue }
    }
}