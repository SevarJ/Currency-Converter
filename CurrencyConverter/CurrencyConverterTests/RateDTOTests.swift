//
//  RateDTOTests.swift
//  CurrencyConverterTests
//
//  Created by Sevar Jafarli on 15.07.26.
//

import Testing
@testable import CurrencyConverter
import Foundation

struct RateDTOTests {
    
    @Test func toDomain_validDTO_mapsAllFields() throws {
        let dto = RateDTO(
            date: "2026-07-15",
            base: "USD",
            quote: "EUR",
            rate: 0.875
        )
        
        let rate = try dto.toDomain()
        
        let expectedDate = DateUtils.dateFormatter.date(from: "2026-07-15")
        #expect(rate.date == expectedDate)
        #expect(rate.base == "USD")
        #expect(rate.quote == "EUR")
    }
    @Test func toDomain_rate_preservesDecimalPrecision() throws {
        let dto = RateDTO(
            date: "2026-07-15",
            base: "USD",
            quote: "EUR",
            rate: 0.875
        )
        
        let rate = try dto.toDomain()
        
        #expect(rate.rate == Decimal(string: "0.875")!)
    }
    
    @Test func toDomain_invalidDate_throws() {
        let dto = RateDTO(
            date: "15.07.2026",
            base: "USD",
            quote: "EUR",
            rate: 0.875
        )
        
        #expect(throws: NetworkError.self) {
            try dto.toDomain()
        }
    }
}
