//
//  AppDependencies.swift
//  CurrencyConverter
//
//  Created by Sevar Jafarli on 16.07.26.
//

import Observation

@MainActor
@Observable
final class AppDependencies {
    let repository: ConverterRepositoryProtocol
    
    init() {
        let networkService: NetworkServiceProtocol = ConverterNetworkService()
        let currenciesStore: CurrenciesStoreProtocol = CurrenciesDataStore()
        
        self.repository = ConverterRepository(
            networkService: networkService,
            currenciesStore: currenciesStore
        )
    }
}
