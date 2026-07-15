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
                    CurrencyRowView(currency: currency) {
                        
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
