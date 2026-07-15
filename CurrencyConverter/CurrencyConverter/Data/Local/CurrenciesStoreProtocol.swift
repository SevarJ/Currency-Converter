//
//  CurrenciesStoreProtocol.swift
//  CurrencyConverter
//
//  Created by Sevar Jafarli on 15.07.26.
//

import Foundation

protocol CurrenciesStoreProtocol {
    func load() -> [Currency]?
    func save(_ currencies: [Currency])
}
