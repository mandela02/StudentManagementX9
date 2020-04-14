//
//  DateFormatterHelper.swift
//  FinancialManagementX9000
//
//  Created by TriBQ on 9/30/19.
//  Copyright © 2019 Tribq. All rights reserved.
//

import Foundation

class DateFormatterHelper {
    static private let dateFormatter = { () -> DateFormatter in
        let dateFormatter = DateFormatter(with: "d/M/y")
        return dateFormatter
    }()

    static func date(from string: String?) -> Date? {
        guard let string = string else { return nil }
        return dateFormatter.date(from: string)
    }
}
