//
//  NetworkServiceProtocol.swift
//  CurrencyConverter
//
//  Created by Sevar Jafarli on 15.07.26.
//

protocol NetworkServiceProtocol {
    func fetch<T: Decodable>(_ endpoint: ConverterEndpoint) async throws -> T
}
