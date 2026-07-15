//
//  MockNetworkService.swift
//  CurrencyConverter
//
//  Created by Sevar Jafarli on 15.07.26.
//

@testable import CurrencyConverter

final class MockNetworkService: NetworkServiceProtocol {
    var result: Result<[CurrencyDTO], Error> = .success([])
    private(set) var fetchCallCount = 0

    func fetch<T>(_ endpoint: CurrencyConverter.ConverterEndpoint) async throws -> T where T : Decodable {
        fetchCallCount += 1
        switch result {
        case .success(let dtos):
            return dtos as! T
        case .failure(let error):
            throw error
        }
    }
    
    
}
