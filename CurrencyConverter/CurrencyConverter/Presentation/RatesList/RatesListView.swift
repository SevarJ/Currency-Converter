//
//  RatesListView.swift
//  CurrencyConverter
//
//  Created by Sevar Jafarli on 15.07.26.
//

import SwiftUI

struct RatesListView: View {
    @State private var viewModel = RatesListViewModel()
    @State private var showCurrencies = false
    
    var body: some View {
        NavigationStack {
            List(viewModel.rates, id: \.quote) { rate in
                if let currency = viewModel.currenciesByCode[rate.quote] {
                    NavigationLink {
                        if let baseCurrency = viewModel.baseCurrency {
                            RateHistoryView(base: baseCurrency, quote: currency)
                        }
                    } label: {
                        CurrencyRowView(currency: currency) {
                            VStack(alignment: .trailing, spacing: 2) {
                                Text(rate.rate.formatted(.number.precision(.fractionLength(0...4))))
                                Text(rate.date.formatted(.dateTime.day().month()))
                                    .font(.caption).foregroundStyle(.secondary)
                            }
                        }
                    }
                }
            }
            .listStyle(.plain)
            .navigationTitle("Rates")
            .toolbar {
                ToolbarItem(placement: .principal) {
                    CurrencyButton(currency: viewModel.baseCurrency) {
                        showCurrencies = true
                    }
                }
            }
            .overlay {
                if viewModel.isLoading { ProgressView() }
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundStyle(.red)
                }
            }
        }
        .task {
            await viewModel.load()
        }
        .sheet(isPresented: $showCurrencies) {
            CurrencyPickerView(
                currencies: viewModel.allCurrencies,
                selection: $viewModel.baseCurrency
            )
        }
    }
}
