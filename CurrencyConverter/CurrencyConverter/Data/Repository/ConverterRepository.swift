//
//  ConverterRepository.swift
//  CurrencyConverter
//
//  Created by Sevar Jafarli on 15.07.26.
//

import Foundation

final class ConverterRepository: ConverterRepositoryProtocol {
    
    private let networkService: NetworkServiceProtocol
    private let currenciesStore: CurrenciesStoreProtocol
    
    init(
        networkService: NetworkServiceProtocol = ConverterNetworkService(),
        currenciesStore: CurrenciesStoreProtocol = CurrenciesDataStore()
    ) {
        self.networkService = networkService
        self.currenciesStore = currenciesStore
    }
    
    func currencies() async throws -> [Currency] {
        if let cached = currenciesStore.load(ignoringTTL: false), !cached.isEmpty {
            return cached
        }
        do {
            let dtos: [CurrencyDTO] = try await networkService.fetch(.currencies)
            let currencies = dtos.map { $0.toDomain() }
            
            currenciesStore.save(currencies)
            return currencies
        }
        catch {
            if let stale = currenciesStore.load(ignoringTTL: true), !stale.isEmpty {
                return stale
            }
            
            throw error
        }
    }
    
    
    func rate(base: String, quote: String) async throws -> Rate {
        let dto: RateDTO = try await networkService.fetch(.rate(base: base, quote: quote))
        return try dto.toDomain()
    }
    
    func rates(base: String, quotes: [String]) async throws -> [Rate] {
        let dtos: [RateDTO] = try await networkService.fetch(.rates(base: base, quotes: quotes))
        return try dtos.map { try $0.toDomain() }
    }
}
