//
//  Button+Extension.swift
//  FinancialManagementX9000
//
//  Created by TriBQ on 9/14/19.
//  Copyright © 2019 Tribq. All rights reserved.
//

import Foundation
import UIKit

extension UIButton {
    func setDisable() {
        self.setTitleColor(UIColor.lightGray, for: .disabled)
    }

    func setInfiniteLine() {
        self.titleLabel?.lineBreakMode = .byWordWrapping
        self.titleLabel?.numberOfLines = 0
    }
}
