//
//  FaceApiHelper.swift
//  StudentManagementX9000
//
//  Created by Bui Quang Tri on 4/18/20.
//  Copyright © 2020 Bui Quang Tri. All rights reserved.
//

import Foundation
import ProjectOxfordFace
import RxSwift
import RxCocoa

struct FaceModel {
    var faceImage: UIImage?
    var gender: String?
    var emotion: String?
    var age: String?
    var rect: CGRect?
}

struct IdentificationResult {
    var person: MPOPerson
    var confidence: Double
    var model: FaceModel?
}

class FaceApiHelper {
    static let shared = FaceApiHelper()
    let client = MPOFaceServiceClient(endpointAndSubscriptionKey: FaceApi.endPoint, key: FaceApi.subscriptionKey)
    var studentGroup: MPOLargePersonGroup?
    private let disposeBag = DisposeBag()
    let students: BehaviorRelay<[MPOPerson]> = BehaviorRelay(value: [])

    private init() {
        getGroup()
        getPeople()
    }

    func detect(image: UIImage) -> Observable<[MPOFace]?> {
        let jpegData = image.jpegData(compressionQuality: 0.75)

        return Observable.create { [weak self] observer in
            guard let self = self else {
                observer.onNext(nil)
                observer.onCompleted()
                return Disposables.create()
            }
            self.client?.detect(with: jpegData,
                                returnFaceId: true,
                                returnFaceLandmarks: true,
                                returnFaceAttributes: [NSNumber(value: MPOFaceAttributeTypeGender.rawValue),
                                                       NSNumber(value: MPOFaceAttributeTypeAge.rawValue),
                                                       NSNumber(value: MPOFaceAttributeTypeEmotion.rawValue)],
                                completionBlock: {faceCollection, error in
                                    if let error = error {
                                        print("error: \(error.localizedDescription)")
                                        observer.onError(error)
                                        observer.onCompleted()
                                        return
                                    }
                                    observer.onNext(faceCollection)
                                    observer.onCompleted()
            })
            return Disposables.create()
        }
    }

    func detectFace(image: UIImage) -> Observable<[FaceModel]?> {
        return Observable.create { [weak self] observer in
            guard let self = self else {
                observer.onNext(nil)
                observer.onCompleted()
                return Disposables.create()
            }
            var faceModels: [FaceModel] = []
            self.detect(image: image).subscribe(onNext: { faceCollection in
                guard let faceCollection = faceCollection else {
                    observer.onNext(nil)
                    observer.onCompleted()
                    return
                }
                for face in faceCollection {
                    guard let faceRectangleLeft = face.faceRectangle.left,
                        let faceRectangleTop = face.faceRectangle.top,
                        let faceRectangleWidth = face.faceRectangle.width,
                        let faceRectangleHeight = face.faceRectangle.height else {
                            continue
                    }
                    let faceRect = CGRect(x: CGFloat(faceRectangleLeft.floatValue),
                                          y: CGFloat(faceRectangleTop.floatValue),
                                          width: CGFloat(faceRectangleWidth.floatValue),
                                          height: CGFloat(faceRectangleHeight.floatValue))
                    let croppedImage = image.cgImage?.cropping(to: faceRect)
                    if let croppedImage = croppedImage {
                        let faceModel = FaceModel(faceImage: UIImage(cgImage: croppedImage),
                                                  gender: face.attributes.gender,
                                                  emotion: face.attributes?.emotion.mostEmotion,
                                                  age: face.attributes?.age.stringValue,
                                                  rect: faceRect)
                        faceModels.append(faceModel)
                    }
                }
                observer.onNext(faceModels)
                observer.onCompleted()
            }).disposed(by: self.disposeBag)
            return Disposables.create()
        }
    }

    func creatPeopleGroupIfNeed() -> Observable<MPOLargePersonGroup?> {
        return Observable.create { [weak self] observer in
            guard let self = self else {
                observer.onNext(nil)
                observer.onCompleted()
                return Disposables.create()
            }
            self.client?.createLargePersonGroup(FaceApi.studentGroupId,
                                                name: FaceApi.studentGroupName,
                                                userData: nil, completionBlock: { error in
                                                    if let error = error {
                                                        observer.onError(error)
                                                        print("error: \(error.localizedDescription)")
                                                        return
                                                    }
                                                    let studentGroup = MPOLargePersonGroup()
                                                    studentGroup.largePersonGroupId = FaceApi.studentGroupId
                                                    studentGroup.name = FaceApi.studentGroupName
                                                    observer.onNext(studentGroup)
                                                    observer.onCompleted()
            })
            return Disposables.create()
        }
    }

    private func getGroup() {
        client?.listLargePersonGroups(completion: { [weak self] personGroups, error in
            guard let self = self, error == nil else {
                return
            }
            guard let personGroups = personGroups else {
                return
            }
            if personGroups.isEmpty {
                self.creatPeopleGroupIfNeed().subscribe(onNext: { group in
                    self.studentGroup = group
                }).disposed(by: self.disposeBag)
            } else {
                self.studentGroup = personGroups.first
            }
        })
    }

    func deleteAllGroup(with groupId: String) {
        client?.deleteLargePersonGroup(groupId, completionBlock: { error in
            if let error = error {
                print("error: \(error.localizedDescription)")
                return
            }
        })
    }

    func addPerson(with name: String) -> Observable<MPOPerson?> {
        return Observable.create { [weak self] observable -> Disposable in
            guard let self = self else {
                observable.onNext(nil)
                observable.onCompleted()
                return Disposables.create()
            }
            self.client?.createPerson(withLargePersonGroupId: FaceApi.studentGroupId,
                                 name: name,
                                 userData: nil,
                                 completionBlock: { [weak self] result, error in
                                    guard let self = self else { return }
                                    if let error = error {
                                        observable.onError(error)
                                        observable.onCompleted()
                                        print("error: \(error.localizedDescription)")
                                        return
                                    }
                                    let student = MPOPerson()
                                    student.name = name
                                    student.personId = result?.personId
                                    observable.onNext(student)
                                    observable.onCompleted()
                                    self.students.accept(self.students.value + [student])
            })
            return Disposables.create()
        }
    }

    func getPeople() {
        client?.listPersons(withLargePersonGroupId: FaceApi.studentGroupId,
                            completionBlock: { [weak self] allStudents, error in
                                guard let self = self else {
                                    return
                                }
                                if let error = error {
                                    print("error: \(error.localizedDescription)")
                                    return
                                }
                                if let allStudents = allStudents {
                                    self.students.accept(allStudents)
                                }
        })
    }

    func deleteAllPerson() {
        client?.listPersons(withLargePersonGroupId: FaceApi.studentGroupId,
                            completionBlock: { [weak self] allStudents, error in
                                guard let self = self else {
                                    return
                                }
                                if let error = error {
                                    print("error: \(error.localizedDescription)")
                                    return
                                }
                                if let allStudents = allStudents {
                                    for student in allStudents {
                                        self.deletePerson(with: student.personId)
                                        self.students.accept([])
                                    }
                                }
        })
    }

    func trainPerson(image: UIImage, with model: MPOFace, studentId: String) -> Observable<()> {
        let jpegData = image.jpegData(compressionQuality: 0.75)
        return Observable.create { [weak self] observable -> Disposable in
            guard let self = self else {
                let errorTemp = NSError(domain: "no self", code: 404, userInfo: nil)
                observable.onError(errorTemp)
                observable.onCompleted()
                return Disposables.create()
            }
            self.client?.addPersonFace(withLargePersonGroupId: FaceApi.studentGroupId,
                                       personId: studentId,
                                       data: jpegData,
                                       userData: nil,
                                       faceRectangle: model.faceRectangle,
                                       completionBlock: { _, error in
                                        if let error = error {
                                            observable.onError(error)
                                            observable.onCompleted()
                                        } else {
                                            observable.onNext(())
                                            observable.onCompleted()
                                        }
            })
            return Disposables.create()
        }
    }

    func trainGroup() -> Observable<Void> {
        return Observable.create { observable in
            self.client?.trainLargePersonGroup(FaceApi.studentGroupId,
                                          completionBlock: { error in
                                            if let error = error {
                                                observable.onError(error)
                                                observable.onCompleted()
                                                print("error: \(error.localizedDescription)")
                                                return
                                            }
                                            observable.onNext(())
                                            observable.onCompleted()
            })
            return Disposables.create()
        }
    }

    func updatePerson(with name: String, of person: MPOPerson) -> Observable<Void> {
        return Observable.create { [weak self] observable in
            guard let self = self else {
                let errorTemp = NSError(domain: "no self", code: 404, userInfo: nil)
                observable.onError(errorTemp)
                observable.onCompleted()
                return Disposables.create()
            }
            self.client?.updatePerson(withLargePersonGroupId: FaceApi.studentGroupId,
                                      personId: person.personId,
                                      name: name,
                                      userData: nil,
                                      completionBlock: { error in
                                        if let error = error {
                                            observable.onError(error)
                                            observable.onCompleted()
                                            print("error: \(error.localizedDescription)")
                                            return
                                        }
                                        self.updateStudent(new: person).subscribe(onNext: { _ in
                                            observable.onNext(())
                                            observable.onCompleted()
                                        }, onError: { error in
                                            observable.onError(error)
                                            observable.onCompleted()
                                        }).disposed(by: self.disposeBag)
            })
            return Disposables.create()
        }
    }

    private func updateStudent(new person: MPOPerson) -> Observable<Void> {
        return Observable.create { [weak self] observable in
            guard let self = self else {
                let errorTemp = NSError(domain: "no self", code: 404, userInfo: nil)
                observable.onError(errorTemp)
                observable.onCompleted()
                return Disposables.create()
            }
            self.client?.getPersonWithLargePersonGroupId(FaceApi.studentGroupId,
                                                    personId: person.personId,
                                                    completionBlock: { newPerson, error in
                                                        if let error = error {
                                                            observable.onError(error)
                                                            observable.onCompleted()
                                                            print("error: \(error.localizedDescription)")
                                                            return
                                                        }
                                                        var currentList = self.students.value
                                                        guard let indexPath = currentList.firstIndex(of: person),
                                                            let newPerson = newPerson else {
                                                                let errorTemp = NSError(domain: "nil person",
                                                                                        code: 2,
                                                                                        userInfo: nil)
                                                                observable.onError(errorTemp)
                                                                observable.onCompleted()
                                                                return
                                                        }
                                                        currentList[indexPath] = newPerson
                                                        self.students.accept(currentList)
                                                        observable.onNext(())
                                                        observable.onCompleted()
            })
            return Disposables.create()
        }
    }

    func deletePerson(with personId: String) {
        client?.deletePerson(withLargePersonGroupId: FaceApi.studentGroupId,
                             personId: personId, completionBlock: { error in
                                if let error = error {
                                    print("error: \(error.localizedDescription)")
                                    return
                                }
        })
    }

    private func getPerson(with personId: String) -> MPOPerson? {
        let index = students.value.map({$0.personId}).firstIndex(of: personId)
        if let index = index {
            return students.value[index]
        }
        return nil
    }

    func identification(with persons: [MPOFace],
                        image: UIImage) -> Observable<[IdentificationResult]> {
        let listFaceId = persons.map({$0.faceId})
        var personList: [IdentificationResult] = []
        return Observable.create { [weak self] observable -> Disposable in
            guard let self = self else {
                observable.onCompleted()
                return Disposables.create()
            }
            self.client?.identify(withLargePersonGroupId: FaceApi.studentGroupId,
                                  faceIds: listFaceId as [Any],
                                  maxNumberOfCandidates: self.students.value.count,
                                  completionBlock: { collection, error in
                                    if let error = error {
                                        print("error: \(error.localizedDescription)")
                                        observable.onError(error)
                                        observable.onCompleted()
                                        return
                                    }
                                    guard let collection = collection else {
                                        let errorTemp = NSError(domain: "nil collection", code: 405, userInfo: nil)
                                        observable.onError(errorTemp)
                                        observable.onCompleted()
                                        return
                                    }
                                    for result in collection {
                                        guard let idIndex = listFaceId.firstIndex(of: result.faceId) else {
                                            continue
                                        }
                                        let model = self.creatFaceModelFromFace(face: persons[idIndex], of: image)
                                        if result.candidates.count == 0 {
                                            personList.append(IdentificationResult(person: MPOPerson(),
                                                                                   confidence: 0.0,
                                                                                   model: model))
                                            continue
                                        }
                                        for candidate in result.candidates {
                                            guard let candidate = candidate as? MPOCandidate else {
                                                continue
                                            }
                                            let person = self.getPerson(with: candidate.personId)
                                            let confidence = candidate.confidence.doubleValue
                                            if let person = person {
                                                personList.append(IdentificationResult(person: person,
                                                                                       confidence: confidence,
                                                                                       model: model))
                                            }
                                        }
                                    }
                                    observable.onNext(personList)
                                    observable.onCompleted()
            })
            return Disposables.create()
        }
    }

    func cutImage(from face: MPOFace, of image: UIImage) -> UIImage {
        guard let faceRectangleLeft = face.faceRectangle.left,
            let faceRectangleTop = face.faceRectangle.top,
            let faceRectangleWidth = face.faceRectangle.width,
            let faceRectangleHeight = face.faceRectangle.height else {
            return UIImage()
        }
        let faceRect = CGRect(x: CGFloat(faceRectangleLeft.floatValue),
                              y: CGFloat(faceRectangleTop.floatValue),
                              width: CGFloat(faceRectangleWidth.floatValue),
                              height: CGFloat(faceRectangleHeight.floatValue))
        guard let croppedImage = image.cgImage?.cropping(to: faceRect) else { return UIImage() }
        return UIImage(cgImage: croppedImage)
    }

    private func creatFaceModelFromFace(face: MPOFace, of image: UIImage) -> FaceModel? {
        guard let faceRectangleLeft = face.faceRectangle.left,
            let faceRectangleTop = face.faceRectangle.top,
            let faceRectangleWidth = face.faceRectangle.width,
            let faceRectangleHeight = face.faceRectangle.height else {
            return nil
        }
        let faceRect = CGRect(x: CGFloat(faceRectangleLeft.floatValue),
                              y: CGFloat(faceRectangleTop.floatValue),
                              width: CGFloat(faceRectangleWidth.floatValue),
                              height: CGFloat(faceRectangleHeight.floatValue))
        let croppedImage = image.cgImage?.cropping(to: faceRect)
        if let croppedImage = croppedImage {
            let faceModel = FaceModel(faceImage: UIImage(cgImage: croppedImage),
                                      gender: face.attributes.gender,
                                      emotion: face.attributes?.emotion.mostEmotion,
                                      age: face.attributes?.age.stringValue,
                                      rect: faceRect)
            return faceModel
        }
        return nil
    }
}
