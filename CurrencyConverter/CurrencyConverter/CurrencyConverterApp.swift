//
//  CurrencyConverterApp.swift
//  CurrencyConverter
//
//  Created by Sevar Jafarli on 10.06.26.
//

import SwiftUI

@main
struct CurrencyConverterApp: App {
    @State private var dependencies = AppDependencies()
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(dependencies)
        }
    }
}
