//
//  StudentClassInformation.swift
//  StudentManagementX9000
//
//  Created by TriBQ on 5/12/20.
//  Copyright © 2020 Bui Quang Tri. All rights reserved.
//

import Foundation

struct StudentClassInformation {
    var classId = ""
    var studentStatus = true
    var midTermScore = 0.0
    var finalScore = 0.0
    
    init() {}
    
    init(classId: String, status: Bool, midTermScore: Double, finalScore: Double) {
        self.classId = classId
        self.studentStatus = status
        self.midTermScore = midTermScore
        self.finalScore = finalScore
    }
}
