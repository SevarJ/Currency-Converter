//
//  Currency.swift
//  CurrencyConverter
//
//  Created by Sevar Jafarli on 10.06.26.
//

import Foundation

struct Currency: Identifiable, Hashable, Codable {
    let code: String
    let name: String      
    let nominal: Int
    let rate: Decimal
    let date: Date
    
    var id: String { code }
    
    var normalizedRate: Decimal {
        rate / Decimal(nominal)
    }
}
