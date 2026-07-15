//
//  CurrencyRowView.swift
//  CurrencyConverter
//
//  Created by Sevar Jafarli on 15.07.26.
//

import SwiftUI

struct CurrencyRowView<Trailing: View>: View {
    let currency: Currency
    @ViewBuilder let trailing: () -> Trailing

    var body: some View {
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

            trailing()
        }
    }
}
