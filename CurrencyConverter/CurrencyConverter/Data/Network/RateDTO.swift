//
//  RateDTO.swift
//  CurrencyConverter
//
//  Created by Sevar Jafarli on 15.07.26.
//

import Foundation

struct RateDTO: Decodable {
    let date: String
    let base: String
    let quote: String
    let rate: Double
}
