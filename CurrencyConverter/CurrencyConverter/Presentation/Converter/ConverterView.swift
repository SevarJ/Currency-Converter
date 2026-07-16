//
//  ConverterView.swift
//  CurrencyConverter
//
//  Created by Sevar Jafarli on 15.07.26.
//

import SwiftUI

enum PickerTarget: Identifiable {
    case base, quote
    var id: Self { self }
}

struct ConverterView: View {
    @State private var viewModel: ConverterViewModel
    @State private var pickerTarget: PickerTarget?
    @FocusState private var amountFocused: Bool
    
    init(
        repository: ConverterRepositoryProtocol
    ) {
        self.viewModel = ConverterViewModel(
            repository: repository
        )
    }
    
    var body: some View {
        VStack(spacing: 28) {
            Spacer()
            HStack(spacing: 8) {
                Text(viewModel.baseCurrency?.symbol ?? "")
                    .font(.amountSymbol)
                
                TextField("1", text: $viewModel.amount)
                    .keyboardType(.decimalPad)
                    .font(.amountInput)
                    .multilineTextAlignment(.center)
                    .focused($amountFocused)
                    .fixedSize()
            }
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
            .onTapGesture { amountFocused = true }
            HStack(spacing: 16) {
                CurrencyButton(currency: viewModel.baseCurrency) {
                    pickerTarget = .base
                }
                
                Button {
                    viewModel.swap()
                } label: {
                    Image(systemName: "arrow.left.arrow.right")
                        .foregroundStyle(.gray)
                        .font(.headline)
                        .padding(12)
                }
                .buttonStyle(.bordered)
                .clipShape(Circle())
                
                CurrencyButton(currency: viewModel.quoteCurrency) {
                    pickerTarget = .quote
                }
            }
            
            ZStack {
                if viewModel.isLoading {
                    ProgressView()
                } else if let result = viewModel.result,
                          let quote = viewModel.quoteCurrency {
                    Text("\(result.formatted(.number.precision(.fractionLength(0...4)))) \(quote.symbol)")
                        .font(.resultText)
                        .contentTransition(.numericText())
                }
            }
            .frame(minHeight: 50)
            
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .font(.caption)
                    .foregroundStyle(.red)
            }
            
            Spacer()
            Spacer()
        }
        .padding(.horizontal, 16)
        .task {
            await viewModel.loadCurrencies()
        }
        .sheet(item: $pickerTarget) { target in
            CurrencyPickerView(
                currencies: viewModel.allCurrencies,
                selection: target == .base
                ? $viewModel.baseCurrency
                : $viewModel.quoteCurrency
            )
        }
        .contentShape(Rectangle())
        .onTapGesture {
            amountFocused = false
        }
    }
}
