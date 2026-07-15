//
//  ConverterViewModel.swift
//  CurrencyConverter
//
//  Created by Sevar Jafarli on 15.07.26.
//

import Foundation

@MainActor
@Observable
final class ConverterViewModel {
    
    var amount: String = ""
    
    var baseCurrency: Currency?
    var quoteCurrency: Currency?
    
    private(set) var allCurrencies: [Currency] = []
    private(set) var result: Decimal?
    private(set) var isLoading = false
    private(set) var errorMessage: String?
    private var lastRate: Rate?
    
    private let repository: ConverterRepositoryProtocol
    
    init(
        repository: ConverterRepositoryProtocol = ConverterRepository()
    ) {
        self.repository = repository
    }
    
    func loadCurrencies() async {
        isLoading = true
        errorMessage = nil
        defer {
            isLoading = false
        }
        
        do {
            allCurrencies = try await repository.currencies()
            baseCurrency = allCurrencies.first { $0.code == "USD" }
            quoteCurrency = allCurrencies.first { $0.code == "AZN" }
        }
        catch let NetworkError.apiError(message) {
            errorMessage = message
        }
        catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func convert() async {
        errorMessage = nil
        isLoading = true
        defer { isLoading = false }
        
        guard let input = Decimal(string: amount.replacingOccurrences(of: ",", with: ".")) else {
            errorMessage = "Input error"
            return
        }
        
        guard let baseCurrency, let quoteCurrency else {
            errorMessage = "Add proper currency"
            return
        }
        
        do {
            let rate = try await repository.rate(base: baseCurrency.code, quote: quoteCurrency.code)
            result = input * rate.rate
            lastRate = rate
        }
        catch let NetworkError.apiError(message) {
            errorMessage = message
        }
        catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func swap() {
        let temp = baseCurrency
        baseCurrency = quoteCurrency
        quoteCurrency = temp
        
        guard let lastRate, let input = Decimal(string: amount.replacingOccurrences(of: ",", with: ".")) else {
            result = nil
            return
        }
        
        let inverted = Rate(
            date: lastRate.date,
            base: lastRate.quote,
            quote: lastRate.base,
            rate: 1 / lastRate.rate
        )
        self.lastRate = inverted
        result = input * inverted.rate
    }
}
