//
//  StringHelper.swift
//  FinancialManagementX9000
//
//  Created by TriBQ on 9/11/19.
//  Copyright © 2019 Tribq. All rights reserved.
//

import Foundation

class StringHelper {
    static func getDayOfWeekString(from date: Date) -> String {
        let dateFormatter = DateFormatter(with: "dd/MM/yyyy (E)")
        return dateFormatter.string(from: date)
    }

    static func getMonthDayYearString(from date: Date) -> String {
        let dateFormatter = DateFormatter(with: "dd/MM/yyyy")
        return dateFormatter.string(from: date)
    }

    static func getMonthYearString(from date: Date) -> String {
        let dateFormatter = DateFormatter(with: "MM/yyyy")
        return dateFormatter.string(from: date)
    }

    static func getFullDateString(from date: Date) -> String {
        let dateFormatter = DateFormatter(with: "dd-MM-yyyy HH:mm:ss")
        return dateFormatter.string(from: date)
    }

    static func isValidEmail(input: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: input)
    }

    static func getFullMonthString(from date: Date) -> String {
        return StringHelper.getMonthYearString(from: date)
            + " ("
            + StringHelper.getMonthDayYearString(from: date.startOfMonth())
            + " - "
            + StringHelper.getMonthDayYearString(from: date.endOfMonth())
            + ")"
    }

    static func getMonthString(_ month: Int) -> String {
        switch Settings.appLanguage.value {
        case LanguageCode.vietnamese.rawValue:
            return "Tháng \(month)"
        default:
            let englishMonths = ["January",
                                 "February",
                                 "March", "April",
                                 "May",
                                 "June",
                                 "July",
                                 "August",
                                 "September",
                                 "October",
                                 "November",
                                 "December"]
            guard month <= englishMonths.count && month >= 1 else { return "\(month)" }
            let monthFullString = englishMonths[month - 1]
            return monthFullString
        }
    }
    static func createDocumentId(from date: Date) -> String {
        let dateFormatter = DateFormatter(with: "ddMMyyyyHHmmss")
        return dateFormatter.string(from: date)
    }
}
