//
//  ContentView.swift
//  CurrencyConverter
//
//  Created by Sevar Jafarli on 10.06.26.
//

import SwiftUI

struct ContentView: View {
    @Environment(AppDependencies.self) private var dependencies
    var body: some View {
        TabView {
            ConverterView(repository: dependencies.repository)
                .tabItem {
                    Label("Converter", systemImage: "arrow.left.arrow.right")
                }
            
            RatesListView(repository: dependencies.repository)
                .tabItem {
                    Label("Rates", systemImage: "list.bullet")
                }
        }
    }
}
