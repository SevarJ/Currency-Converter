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

extension RateDTO {
    func toDomain() throws -> Rate {
        guard let parsedDate = DateUtils.dateFormatter.date(from: date) else {
            throw RatesError.decodingFailed
        }
        guard let decimalRate = Decimal(string: "\(rate)") else {
            throw RatesError.decodingFailed
        }
        return Rate(
            date: parsedDate,
            base: base,
            quote: quote,
            rate: decimalRate
        )
    }
}
