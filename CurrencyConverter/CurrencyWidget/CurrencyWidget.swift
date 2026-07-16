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
        SimpleEntry(date: Date(), base: "USD", quote: "EUR", rate: 0.8741)
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), base: "USD", quote: "EUR", rate: 0.8741)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let entry = SimpleEntry(date: Date(), base: "USD", quote: "AZN", rate: 1.6996)
        let timeline = Timeline(
            entries: [entry],
            policy: .after(Date().addingTimeInterval(4 * 60 * 60))
        )
        completion(timeline)
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

struct CurrencyWidgetEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        VStack {
            Text(entry.date, style: .date)
                .foregroundStyle(.placeholder)
                .font(.headline)
            Spacer()
            Text("\(entry.base) -> \(entry.quote)")
                .font(.title2)
                .bold()
            Spacer()
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
    SimpleEntry(date: Date(), base: "USD", quote: "EUR", rate: 0.8741)
    SimpleEntry(date: Date(), base: "USD", quote: "EUR", rate: 0.8741)
}
