//
//  Currency.swift
//  CurrencyConverter
//
//  Created by Sevar Jafarli on 15.07.26.
//

import Foundation

struct Currency: Identifiable, Hashable {
    var id: String {
        code
    }
    let code: String
    let name: String
    let symbol: String
}
