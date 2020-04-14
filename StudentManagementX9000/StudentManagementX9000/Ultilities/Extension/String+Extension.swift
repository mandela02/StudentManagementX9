//
//  String+Extension.swift
//  FinancialManagementX9000
//
//  Created by TriBQ on 8/30/19.
//  Copyright © 2019 Tribq. All rights reserved.
//

import Foundation
import UIKit

extension String {
    init(localizedKey key: String) {
        var bundle: Bundle? = Bundle.main
        let resourceName =
            Settings.appLanguage.value
        if let path = Bundle.main.path(forResource: resourceName, ofType: "lproj") {
            bundle = Bundle(path: path)
        }
        self = bundle?.localizedString(forKey: key, value: nil, table: nil) ?? key
    }
}
