//
//  CurrencyWidget.swift
//  CurrencyWidget
//
//  Created by Sevar Jafarli on 16.07.26.
//

import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry.placeholder
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        completion( SimpleEntry.placeholder)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<SimpleEntry>) -> ()) {
        Task {
            do {
                let service = ConverterNetworkService()
                let dto: RateDTO = try await service.fetch(.rate(base: "USD", quote: "EUR"))
                let rate = try dto.toDomain()
                
                let entry = SimpleEntry(
                    date: rate.date,
                    base: rate.base,
                    quote: rate.quote,
                    rate: rate.rate
                )
                let timeline = Timeline(
                    entries: [entry],
                    policy: .after(Date().addingTimeInterval(4 * 60 * 60))
                )
                completion(timeline)
            } catch {
                let timeline = Timeline(
                    entries: [SimpleEntry.placeholder],
                    policy:  .after(Date().addingTimeInterval(30 * 60))
                )
                completion(timeline)
            }
        }
    }

//    func relevances() async -> WidgetRelevances<Void> {
//        // Generate a list containing the contexts this widget is relevant in.
//    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let base: String
    let quote: String
    let rate: Decimal
}

extension SimpleEntry {
    static let placeholder = SimpleEntry(date: .now, base: "USD", quote: "EUR", rate: 0.8741)
}

struct CurrencyWidgetEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        VStack(spacing: 6) {
            Text(entry.date, style: .date)
                .foregroundStyle(.secondary)
                .font(.headline)
            Text("\(entry.base) → \(entry.quote)")
                .font(.title2)
                .bold()
            Text(entry.rate.formatted(.number.precision(.fractionLength(0...4))))
                .font(.headline)
        }
    }
}

struct CurrencyWidget: Widget {
    let kind: String = "CurrencyWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            CurrencyWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Exchange Rate")
        .description("Shows the latest USD → EUR rate.")
    }
}

#Preview(as: .systemSmall) {
    CurrencyWidget()
} timeline: {
    SimpleEntry.placeholder
    SimpleEntry.placeholder
}
