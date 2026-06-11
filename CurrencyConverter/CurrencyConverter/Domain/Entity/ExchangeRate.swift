//
//  ExchangeRate.swift
//  CurrencyConverter
//
//  Created by Sevar Jafarli on 10.06.26.
//

import Foundation

struct ExchangeRate: Identifiable, Codable {
    let id: UUID
    let date: Date
    let currencies: [Currency]
    
    init(
        id: UUID = UUID(),
        date: Date,
        currencies: [Currency]
    ) {
        self.id = id
        self.date = date
        self.currencies = currencies
    }
    
    func currency(for code: String) -> Currency? {
        currencies.first { $0.code == code }
    }
}
