//
//  ContentView.swift
//  CurrencyConverter
//
//  Created by Sevar Jafarli on 10.06.26.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            ConverterView()
                .tabItem {
                    Label("Converter", systemImage: "arrow.left.arrow.right")
                }
            
            RatesListView()
                .tabItem {
                    Label("Rates", systemImage: "list.bullet")
                }
        }
    }
}
