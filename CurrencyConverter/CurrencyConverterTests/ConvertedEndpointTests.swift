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

    @Test func ratesURL_containsBaseAndQuotes() async throws {
        let url = await ConverterEndpoint.rates(base: "USD", quotes: ["AZN", "EUR"]).url
        
        #expect(url?.absoluteString == "https://api.frankfurter.dev/v2/rates?base=USD&quotes=AZN,EUR")
    }

    @Test func ratesURL_omitsEmptyQotes() async throws {
        let url = await ConverterEndpoint.rates(base: "USD", quotes: []).url
        #expect(url?.absoluteString == "https://api.frankfurter.dev/v2/rates?base=USD")
    }
    
    @Test func ratesURL_path_matches() async throws {
        let url = await ConverterEndpoint.rate(base: "USD", quote: "EUR").url
        #expect(url?.absoluteString == "https://api.frankfurter.dev/v2/rate/USD/EUR")
    }
    
    @Test func currenciesURL_test() async throws {
        let url = await ConverterEndpoint.currencies.url
        #expect(url?.absoluteString == "https://api.frankfurter.dev/v2/currencies")
    }
    
    @Test func endpointURLNotNil() async throws {
        let url = await ConverterEndpoint.currencies.url
        #expect(url != nil)
    }
}
