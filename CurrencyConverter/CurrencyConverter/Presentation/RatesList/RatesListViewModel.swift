//
//  RatesListViewModel.swift
//  CurrencyConverter
//
//  Created by Sevar Jafarli on 15.07.26.
//

import Observation
import Foundation

@MainActor
@Observable
final class RatesListViewModel {
    private let repository: ConverterRepositoryProtocol
    private(set) var allCurrencies: [Currency] = []
    private(set) var rates: [Rate] = []
    private(set) var errorMessage: String? = nil
    private(set) var isLoading: Bool = false
    private(set) var currenciesByCode: [String: Currency] = [:]
    
    var baseCurrency: Currency? {
        didSet {
            guard oldValue != baseCurrency else { return }
            Task { await loadRates() }
        }
    }
    
    init(
        repository: ConverterRepositoryProtocol = ConverterRepository()
    ) {
        self.repository = repository
    }
    
    func load() async {
        isLoading = true
        errorMessage = nil
        
        defer {
            isLoading = false
        }
        
        do {
            allCurrencies = try await repository.currencies()
            baseCurrency = allCurrencies.first(where: { $0.code == "USD" })
            
            currenciesByCode = Dictionary(uniqueKeysWithValues: allCurrencies.map { ($0.code, $0) })
        }
        catch let NetworkError.apiError(message) {
            errorMessage = message
        }
        catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func loadRates() async {
        isLoading = true
        errorMessage = nil
        
        defer {
            isLoading = false
        }
        
        if let base = baseCurrency?.code {
            do {
                rates = try await repository.rates(base: base, quotes: [])
            }
            catch let NetworkError.apiError(message) {
                errorMessage = message
            }
            catch {
                errorMessage = error.localizedDescription
            }
        }
        
    }
    
}
