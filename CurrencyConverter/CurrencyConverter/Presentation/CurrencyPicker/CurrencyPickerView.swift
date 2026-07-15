//
//  CurrencyPickerView.swift
//  CurrencyConverter
//
//  Created by Sevar Jafarli on 15.07.26.
//

import SwiftUI

struct CurrencyPickerView: View {
    let currencies: [Currency]
    @Binding var selection: Currency?
    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""
    
    var filteredCurrencies: [Currency] {
        guard !searchText.isEmpty else { return currencies }
        return currencies.filter { $0.code.localizedCaseInsensitiveContains(searchText) || $0.name.localizedCaseInsensitiveContains(searchText) }
    }
    
    var body: some View {
        NavigationStack {
            List(filteredCurrencies) { currency in
                Button {
                  selection = currency
                    dismiss()
                } label: {
                    HStack(spacing: 12) {
                        Text(currency.symbol)
                            .font(.control)
                            .frame(width: 44, height: 44)
                            .background(Circle().fill(Color(.systemGray6)))
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(currency.code).font(.control)
                            Text(currency.name)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        
                        Spacer()
                        
                        if currency == selection {
                            Image(systemName: "checkmark")
                                .foregroundStyle(.tint)
                        }
                    }
                }
                .foregroundStyle(.primary)
                
            }
            .overlay(content: {
                if filteredCurrencies.isEmpty {
                    ContentUnavailableView.search(text: searchText)
                }
            })
            .listStyle(.plain)
            .searchable(text: $searchText, prompt: "Search")
            .navigationTitle("Currencies")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundStyle(.foreground)
                    }
                }
            }
        }
    }
}
