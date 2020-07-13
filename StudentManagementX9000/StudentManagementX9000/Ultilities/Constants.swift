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
    static let subscriptionKey = "83042c900ea245318506435334b4bfa5"
    static let endPoint = "https://eastasia.api.cognitive.microsoft.com/face/v1.0/"
    static let studentGroupName = "Student Group"
    static let studentGroupId = "student_groud_id"
}

struct StudentFirestore {
    static let studentCollectionName = "Students"
    static let studentName = "StudentName"
    static let studentId = "StudentID"
    static let studentMail = "StudentMail"
    static let studentPhone = "StudentPhone"
    static let studentFaceId = "studentFaceId"

    static let studentClassesCollectionName = "Classes"
    static let studentClassId = "StudentClassId"
    static let studentStatus = "StudentCanAttendTest"
    static let studentMidTermScore = "StudentMidTermScore"
    static let studentFinalScore = "StudentFinalScore"
}

struct ClassFirestore {
    static let classCollectionName = "Classes"
    static let classID = "ClassID"
    static let className = "ClassName"
    static let classRoom = "ClassRoom"
    static let classTeacher = "ClassTeacher"
    static let classLesson = "ClassLesson"
    static let classTestId = "ClassTestID"
    static let midTermDate = "midTermDate"
    static let finalDate = "finalDate"
}

struct TeacherFirestore {
    static let teacherCollectionName = "Teachers"
    static let teacherName = "TeacherName"
    static let teacherId = "TeacherID"
    static let teacherMail = "TeacherMail"
    static let teacherPhone = "TeacherPhone"
}
