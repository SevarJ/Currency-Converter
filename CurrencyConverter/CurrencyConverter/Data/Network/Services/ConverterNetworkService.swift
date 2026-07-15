//
//  ConverterNetworkService.swift
//  CurrencyConverter
//
//  Created by Sevar Jafarli on 15.07.26.
//

import Foundation

final class ConverterNetworkService: NetworkServiceProtocol {

    private let urlSession: URLSession

    init(urlSession: URLSession = .shared) {
        self.urlSession = urlSession
    }

    func fetch<T>(_ endpoint: ConverterEndpoint) async throws -> T where T: Decodable {
        guard let url = endpoint.url else {
            throw NetworkError.invalidURL
        }

        let data: Data
        let response: URLResponse
        
        do {
            (data, response) = try await urlSession.data(from: url)
        } catch {
            throw NetworkError.networkUnavailable
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.networkUnavailable
        }

        guard httpResponse.statusCode == 200 else {
            let apiMessage = (try? JSONDecoder().decode(APIErrorDTO.self, from: data))?.message
            throw NetworkError.apiError(apiMessage ?? "Server error (status \(httpResponse.statusCode))")
        }

        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            throw NetworkError.decodingFailed
        }
    }
}
