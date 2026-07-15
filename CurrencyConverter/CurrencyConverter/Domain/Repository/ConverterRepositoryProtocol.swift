//
//  ConverterRepositoryProtocol.swift
//  CurrencyConverter
//
//  Created by Sevar Jafarli on 15.07.26.
//

protocol ConverterRepositoryProtocol {
    func currencies() async throws -> [Currency]
    func rate(base: String, quote: String) async throws -> Rate
    func rates(base: String, quotes: [String]) async throws -> [Rate]
}


final class ConverterRepository: ConverterRepositoryProtocol {
    
    private let networkService: NetworkServiceProtocol
    
    init(
        networkService: NetworkServiceProtocol = ConverterNetworkService()
    ) {
        self.networkService = networkService
    }
    
    func currencies() async throws -> [Currency] {
        let dtos: [CurrencyDTO] = try await networkService.fetch(.currencies)
        return dtos.map { $0.toDomain() }
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
