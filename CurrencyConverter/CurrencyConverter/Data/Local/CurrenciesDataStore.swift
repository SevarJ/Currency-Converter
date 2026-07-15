//
//  CurrenciesDataStore.swift
//  CurrencyConverter
//
//  Created by Sevar Jafarli on 15.07.26.
//

import Foundation

final class CurrenciesDataStore: CurrenciesStoreProtocol {
    private let fileURL: URL
    
    private let maxAge: TimeInterval
    
    init(
        fileURL: URL =
        FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0].appendingPathComponent("currencies.json"),
        maxAge: TimeInterval  = 30 * 24 * 60 * 60  // 30 days in seconds)
    ) {
        self.fileURL = fileURL
        self.maxAge = maxAge
    }
    
    func load() -> [Currency]? {
        guard let data = try? Data(contentsOf: fileURL) else { return nil }
        
        guard let dto = try? JSONDecoder().decode(CachedCurrenciesDTO.self, from: data) else { return nil }
        
        let age = Date().timeIntervalSince(dto.savedAt)
        guard abs(age) < maxAge else {
            return nil
        }
        
        return dto.currencies.map { Currency(code: $0.code, name: $0.name, symbol: $0.symbol )}
    }
    
    func save(_ currencies: [Currency]) {
        let dto = CachedCurrenciesDTO(
            savedAt: Date(),
            currencies: currencies.map {
                CachedCurrenciesDTO.CachedCurrency(
                    code: $0.code,
                    name: $0.name,
                    symbol: $0.symbol
                )
            }
        )
        
        guard let data = try? JSONEncoder().encode(dto) else { return }
        
        try? data.write(to: fileURL, options: .atomic)
    }
}
