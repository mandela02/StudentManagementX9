//
//  Strings.swift
//  FinancialManagementX9000
//
//  Created by TriBQ on 8/30/19.
//  Copyright © 2019 Tribq. All rights reserved.
//

import Foundation

enum LanguageCode: String, CaseIterable {
    case english = "en"
    case vietnamese = "vi"

    var name: String {
        switch self {
        case .english:
            return "English"
        case .vietnamese:
            return "Tiếng Việt"
        }
    }

    static func getLanguageCode(from index: Int) -> LanguageCode {
        return allCases.indices.contains(index) ? allCases[index] : .english
    }
}

struct Strings {
    static let preferredLanguages = NSLocale.preferredLanguages
    static var languageCodeDevice: String {
        guard let currentLanguage = preferredLanguages.first,
            let deviceLanguageCode =  LanguageCode
                .allCases
                .last(where: { currentLanguage.lowercased().contains($0.rawValue) })
        else {
            return LanguageCode.english.rawValue
        }
        return deviceLanguageCode.rawValue
    }

    static var localeIdentifier: String {
        return Settings.appLanguage.value
    }

    static let languageChangedObserver = "languageChangedObserver"
}

// swiftlint:disable identifier_name
struct LocalizedStrings {
    static var ok: String {return String(localizedKey: "ok")}
    static var done: String {return String(localizedKey: "done")}

    static var sun: String {return String(localizedKey: "sun")}
    static var mon: String {return String(localizedKey: "mon")}
    static var tue: String {return String(localizedKey: "tue")}
    static var wed: String {return String(localizedKey: "wed")}
    static var thu: String {return String(localizedKey: "thu")}
    static var fri: String {return String(localizedKey: "fri")}
    static var sat: String {return String(localizedKey: "sat")}
}
