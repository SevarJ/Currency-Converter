//
//  NetworkError.swift
//  CurrencyConverter
//
//  Created by Sevar Jafarli on 11.06.26.
//

enum NetworkError: Error {
    case invalidURL
    case networkUnavailable
    case cacheEmpty
    case decodingFailed
    case apiError(_ message: String)
}
