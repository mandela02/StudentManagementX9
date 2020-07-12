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

enum DocumentChangeStatus: CaseIterable {
    case edited
    case added
    case deleted
}

class FirestoreHelper {
    static let shared = FirestoreHelper()

    private var database = Firestore.firestore()
    private let disposeBag = DisposeBag()

    private init() {}

    private var listener: ListenerRegistration?

    var query: Query? {
        didSet {
            if let listener = listener {
                listener.remove()
            }
        }
    }

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
                          StudentFirestore.studentName: student.studentName,
                          StudentFirestore.studentFaceId: student.studentFaceId],
                         merge: true) { error in
                            if let error = error {
                                print("error \(error.localizedDescription)")
                                observer.onError(error)
                                observer.onCompleted()
                                return
                            }
//                            let dispatchGroup = DispatchGroup()
//                            for studentClass in student.studentClasses {
//                                dispatchGroup.enter()
//                                self.uploadStudentClassInformation(of: student,
//                                                        with: studentClass).subscribe(onNext: { _ in
//                                                            observer.onNext(())
//                                                            dispatchGroup.leave()
//                                                        }, onError: { error in
//                                                            observer.onError(error)
//                                                            dispatchGroup.leave()
//                                                        }, onCompleted: {
//                                                            dispatchGroup.leave()
//                                                        }).disposed(by: self.disposeBag)
//                            }
//                            dispatchGroup.notify(queue: .main) {
//                                observer.onCompleted()
//                            }
                            observer.onNext(())
                            observer.onCompleted()
            }
            return Disposables.create()
        }
    }

    func uploadStudentClassInformation(of student: Student,
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

    func getStudent(studentId: String) -> Observable<Student> {
        return Observable.create {  [weak self] observer -> Disposable in
            guard let self = self else {
                let errorTemp = NSError(domain: "no self", code: 404, userInfo: nil)
                observer.onError(errorTemp)
                observer.onCompleted()
                return Disposables.create()
            }
            self.database
            .collection(StudentFirestore.studentCollectionName)
            .document(studentId)
                .addSnapshotListener { (document, error) in
                    if let error = error {
                        observer.onError(error)
                        observer.onCompleted()
                        return
                    }
                    guard let data = document?.data() else {
                        let errorTemp = NSError(domain: "no doc", code: 404, userInfo: nil)
                        observer.onError(errorTemp)
                        observer.onCompleted()
                        return
                    }
                    observer.onNext(self.getStudentData(from: data))
                    observer.onCompleted()
            }
            return Disposables.create()
        }
    }
    
    func getStudent(faceID: String) -> Observable<Student> {
        return Observable.create {  [weak self] observer -> Disposable in
            guard let self = self else {
                let errorTemp = NSError(domain: "no self", code: 404, userInfo: nil)
                observer.onError(errorTemp)
                observer.onCompleted()
                return Disposables.create()
            }
            self.database
            .collection(StudentFirestore.studentCollectionName)
                .whereField(StudentFirestore.studentFaceId, isEqualTo: faceID)
                .getDocuments { (snapShot, error) in
                    if let error = error {
                        observer.onError(error)
                        observer.onCompleted()
                        return
                    }
                    guard let data = snapShot?.documents.first?.data() else {
                        let errorTemp = NSError(domain: "no doc", code: 404, userInfo: nil)
                        observer.onError(errorTemp)
                        observer.onCompleted()
                        return
                    }
                    observer.onNext(self.getStudentData(from: data))
                    observer.onCompleted()
            }
            return Disposables.create()
        }
    }

    
    func getAllDocument(_ callback: @escaping ([Student]) -> Void) {
        self.database
            .collection(StudentFirestore.studentCollectionName)
            .getDocuments(completion: { [weak self] querySnapshot, error in
            guard let self = self else { return }
            guard let snapshot = querySnapshot else {
                print("Error retreiving snapshot: \(error!)")
                return
            }
            var dataList: [Student] = []
            for document in snapshot.documents {
                dataList.append(self.getStudentData(from: document.data()))
            }
            callback(dataList)
        })
    }

    func deleteAll(_ complete: @escaping () -> Void) {
        getAllDocument { [weak self] (dataList) in
            guard let self = self else { return }
            for data in dataList {
                self.delete(at: data.studentId)
            }
            complete()
        }
    }

    func delete(at documentId: String, _ complete: ((Error?) -> Void)? = nil) {
        self.database
            .collection(StudentFirestore.studentCollectionName)
            .document(documentId).delete(completion: { error in
                guard let err = error else {
                    complete?(nil)
                    return
                }
                complete?(err)
            })
    }
}

// listen to student change
extension FirestoreHelper {
    func startListening(_ complete: @escaping ([Student]) -> Void) {
        stopListening()
        query = baseQuery()
        listening { data in
            complete(data)
        }
    }

    func stopListening() {
        listener?.remove()
    }

    private func baseQuery() -> Query? {
        return self.database
            .collection(StudentFirestore.studentCollectionName)
    }

    private func listening(_ complete: @escaping ([Student]) -> Void) {
        guard let query = query else { return }
        stopListening()
        listener = query
            .addSnapshotListener(includeMetadataChanges: true) { [weak self] querySnapshot, error in
                guard let self = self else { return }
                guard let snapshot = querySnapshot else {
                    print("Error retreiving snapshot: \(error!)")
                    return
                }
                complete(snapshot.documents.map({self.getStudentData(from: $0.data())}))
        }
    }

    func listenToChange(_ complete: @escaping ([Student]) -> Void) {
        self.database
            .collection(StudentFirestore.studentCollectionName)
            .addSnapshotListener(includeMetadataChanges: true) { [weak self] querySnapshot, error in
                guard let self = self else { return }
                guard let snapshot = querySnapshot else {
                    print("Error retreiving snapshot: \(error!)")
                    return
                }
                complete(snapshot.documents.map({self.getStudentData(from: $0.data())}))
        }
    }

    func getStudentData(from document: [String: Any]) -> Student {
        guard let id = document[StudentFirestore.studentId] as? String,
            let mail = document[StudentFirestore.studentMail] as? String,
            let name = document[StudentFirestore.studentName] as? String,
            let phone = document[StudentFirestore.studentPhone] as? String,
            let faceId = document[StudentFirestore.studentFaceId] as? String
            else {
                return Student()
        }
        return Student(id: id, name: name, mail: mail, phone: phone, faceId: faceId)
    }
}

extension FirestoreHelper {
    func uploadClass(newClass: Class) -> Observable<Void> {
        return Observable.create { [weak self] observer -> Disposable in
            guard let self = self else {
                let errorTemp = NSError(domain: "no self", code: 404, userInfo: nil)
                observer.onError(errorTemp)
                observer.onCompleted()
                return Disposables.create()
            }
            self.database
                .collection(ClassFirestore.classCollectionName)
                .document(newClass.classID)
                .setData([ClassFirestore.classID: newClass.classID,
                          ClassFirestore.className: newClass.className,
                          ClassFirestore.classRoom: newClass.classRoom,
                          ClassFirestore.classTeacher: newClass.classTeacher,
                          ClassFirestore.classTestId: newClass.classTestId,
                          ClassFirestore.classLesson: newClass.classLesson],
                         merge: true) { error in
                            if let error = error {
                                observer.onError(error)
                                observer.onCompleted()
                            }
                            observer.onNext(())
                            observer.onCompleted()
            }
            return Disposables.create()
        }
    }
}

extension FirestoreHelper {
    func uploadTeacher(teacher: Teacher) -> Observable<Void> {
        return Observable.create { [weak self] observer -> Disposable in
            guard let self = self else {
                let errorTemp = NSError(domain: "no self", code: 404, userInfo: nil)
                observer.onError(errorTemp)
                observer.onCompleted()
                return Disposables.create()
            }
            self.database
                .collection(TeacherFirestore.teacherCollectionName)
                .document(teacher.teacherId)
                .setData([TeacherFirestore.teacherId: teacher.teacherId,
                          TeacherFirestore.teacherMail: teacher.teacherMail,
                          TeacherFirestore.teacherName: teacher.teacherName,
                          TeacherFirestore.teacherPhone: teacher.teacherPhone],
                         merge: true) { error in
                            if let error = error {
                                observer.onError(error)
                                observer.onCompleted()
                            }
                            observer.onNext(())
                            observer.onCompleted()
            }
            return Disposables.create()
        }
    }
}
