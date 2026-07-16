//
//  RateHistoryViewModel.swift
//  CurrencyConverter
//
//  Created by Sevar Jafarli on 16.07.26.
//

import Foundation
import Observation

@MainActor
@Observable
final class RateHistoryViewModel {
    let base: Currency
    let quote: Currency
    
    var range: ClosedRange<Date> {
        didSet {
            Task {
                await load()
            }
        }
    }
    
    private let repository: ConverterRepositoryProtocol
    
    private(set) var rates: [Rate] = []
    private(set) var isLoading = false
    private(set) var errorMessage: String?

    var latestRate: Rate? { rates.last }

    var changePercent: Double? {
        guard let first = rates.first?.rateAsDouble,
              let last = rates.last?.rateAsDouble,
              first != 0 else { return nil }
        return (last - first) / first * 100
    }

    init(
        base: Currency,
        quote: Currency,
        repository: ConverterRepositoryProtocol
    ) {
        self.base = base
        self.quote = quote
        self.repository = repository
        
        let defaultStartDate =  Calendar.current.date(byAdding: .month, value: -1, to: Date())!
        self.range = defaultStartDate...Date()
    }
    
    func load() async {
        isLoading = true
        errorMessage = nil
        
        defer {
            isLoading = false
        }
        do {
         rates = try await repository.history(
                base: base.code,
                quote: quote.code,
                from: range.lowerBound,
                to: range.upperBound
            )
        }
        catch let NetworkError.apiError(message) {
           errorMessage = message
       } catch {
           errorMessage = "Failed to load rates"
       }
    }
}
