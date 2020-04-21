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

struct FaceApi {
    static let subscriptionKey = "fee82920753747ab9cbae785bd83a389"
    static let endPoint = "https://eastasia.api.cognitive.microsoft.com/face/v1.0/"
    static let studentGroupName = "Student Group"
    static let studentGroupId = "student_groud_id"
}
