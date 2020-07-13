//
//  AppDelegate.swift
//  StudentManagementX9000
//
//  Created by Bui Quang Tri on 4/14/20.
//  Copyright © 2020 Bui Quang Tri. All rights reserved.
//

import UIKit
import Firebase
import RxSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    let disposeBag = DisposeBag()

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        let loginViewController = SM01LoginViewController.instantiateFromStoryboard()
        let rootNavigationViewController = UINavigationController(rootViewController: loginViewController)
        window?.rootViewController = rootNavigationViewController
        window?.makeKeyAndVisible()
        FirebaseApp.configure()
        //fakeData()
        return true
    }

    private func fakeData() {
        FirestoreHelper.shared.uploadClass(newClass: Class(classID: "Class1",
                                                           className: "Demo class 1",
                                                           classRoom: "Room 101",
                                                           classTeacher: "teacher1",
            classTestId: "Class1-Test")).subscribe().disposed(by: disposeBag)
        FirestoreHelper.shared.uploadClass(newClass: Class(classID: "Class2",
                                                           className: "Demo class 2",
                                                           classRoom: "Room 102",
                                                           classTeacher: "teacher2",
            classTestId: "Class2-Test")).subscribe().disposed(by: disposeBag)
        FirestoreHelper.shared.uploadClass(newClass: Class(classID: "Class3",
                                                           className: "Demo class 3",
                                                           classRoom: "Room 103",
                                                           classTeacher: "teacher3",
            classTestId: "Class3-Test")).subscribe().disposed(by: disposeBag)
        FirestoreHelper.shared.uploadClass(newClass: Class(classID: "Class4",
                                                           className: "Demo class 4",
                                                           classRoom: "Room 104",
                                                           classTeacher: "teacher4",
            classTestId: "Class4-Test")).subscribe().disposed(by: disposeBag)
        FirestoreHelper.shared.uploadClass(newClass: Class(classID: "Class5",
                                                           className: "Demo class 5",
                                                           classRoom: "Room 105",
                                                           classTeacher: "teacher5",
            classTestId: "Class5-Test")).subscribe().disposed(by: disposeBag)
        
        FirestoreHelper.shared.uploadTeacher(teacher: Teacher(teacherName: "Nguyen Van A",
                                                              teacherId: "teacher1",
                                                              teacherMail: "teacher1@gmail.com",
                                                              teacherPhone: "12211211221"))
            .subscribe()
            .disposed(by: disposeBag)
        FirestoreHelper.shared.uploadTeacher(teacher: Teacher(teacherName: "Nguyen Van B",
                                                              teacherId: "teacher2",
                                                              teacherMail: "teacher2@gmail.com",
                                                              teacherPhone: "12211211221"))
            .subscribe()
            .disposed(by: disposeBag)
        FirestoreHelper.shared.uploadTeacher(teacher: Teacher(teacherName: "Nguyen Van C",
                                                              teacherId: "teacher3",
                                                              teacherMail: "teacher3@gmail.com",
                                                              teacherPhone: "12211211221"))
            .subscribe()
            .disposed(by: disposeBag)
        FirestoreHelper.shared.uploadTeacher(teacher: Teacher(teacherName: "Nguyen Van D",
                                                              teacherId: "teacher4",
                                                              teacherMail: "teacher4@gmail.com",
                                                              teacherPhone: "12211211221"))
            .subscribe()
            .disposed(by: disposeBag)
        FirestoreHelper.shared.uploadTeacher(teacher: Teacher(teacherName: "Nguyen Van E",
                                                              teacherId: "teacher5",
                                                              teacherMail: "teacher5@gmail.com",
                                                              teacherPhone: "12211211221"))
            .subscribe()
            .disposed(by: disposeBag)

    }
}
