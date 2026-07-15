//
//  CurrencyButton.swift
//  CurrencyConverter
//
//  Created by Sevar Jafarli on 15.07.26.
//

import SwiftUI

struct CurrencyButton: View {
    let currency: Currency?
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(currency.map { "\($0.symbol) \($0.code)" } ?? "Choose")
                .font(.headline)
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(Capsule().fill(Color(.systemGray6)))
        }
        .foregroundStyle(.primary)
    }
}
