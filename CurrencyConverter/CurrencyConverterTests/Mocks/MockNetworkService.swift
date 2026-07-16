//
//  MockNetworkService.swift
//  CurrencyConverter
//
//  Created by Sevar Jafarli on 15.07.26.
//

@testable import CurrencyConverter

final class MockNetworkService: NetworkServiceProtocol {
    var result: Result<Any, Error> = .success([CurrencyDTO]())
    private(set) var fetchCallCount = 0
    private(set) var lastEndpoint: ConverterEndpoint?


    func fetch<T>(_ endpoint: CurrencyConverter.ConverterEndpoint) async throws -> T where T : Decodable {
        fetchCallCount += 1
        lastEndpoint = endpoint
        switch result {
        case .success(let value):
            return value as! T
        case .failure(let error):
            throw error
        }
    }
    
    
}
