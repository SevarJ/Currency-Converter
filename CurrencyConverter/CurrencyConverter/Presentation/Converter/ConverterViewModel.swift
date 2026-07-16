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

    var amount: String = "1" {
        didSet { recompute() }
    }

    var baseCurrency: Currency? {
        didSet {
            guard !suppressRateReload, oldValue != baseCurrency else { return }
            lastRate = nil
            result = nil
            Task { await loadRate() }
        }
    }

    var quoteCurrency: Currency? {
        didSet {
            guard !suppressRateReload, oldValue != quoteCurrency else { return }
            lastRate = nil
            result = nil
            Task { await loadRate() }
        }
    }

    private(set) var allCurrencies: [Currency] = []
    private(set) var result: Decimal?
    private(set) var isLoading = false
    private(set) var errorMessage: String?

    private var lastRate: Rate?
    private var suppressRateReload = false

    private let repository: ConverterRepositoryProtocol

    init(repository: ConverterRepositoryProtocol) {
        self.repository = repository
    }

    func loadCurrencies() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            allCurrencies = try await repository.currencies()

            suppressRateReload = true
            baseCurrency = allCurrencies.first { $0.code == "USD" }
            quoteCurrency = allCurrencies.first { $0.code == "AZN" }
            suppressRateReload = false

            await loadRate()
        } catch let NetworkError.apiError(message) {
            errorMessage = message
        } catch {
            errorMessage = "Failed to load currencies"
        }
    }

    func loadRate() async {
        guard let baseCurrency, let quoteCurrency else { return }

        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            lastRate = try await repository.rate(
                base: baseCurrency.code,
                quote: quoteCurrency.code
            )
            recompute()
        } catch let NetworkError.apiError(message) {
            errorMessage = message
        } catch {
            errorMessage = "Failed to load rate"
        }
    }

    func swap() {
        suppressRateReload = true
        let temp = baseCurrency
        baseCurrency = quoteCurrency
        quoteCurrency = temp
        suppressRateReload = false

        if let lastRate {
            self.lastRate = Rate(
                date: lastRate.date,
                base: lastRate.quote,
                quote: lastRate.base,
                rate: 1 / lastRate.rate
            )
            recompute()
        } else {
            Task { await loadRate() }
        }
    }

    private func recompute() {
        guard let lastRate else {
            result = nil
            return
        }

        let normalized = amount.replacingOccurrences(of: ",", with: ".")

        let input: Decimal
        if normalized.isEmpty {
            input = 1
        } else if let parsed = Decimal(string: normalized) {
            input = parsed
        } else {
            result = nil
            return
        }

        result = input * lastRate.rate
    }
}
