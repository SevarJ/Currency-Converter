//
//  ConverterEndpoint.swift
//  CurrencyConverter
//
//  Created by Sevar Jafarli on 15.07.26.
//

import Foundation

enum ConverterEndpoint {
    case currencies
    case rate(base: String, quote: String)
    case rates(base: String, quotes: [String])
    
    var url: URL? {
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = "api.frankfurter.dev"
        
        switch self {
        case .currencies:
            urlComponents.path = "/v2/currencies"
        case .rate(let base, let quote):
            urlComponents.path = "/v2/rate/\(base)/\(quote)"
        case .rates(let base, let quotes):
            urlComponents.path = "/v2/rates"
            
            urlComponents.queryItems = [
                URLQueryItem(name: "base", value: base),
            ]
            
            if !quotes.isEmpty {
                urlComponents.queryItems?.append(URLQueryItem(name: "quotes", value: quotes.joined(separator: ",")))
            }
        }
        
        return urlComponents.url
    }
    
    
    
    
}
