//
//  DateHelper.swift
//  FinancialManagementX9000
//
//  Created by TriBQ on 9/13/19.
//  Copyright © 2019 Tribq. All rights reserved.
//

import Foundation
import FirebaseFirestore

class DateHelper {
    static func createDate(from chosenDay: Date) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        let chosenDateString = dateFormatter.string(from: chosenDay)
        dateFormatter.dateFormat = "HH:mm:ss"
        let currentHourString = dateFormatter.string(from: Date())
        dateFormatter.dateFormat = "dd-MM-yyyy HH:mm:ss"
        let dateString = chosenDateString + " " + currentHourString
        return dateFormatter.date(from: dateString) ?? Date()
    }

    static func getTimeStamp(from date: Date) -> Timestamp {
        return Timestamp(date: date)
    }

    static func getDate(from timeStamp: Timestamp) -> Date {
        return timeStamp.dateValue()
    }

    static func getDayOfMonth(from date: Date) -> Date {
        let component =  Calendar.current.dateComponents([Calendar.Component.day,
                                                          Calendar.Component.month,
                                                          Calendar.Component.year], from: date)
        guard let date = Calendar.current.date(from: component) else {
            return Date()
        }
        return date
    }

    static func dayBetweenDates(start: Date, end: Date) -> Int {
        let components = Calendar.current.dateComponents([.day], from: start, to: end)
        return components.day ?? 0
    }
}
