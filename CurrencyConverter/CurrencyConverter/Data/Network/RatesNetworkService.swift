//
//  RatesNetworkService.swift
//  CurrencyConverter
//
//  Created by Sevar Jafarli on 11.06.26.
//

import Foundation

protocol RatesNetworkServiceProtocol {
    func fetchRates(for date: Date) async throws -> ExchangeRate
}

final class RatesNetworkService: RatesNetworkServiceProtocol {
    
    private let session: URLSession
    private let parser: RatesXMLParserProtocol
    
    init(
        session: URLSession = .shared,
        parser: RatesXMLParserProtocol = RatesXMLParser()
    ) {
        self.session = session
        self.parser = parser
    }
    
    func fetchRates(for date: Date) async throws -> ExchangeRate {
           let url = try makeURL(for: date)
           
           let (data, response) = try await session.data(from: url)
           
           guard let httpResponse = response as? HTTPURLResponse,
                 httpResponse.statusCode == 200 else {
               throw RatesError.networkUnavailable
           }
           
           return try parser.parse(data: data, date: date)
       }
       
       private func makeURL(for date: Date) throws -> URL {
           let formatter = DateFormatter()
           formatter.dateFormat = "dd.MM.yyyy"
           let dateString = formatter.string(from: date)
           
           guard let url = URL(string: "https://cbar.az/currencies/\(dateString).xml") else {
               throw RatesError.networkUnavailable
           }
           
           return url
       }
}
