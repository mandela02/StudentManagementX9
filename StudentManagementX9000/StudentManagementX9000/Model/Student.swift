//
//  File.swift
//  StudentManagementX9000
//
//  Created by TriBQ on 5/12/20.
//  Copyright © 2020 Bui Quang Tri. All rights reserved.
//

import Foundation

struct Student {
    var studentId = ""
    var studentName = ""
    var studentMail = ""
    var studentPhone = ""
    var studentFaceId = ""
    var studentClasses: [StudentClassInformation] = []

    init() {}

    init(id: String, name: String, mail: String, phone: String, faceId: String = "") {
        self.studentId = id
        self.studentName = name
        self.studentMail = mail
        self.studentPhone = phone
        self.studentFaceId = faceId
    }
}
