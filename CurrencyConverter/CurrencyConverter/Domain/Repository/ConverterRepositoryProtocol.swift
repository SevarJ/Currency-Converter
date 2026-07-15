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
