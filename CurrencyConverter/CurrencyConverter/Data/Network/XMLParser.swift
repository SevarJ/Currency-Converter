//
//  XMLParser.swift
//  CurrencyConverter
//
//  Created by Sevar Jafarli on 11.06.26.
//

import Foundation

protocol RatesXMLParserProtocol {
    func parse(data: Data, date: Date) throws -> ExchangeRate
}

final class RatesXMLParser: NSObject, RatesXMLParserProtocol {
    
    private var currencies: [Currency] = []
    private var currentCode: String = ""
    private var currentName: String = ""
    private var currentNominal: Int = 1
    private var currentValue: String = ""
    private var currentElement: String = ""
    private var parseDate: Date = Date()
    
    func parse(data: Data, date: Date) throws -> ExchangeRate {
        currencies = []
        parseDate = date
        
        let xmlParser = XMLParser(data: data)
        xmlParser.delegate = self
        
        guard xmlParser.parse() else {
            throw RatesError.parsingFailed
        }
        
        guard !currencies.isEmpty else {
            throw RatesError.parsingFailed
        }
        
        return ExchangeRate(date: date, currencies: currencies)
    }
}

// MARK: - XMLParserDelegate

extension RatesXMLParser: XMLParserDelegate {
    
    func parser(
        _ parser: XMLParser,
        didStartElement elementName: String,
        namespaceURI: String?,
        qualifiedName qName: String?,
        attributes attributeDict: [String: String] = [:]
    ) {
        currentElement = elementName
        
        if elementName == "Valute" {
            currentCode = attributeDict["Code"] ?? ""
            currentName = ""
            currentNominal = 1
            currentValue = ""
        }
    }
    
    func parser(
        _ parser: XMLParser,
        foundCharacters string: String
    ) {
        let trimmed = string.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        
        switch currentElement {
        case "Name":    currentName = trimmed
        case "Nominal": currentNominal = Int(trimmed) ?? 1
        case "Value":   currentValue = trimmed
        default:        break
        }
    }
    
    func parser(
        _ parser: XMLParser,
        didEndElement elementName: String,
        namespaceURI: String?,
        qualifiedName qName: String?
    ) {
        guard elementName == "Valute",
              !currentCode.isEmpty,
              let rate = Decimal(string: currentValue) else { return }
        
        let currency = Currency(
            code: currentCode,
            name: currentName,
            nominal: currentNominal,
            rate: rate,
            date: parseDate
        )
        
        currencies.append(currency)
    }
}
