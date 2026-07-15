//
//  CurrencyDTO.swift
//  CurrencyConverter
//
//  Created by Sevar Jafarli on 15.07.26.
//

struct CurrencyDTO: Decodable {
    let isoCode: String
    let name: String
    let symbol: String
    
    enum CodingKeys: String, CodingKey {
        case isoCode = "iso_code"
        case name
        case symbol
    }
}
