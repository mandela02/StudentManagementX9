//
//  Constants.swift
//  FinancialManagementX9000
//
//  Created by TriBQ on 9/12/19.
//  Copyright © 2019 Tribq. All rights reserved.
//

import Foundation
import UIKit

struct CollectionView {
    static let sectionInsets = UIEdgeInsets(top: 2.0, left: 2.0, bottom: 2.0, right: 2.0)
    static let numberOfCellinRow: CGFloat = 3
}

struct Constants {
    static let minDate = DateFormatterHelper.date(from: "1/1/2000") ?? Date()
    static let maxDate = DateFormatterHelper.date(from: "31/12/2077") ?? Date()
}