//
//  FirestoreHelper.swift
//  StudentManagementX9000
//
//  Created by TriBQ on 5/12/20.
//  Copyright © 2020 Bui Quang Tri. All rights reserved.
//

import Foundation
import FirebaseFirestore
import RxSwift

class FirestoreHelper {
    let shared = FirestoreHelper()

    private var database = Firestore.firestore()
    private let disposeBag = DisposeBag()
    private init() {}

    private func configFirestore() {
        let settings = FirestoreSettings()
        settings.isPersistenceEnabled = false
        database.settings = settings
    }

    func uploadStudent(student: Student) -> Observable<Void> {
        return Observable.create { [weak self] observer -> Disposable in
            guard let self = self else {
                let errorTemp = NSError(domain: "no self", code: 404, userInfo: nil)
                observer.onError(errorTemp)
                observer.onCompleted()
                return Disposables.create()
            }
            let studentRef = self.database
                .collection(StudentFirestore.studentCollectionName)
                .document(student.studentId)
            studentRef
                .setData([StudentFirestore.studentId: student.studentId,
                          StudentFirestore.studentMail: student.studentMail,
                          StudentFirestore.studentPhone: student.studentPhone,
                          StudentFirestore.studentName: student.studentName],
                         merge: true) {  error in
                            if let error = error {
                                print("error \(error.localizedDescription)")
                                observer.onError(error)
                                observer.onCompleted()
                                return
                            }
                            let dispatchGroup = DispatchGroup()
                            for studentClass in student.studentClasses {
                                dispatchGroup.enter()
                                self.uploadStudentClass(of: student,
                                                        with: studentClass).subscribe(onNext: { isSuccess in
                                                            observer.onNext(())
                                                            dispatchGroup.leave()
                                                        }, onError: { error in
                                                            observer.onError(error)
                                                            dispatchGroup.leave()
                                                        }, onCompleted: {
                                                            dispatchGroup.leave()
                                                        }).disposed(by: self.disposeBag)
                            }
                            dispatchGroup.notify(queue: .main) {
                                observer.onCompleted()
                            }
            }
            return Disposables.create()
        }
    }

    func uploadStudentClass(of student: Student,
                            with studentClass: StudentClassInformation) -> Observable<Bool> {
        return Observable.create { [weak self] observer -> Disposable in
            guard let self = self else {
                let errorTemp = NSError(domain: "no self", code: 404, userInfo: nil)
                observer.onError(errorTemp)
                observer.onCompleted()
                return Disposables.create()
            }
            self.database
                .collection(StudentFirestore.studentCollectionName)
                .document(student.studentId)
                .collection(StudentFirestore.studentClassesCollectionName)
                .document(studentClass.classId)
                .setData([StudentFirestore.studentClassId: studentClass.classId,
                          StudentFirestore.studentStatus: studentClass.studentStatus,
                          StudentFirestore.studentMidTermScore: studentClass.midTermScore,
                          StudentFirestore.studentFinalScore: studentClass.finalScore],
                         merge: true) { error in
                            if let error = error {
                                observer.onError(error)
                                observer.onCompleted()
                                print("error \(error.localizedDescription)")
                                return
                            }
                            observer.onNext(true)
                            observer.onCompleted()
            }
            return Disposables.create()
        }
    }
}
