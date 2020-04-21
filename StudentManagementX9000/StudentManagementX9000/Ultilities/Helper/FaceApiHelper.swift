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
}

protocol FaceApiDelegate: class {
    func didFinishDetection(models: [FaceModel])
}

enum DetectResult {
    case error
    case success
    case noFace
    case moreThanOneFace
}

class FaceApiHelper {
    static let shared = FaceApiHelper()
    let client = MPOFaceServiceClient(endpointAndSubscriptionKey: FaceApi.endPoint, key: FaceApi.subscriptionKey)
    var studentGroup: MPOLargePersonGroup?
    weak var delegate: FaceApiDelegate?
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
                                        print(error.localizedDescription)
                                        return
                                    }
                                    observer.onNext(faceCollection)
                                    observer.onCompleted()
            })
            return Disposables.create()
        }
    }

    func detectFace(image: UIImage) {
        var faceModels: [FaceModel] = []
        detect(image: image).subscribe(onNext: { faceCollection in
            guard let faceCollection = faceCollection else {
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
            self.delegate?.didFinishDetection(models: faceModels)
        }).disposed(by: self.disposeBag)
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
                                                        print(error.localizedDescription)
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
                print(error.localizedDescription)
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
                                        print(error.localizedDescription)
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
                                    print(error.localizedDescription)
                                    return
                                }
                                if let allStudents = allStudents {
                                    self.students.accept(allStudents)
                                }
        })
    }

    func trainPerson(with image: UIImage, studentId: String) -> Observable<DetectResult> {
        return Observable.create { [weak self] observable -> Disposable in
            guard let self = self else {
                observable.onNext(.error)
                observable.onCompleted()
                return Disposables.create()
            }
            self.detect(image: image).subscribe(onNext: { collection in
                guard let collection = collection else {
                    observable.onNext(.error)
                    observable.onCompleted()
                    return
                }
                if collection.count == 0 {
                    observable.onNext(.noFace)
                    observable.onCompleted()
                } else if collection.count == 1, let face = collection.first {
                    self.train(image: image, face: face, studentId: studentId).subscribe(onNext: { result in
                        switch result {
                        case .error:
                            observable.onNext(.error)
                            observable.onCompleted()
                        case .success:
                            observable.onNext(.success)
                            observable.onCompleted()
                        case .moreThanOneFace:
                            observable.onNext(.error)
                            observable.onCompleted()
                        case .noFace:
                            observable.onNext(.error)
                            observable.onCompleted()
                        }
                    }).disposed(by: self.disposeBag)
                } else {
                    observable.onNext(.moreThanOneFace)
                    observable.onCompleted()
                }
            }).disposed(by: self.disposeBag)
            return Disposables.create()
        }
    }

    private func train(image: UIImage, face: MPOFace, studentId: String) -> Observable<DetectResult> {
        let jpegData = image.jpegData(compressionQuality: 0.75)
        return Observable.create { [weak self] observable -> Disposable in
            guard let self = self else {
                observable.onNext(.error)
                observable.onCompleted()
                return Disposables.create()
            }
            self.client?.addPersonFace(withLargePersonGroupId: FaceApi.studentGroupId,
                                       personId: studentId,
                                       data: jpegData,
                                       userData: nil,
                                       faceRectangle: face.faceRectangle,
                                       completionBlock: { _, error in
                                        if error == nil {
                                            observable.onNext(.success)
                                            observable.onCompleted()
                                        } else {
                                            observable.onNext(.error)
                                            observable.onCompleted()
                                        }
            })
            return Disposables.create()
        }
    }

    func trainGroup() {
        client?.trainLargePersonGroup(FaceApi.studentGroupId,
                                      completionBlock: { error in
                                        if let error = error {
                                            print(error.localizedDescription)
                                            return
                                        }
        })
    }

    func updatePerson(with name: String, of person: MPOPerson) {
        client?.updatePerson(withLargePersonGroupId: FaceApi.studentGroupId,
                             personId: person.personId,
                             name: name,
                             userData: nil,
                             completionBlock: { error in
                                if let error = error {
                                    print(error.localizedDescription)
                                    return
                                }
        })
    }

    func deletePerson(with personId: String) {
        client?.deletePerson(withLargePersonGroupId: FaceApi.studentGroupId,
                             personId: personId, completionBlock: { error in
                                if let error = error {
                                    print(error.localizedDescription)
                                    return
                                }
        })
    }

    private func getPerson(with id: String) -> MPOPerson? {
        let index = students.value.map({$0.personId}).firstIndex(of: id)
        if let index = index {
            return students.value[index]
        }
        return nil
    }

    func identification(with persons: [MPOFace]) -> Observable<[IdentificationResult]> {
        let ids = persons.map({$0.faceId})
        var personList: [IdentificationResult] = []
        return Observable.create { [weak self] observable -> Disposable in
            guard let self = self else {
                observable.onCompleted()
                return Disposables.create()
            }
            self.client?.identify(withLargePersonGroupId: FaceApi.studentGroupId,
                             faceIds: ids,
                             maxNumberOfCandidates: self.students.value.count,
                             completionBlock: { collection, error in
                                if let error = error {
                                    print(error.localizedDescription)
                                    observable.onError(error)
                                    observable.onCompleted()
                                    return
                                }
                                guard let collection = collection else {
                                    observable.onCompleted()
                                    return
                                }
                                for result in collection {
                                    for candidate in result.candidates {
                                        guard let candidate = candidate as? MPOCandidate else {
                                            observable.onCompleted()
                                            return
                                        }
                                        let person = self.getPerson(with: candidate.personId)
                                        let confidence = candidate.confidence.doubleValue
                                        if let person = person {
                                            personList.append(IdentificationResult(person: person,
                                                                                   confidence: confidence))
                                        }
                                    }
                                }
                                observable.onNext(personList)
                                observable.onCompleted()
            })
            return Disposables.create()
        }
    }
}