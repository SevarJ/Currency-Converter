//
//  ConverterRepositoryTests.swift
//  CurrencyConverter
//
//  Created by Sevar Jafarli on 15.07.26.
//

@testable import CurrencyConverter
import Foundation
import Testing

@MainActor
struct ConverterRepositoryTests {
    private func makeSUT(maxAge: TimeInterval = 3600)
    -> (repo: ConverterRepository, network: MockNetworkService, store: CurrenciesDataStore) {
        let network = MockNetworkService()
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString + ".json")
        let store = CurrenciesDataStore(fileURL: url, maxAge: maxAge)
        let repo = ConverterRepository(networkService: network, currenciesStore: store)
        return (repo, network, store)
    }
    
    @Test func currencies_freshCache_skipsNetwork() async throws {
        let (repo, network, store) = makeSUT()
        
        let cached = [Currency(code: "USD", name: "US Dollar", symbol: "$")]
        store.save(cached)
        
        let result = try await repo.currencies()
        
        #expect(result == cached)
        #expect(network.fetchCallCount == 0)
    }
    
    @Test func currencies_noCache_network_success() async throws {
        let (repo, network, store) = makeSUT()
        
        network.result = .success(
            [CurrencyDTO(
                isoCode: "USD",
                name: "US Dollar",
                symbol: "$"
            )]
        )
        let result = try await repo.currencies()

        #expect(result == [Currency(code: "USD", name: "US Dollar", symbol: "$")])
        #expect(network.fetchCallCount == 1)
        #expect(store.load(ignoringTTL: false) != nil)    // repo keşə yazdı
    }
    
    @Test func currencies_returnCached_network_fail() async throws {
        let (repo, network, store) = makeSUT(maxAge: -1)
        
        let cached = [Currency(code: "USD", name: "US Dollar", symbol: "$")]
        store.save(cached)
        
        network.result = .failure(NetworkError.networkUnavailable)
        
        let result = try await repo.currencies()
        
        #expect(result == cached)
    }
    
    @Test func currencies_noCache_network_fail() async throws {
        let (repo, network, _) = makeSUT()
        network.result = .failure(NetworkError.networkUnavailable)
        
        await #expect(throws: NetworkError.self) {
            try await repo.currencies()
        }
    }
    
    @Test func history_twoYearRange_usesMonthGrouping() async throws {
        let (repo, network, _) = makeSUT()
        
        network.result = .success([RateDTO]())
        
        let from = Calendar.current.date(byAdding: .year, value: -2, to: Date())!
        
        _ = try await repo.history(base: "USD", quote: "EUR", from: from, to: nil)
        
        guard case let .history(_, _, _, _, group) = network.lastEndpoint else {
            Issue.record("History endpoint is not called")
            return
        }
        
        #expect(group == "month")
    }
}
