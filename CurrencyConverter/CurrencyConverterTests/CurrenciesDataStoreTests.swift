//
//  CurrenciesDataStoreTests.swift
//  CurrencyConverterTests
//
//  Created by Sevar Jafarli on 15.07.26.
//

import Testing
import Foundation
@testable import CurrencyConverter

struct CurrenciesDataStoreTests {
    private func makeStore(maxAge: TimeInterval = 3600) -> CurrenciesDataStore {
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString + ".json")
        return CurrenciesDataStore(fileURL: url, maxAge: maxAge)
    }
    @Test func saveThenLoad_returnsSameCurrencies() async throws {
        let store = makeStore()
        
        let currencies: [Currency] = [
            .init(code: "AED", name: "United Arab Emirates Dirham", symbol: "د.إ"),
            .init(code: "AFN", name: "Afghan Afghani", symbol: "؋")
        ]
        await store.save(currencies)
        
        let result = await store.load()
        
        #expect(currencies == result)
    }
    
    @Test func load_noFile_returnsNil() async throws {
        let store = makeStore()
        
        let result = await store.load()
        
        #expect(result == nil)
    }
    
    
    @Test func load_expiredTTL_returnsNil() async throws {
        let store = makeStore(maxAge: -1)
        let currencies: [Currency] = [
            .init(code: "AED", name: "United Arab Emirates Dirham", symbol: "د.إ"),
            .init(code: "AFN", name: "Afghan Afghani", symbol: "؋")
        ]
        await store.save(currencies)
        
        let result = await store.load()
        
        #expect(result == nil)
    }
}
