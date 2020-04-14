//
//  DateFormatter+Extension.swift
//  FinancialManagementX9000
//
//  Created by TriBQ on 9/13/19.
//  Copyright © 2019 Tribq. All rights reserved.
//

import Foundation

extension DateFormatter {
    convenience init(with dateFormat: String) {
        self.init()
        self.dateFormat = dateFormat
        self.timeZone = TimeZone.current
        self.locale = Locale(identifier: Strings.localeIdentifier)
    }
}
