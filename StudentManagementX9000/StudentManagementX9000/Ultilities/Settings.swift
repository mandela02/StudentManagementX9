//
//  Settings.swift
//  FinancialManagementX9000
//
//  Created by TriBQ on 8/30/19.
//  Copyright © 2019 Tribq. All rights reserved.
//

import Foundation

enum UserDefaultsKey: String {
    case appLanguage
    case isFirstTimeLogIn
    case budget
}

struct Settings {
    static let appLanguage = WrappedUserDefault<String>(key: .appLanguage, defaultValue: Strings.languageCodeDevice)
    static let isLogOut = WrappedUserDefault<Bool>(key: .isFirstTimeLogIn, defaultValue: true)
    static let budget = WrappedUserDefault<Double>(key: .budget, defaultValue: 0)
}

class WrappedUserDefault<T> {
    let key: String
    let defaultValue: T

    var value: T {
        get {
            if let value = UserDefaults.standard.object(forKey: key) as? T {
                return value
            } else {
                return defaultValue
            }
        }
        set {
            UserDefaults.standard.set(newValue, forKey: key)
            UserDefaults.standard.synchronize()
        }
    }

    init(key: UserDefaultsKey, defaultValue: T) {
        self.key = key.rawValue
        self.defaultValue = defaultValue
    }
}
