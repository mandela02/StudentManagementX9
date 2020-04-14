//
//  Date+Extension.swift
//  FinancialManagementX9000
//
//  Created by TriBQ on 9/13/19.
//  Copyright © 2019 Tribq. All rights reserved.
//

import Foundation

enum Weekday: Int, CaseIterable {
    /* 1: Sun, 2: Mon, 3: Tue, 4: Wed, 5: Thu, 6: Fri, 7: Sat */
    case sun
    case mon
    case tue
    case wed
    case thu
    case fri
    case sat
    static func getWeekDay(from index: Int) -> Weekday {
        return allCases.indices.contains(index) ? allCases[index] : .sun
    }
    static func getWeekDayString(from index: Int) -> String {
        let weekday = Weekday.getWeekDay(from: index)
        switch weekday {
        case .sun:
            return LocalizedStrings.sun
        case .mon:
            return LocalizedStrings.mon
        case .tue:
            return LocalizedStrings.tue
        case .wed:
            return LocalizedStrings.wed
        case .thu:
            return LocalizedStrings.thu
        case .fri:
            return LocalizedStrings.fri
        case .sat:
            return LocalizedStrings.sat
        }
    }
}

extension Date {
    var year: Int {
        return Calendar.gregorian.component(.year, from: self)
    }

    var month: Int {
        return Calendar.gregorian.component(.month, from: self)
    }

    var day: Int {
        return Calendar.gregorian.component(.day, from: self)
    }

    var tomorrow: Date {
        return Calendar.gregorian.date(byAdding: .day, value: 1, to: self) ?? self
    }

    var yesterday: Date {
        return Calendar.gregorian.date(byAdding: .day, value: -1, to: self) ?? self
    }

    func startOfMonth() -> Date {
        guard let date = Calendar.gregorian.date(from: Calendar.gregorian
            .dateComponents([.year, .month], from: Calendar.gregorian.startOfDay(for: self)))
        else {
                return self
        }
        return date
    }

    func endOfMonth() -> Date {
        guard let date = Calendar.gregorian
            .date(byAdding: DateComponents(month: 1, day: -1), to: self.startOfMonth())
        else {
            return self
        }
        return date
    }

    func nextMonth() -> Date {
        guard let date = Calendar.gregorian.date(byAdding: DateComponents(month: 1, day: 0), to: self)
        else {
            return self
        }
        return date
    }

    func lastMonth() -> Date {
        guard let date = Calendar.gregorian.date(byAdding: DateComponents(month: -1, day: 0), to: self)
            else {
                return self
        }
        return date
    }

    func isInSameWeek(date: Date) -> Bool {
        return Calendar.gregorian.isDate(self, equalTo: date, toGranularity: .weekOfYear)
    }

    func isInSameMonth(date: Date) -> Bool {
        return Calendar.gregorian.isDate(self, equalTo: date, toGranularity: .month)
    }

    func isInSameYear(date: Date) -> Bool {
        return Calendar.gregorian.isDate(self, equalTo: date, toGranularity: .year)
    }

    func isInSameDay(date: Date) -> Bool {
        return Calendar.gregorian.isDate(self, equalTo: date, toGranularity: .day)
    }

    var isInThisWeek: Bool {
        return isInSameWeek(date: Date())
    }

    var isInYesterday: Bool {
        return Calendar.gregorian.isDateInYesterday(self)
    }

    var isInToday: Bool {
        return Calendar.gregorian.isDateInToday(self)
    }

    var isInTomorrow: Bool {
        return Calendar.gregorian.isDateInTomorrow(self)
    }

    var isInTheFuture: Bool {
        return Date() < self
    }

    var isInThePast: Bool {
        return self < Date()
    }

    var weekday: Weekday {
        /* 0: Sun, 1: Mon, 2: Tue, 3: Wed, 4: Thu, 5: Fri, 6: Sat */
        return Weekday.getWeekDay(from: Calendar.gregorian.component(.weekday, from: self) - 1)
    }

    var previousSecond: Date {
        return Calendar.gregorian.date(byAdding: .second, value: -1, to: self) ?? self
    }

    var nextWeek: Date {
        return Calendar.gregorian.date(byAdding: .day, value: 7, to: self) ?? self
    }

    var startOfWeek: Date {
        let components = Calendar.gregorian.dateComponents([.weekOfYear, .yearForWeekOfYear], from: self)
        return Calendar.gregorian.date(from: components) ?? self
    }

    var endOfWeek: Date {
        return startOfWeek.nextWeek.previousSecond
    }

    func isInSameDay(as date: Date) -> Bool {
        return Calendar.gregorian.isDate(self, inSameDayAs: date)
    }
}
