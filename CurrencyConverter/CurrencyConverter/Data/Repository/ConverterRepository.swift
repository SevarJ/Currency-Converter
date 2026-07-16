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
        networkService: NetworkServiceProtocol,
        currenciesStore: CurrenciesStoreProtocol
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
    
    func history(base: String, quote: String, from: Date, to: Date?) async throws -> [Rate] {
        let group = grouping(from: from, to: to ?? Date())
        let dtos: [RateDTO] = try await networkService.fetch(
            .history(
                    base: base,
                    quote: quote,
                    from: from,
                    to: to,
                    group: group
            )
        )
        return try dtos.map { try $0.toDomain() }
    }
    
    private func grouping(from: Date, to: Date) -> String? {
        let days = Calendar.current.dateComponents([.day], from: from, to: to).day ?? 0
        switch days {
        case ..<45:    return nil
        case ..<400:   return "week"
        default:       return "month"
        }
    }
}
