//
//  CachedCurrenciesDTO.swift
//  CurrencyConverter
//
//  Created by Sevar Jafarli on 15.07.26.
//

import Foundation

struct CachedCurrenciesDTO: Codable {
    let savedAt: Date
    let currencies: [CachedCurrency]
    
    struct CachedCurrency: Codable {
        let code: String
        let name: String
        let symbol: String
    }
}
