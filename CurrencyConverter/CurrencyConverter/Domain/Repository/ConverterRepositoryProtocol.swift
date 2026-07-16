//
//  ConverterRepositoryProtocol.swift
//  CurrencyConverter
//
//  Created by Sevar Jafarli on 15.07.26.
//

import Foundation

protocol ConverterRepositoryProtocol {
    func currencies() async throws -> [Currency]
    func rate(base: String, quote: String) async throws -> Rate
    func rates(base: String, quotes: [String]) async throws -> [Rate]
    func history(base: String, quote: String, from: Date, to: Date?) async throws -> [Rate]
}
