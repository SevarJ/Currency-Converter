//
//  DateUtils.swift
//  CurrencyConverter
//
//  Created by Sevar Jafarli on 15.07.26.
//

import Foundation

struct DateUtils {
    static let dateFormatter : DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
}
