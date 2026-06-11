//
//  RatesRepositoryProtocol.swift
//  CurrencyConverter
//
//  Created by Sevar Jafarli on 11.06.26.
//

import Foundation

protocol RatesRepositoryProtocol {
    func fetchTodayRates() async throws -> ExchangeRate
    func fetchRates(for: Date) async throws -> ExchangeRate
    func cachedTodayRates() async -> ExchangeRate?
}
