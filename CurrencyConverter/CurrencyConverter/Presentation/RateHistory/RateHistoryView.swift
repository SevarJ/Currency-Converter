//
//  RateHistoryView.swift
//  CurrencyConverter
//
//  Created by Sevar Jafarli on 16.07.26.
//

import SwiftUI
import Charts

struct RateHistoryView: View {
    @State private var viewModel: RateHistoryViewModel
    @State private var selectedDate: Date?
    
    init(base: Currency, quote: Currency) {
        _viewModel = .init(initialValue: .init(base: base, quote: quote))
    }
    
    // MARK: - Bindings
    
    private var fromBinding: Binding<Date> {
        Binding(
            get: { viewModel.range.lowerBound },
            set: { viewModel.range = min($0, viewModel.range.upperBound)...viewModel.range.upperBound }
        )
    }
    
    private var toBinding: Binding<Date> {
        Binding(
            get: { viewModel.range.upperBound },
            set: { viewModel.range = viewModel.range.lowerBound...max($0, viewModel.range.lowerBound) }
        )
    }
    
    // MARK: - Chart helpers
    
    private var yDomain: ClosedRange<Double> {
        let values = viewModel.rates.map(\.rateAsDouble)
        
        guard let minV = values.min(), let maxV = values.max() else {
            return 0...1
        }
        guard minV < maxV else {
            let pad = Swift.max(minV * 0.01, 0.0001)
            return (minV - pad)...(maxV + pad)
        }
        let padding = (maxV - minV) * 0.1
        return (minV - padding)...(maxV + padding)
    }
    
    private var selectedRate: Rate? {
        guard let selectedDate else { return nil }
        return viewModel.rates.min(by: {
            abs($0.date.timeIntervalSince(selectedDate)) < abs($1.date.timeIntervalSince(selectedDate))
        })
    }
    
    private var displayedRate: Rate? {
        selectedRate ?? viewModel.latestRate
    }
    
    var body: some View {
        VStack(spacing: 16) {
            header
            chart
            presets
            datePickers
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 24)
        .navigationTitle("\(viewModel.base.code) → \(viewModel.quote.code)")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await viewModel.load()
        }
    }
    
    // MARK: - Subviews
    
    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(displayedRate.map {
                $0.rate.formatted(.number.precision(.fractionLength(0...4)))
            } ?? "—")
            .font(.resultText)
            .contentTransition(.numericText())
            
            HStack(spacing: 8) {
                Text(displayedRate.map {
                    $0.date.formatted(.dateTime.day().month().year())
                } ?? "")
                
                if selectedRate == nil, let change = viewModel.changePercent {
                    Text("\(change >= 0 ? "+" : "")\(change, specifier: "%.2f")%")
                        .foregroundStyle(change > 0 ? .green : (change < 0 ? .red : .secondary))
                }
            }
            .font(.caption)
            .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .animation(.default, value: selectedDate)
    }
    
    private var chart: some View {
        Group {
            if viewModel.isLoading && viewModel.rates.isEmpty {
                ProgressView()
                    .frame(maxWidth: .infinity)
            } else if let errorMessage = viewModel.errorMessage {
                ContentUnavailableView {
                    Label("No data", systemImage: "chart.line.downtrend.xyaxis")
                } description: {
                    Text(errorMessage)
                } actions: {
                    Button("Retry") {
                        Task { await viewModel.load() }
                    }
                    .buttonStyle(.bordered)
                }
            } else {
                chartContent
                    .opacity(viewModel.isLoading ? 0.4 : 1)
            }
        }
        .frame(
            maxWidth: .infinity,
            minHeight: 260,
            maxHeight: .infinity
        )
        .animation(.default, value: viewModel.isLoading)
    }
    
    private var chartContent: some View {
        Chart(viewModel.rates, id: \.date) { rate in
            AreaMark(
                x: .value("Date", rate.date),
                yStart: .value("Base", yDomain.lowerBound),
                yEnd: .value("Rate", rate.rateAsDouble)
            )
            .interpolationMethod(.catmullRom)
            .foregroundStyle(
                LinearGradient(
                    colors: [.accentColor.opacity(0.25), .accentColor.opacity(0.02)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            
            LineMark(
                x: .value("Date", rate.date),
                y: .value("Rate", rate.rateAsDouble)
            )
            .interpolationMethod(.catmullRom)
            .lineStyle(StrokeStyle(lineWidth: 2.5))
            .foregroundStyle(.tint)
            
            if let selectedRate {
                RuleMark(x: .value("Selected", selectedRate.date))
                    .foregroundStyle(.gray.opacity(0.4))
                    .lineStyle(StrokeStyle(lineWidth: 1))
                
                PointMark(
                    x: .value("Selected", selectedRate.date),
                    y: .value("Rate", selectedRate.rateAsDouble)
                )
                .foregroundStyle(.tint)
                .symbolSize(80)
            }
        }
        .chartYScale(domain: yDomain)
        .chartXSelection(value: $selectedDate)
    }
    
    private var presets: some View {
        HStack(spacing: 12) {
            presetButton("1M", months: -1)
            presetButton("3M", months: -3)
            presetButton("1Y", months: -12)
        }
    }
    
    private func presetButton(_ title: String, months: Int) -> some View {
        Button(title) {
            let from = Calendar.current.date(byAdding: .month, value: months, to: .now)!
            viewModel.range = from...Date()
        }
        .tint(.primary)
        .buttonStyle(.bordered)
    }
    
    private var datePickers: some View {
        HStack(spacing: 12) {
            labeledDatePicker("From", selection: fromBinding)
            labeledDatePicker("To", selection: toBinding)
        }
    }
    
    private func labeledDatePicker(_ title: String, selection: Binding<Date>) -> some View {
        HStack(spacing: 6) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            
            DatePicker("", selection: selection, in: ...Date(), displayedComponents: .date)
                .labelsHidden()
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }
}
