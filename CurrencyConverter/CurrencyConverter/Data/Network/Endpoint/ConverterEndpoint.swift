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
    case history(base: String, quote: String, from: Date, to: Date?, group: String?)
    
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
            
        case let .history(base, quote, from, to, group):
            urlComponents.path = "/v2/rates"
            urlComponents.queryItems = [
                URLQueryItem(name: "base", value: base),
                URLQueryItem(name: "quotes", value: quote),
                URLQueryItem(name: "from", value: DateUtils.dateFormatter.string(from: from))
            ]
            
            if let to {
                urlComponents.queryItems?.append(URLQueryItem(
                    name: "to",
                    value: DateUtils.dateFormatter.string(from: to))
                )
            }
            
            if let group {
                urlComponents.queryItems?.append(
                    URLQueryItem(
                        name: "group",
                        value: group
                    )
                )
            }
        }
        
        return urlComponents.url
    }
    
    
    
    
}
