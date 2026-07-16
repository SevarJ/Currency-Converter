//
//  ConvertedEndpointTests.swift
//  CurrencyConverterTests
//
//  Created by Sevar Jafarli on 15.07.26.
//

import Testing
import Foundation
@testable import CurrencyConverter

struct ConvertedEndpointTests {

    @Test func ratesURL_containsBaseAndQuotes() throws {
        let url = ConverterEndpoint.rates(base: "USD", quotes: ["AZN", "EUR"]).url
        
        #expect(url?.absoluteString == "https://api.frankfurter.dev/v2/rates?base=USD&quotes=AZN,EUR")
    }

    @Test func ratesURL_omitsEmptyQotes() throws {
        let url = ConverterEndpoint.rates(base: "USD", quotes: []).url
        #expect(url?.absoluteString == "https://api.frankfurter.dev/v2/rates?base=USD")
    }
    
    @Test func ratesURL_path_matches() throws {
        let url = ConverterEndpoint.rate(base: "USD", quote: "EUR").url
        #expect(url?.absoluteString == "https://api.frankfurter.dev/v2/rate/USD/EUR")
    }
    
    @Test func currenciesURL_test() throws {
        let url = ConverterEndpoint.currencies.url
        #expect(url?.absoluteString == "https://api.frankfurter.dev/v2/currencies")
    }
    
    @Test func endpointURLNotNil() throws {
        let url = ConverterEndpoint.currencies.url
        #expect(url != nil)
    }
    
    @Test func ratesURL_historyContainsAllQueryItems() throws {
        let calendar = Calendar.current
        let fromDate = calendar.date(
            from: DateComponents(
                year: 2026,
                month: 7,
                day: 6
            )
        )
        
        let toDate = calendar.date(
            from: DateComponents(
                year: 2026,
                month: 7,
                day: 16
            )
        )
        let url = ConverterEndpoint.history(
            base: "USD",
            quote: "EUR",
            from: fromDate!,
            to: toDate,
            group: "day"
        ).url
        
        #expect(url?.absoluteString == "https://api.frankfurter.dev/v2/rates?base=USD&quotes=EUR&from=2026-07-06&to=2026-07-16&group=day")
    }
    
    @Test func ratesURL_history_Without_ToAndGroup() throws {
        let calendar = Calendar.current
        let fromDate = calendar.date(
            from: DateComponents(
                year: 2026,
                month: 7,
                day: 6
            )
        )
        
        let url = ConverterEndpoint.history(
            base: "USD",
            quote: "EUR",
            from: fromDate!,
            to: nil,
            group: nil
        ).url
        
        #expect(url?.absoluteString == "https://api.frankfurter.dev/v2/rates?base=USD&quotes=EUR&from=2026-07-06")
    }
}
