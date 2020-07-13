//
//  SM04NewPersonViewModel.swift
//  StudentManagementX9000
//
//  Created by Bui Quang Tri on 4/20/20.
//  Copyright © 2020 Bui Quang Tri. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import ProjectOxfordFace
import UIKit
import RxDataSources

enum Mode {
    case new
    case update
}

struct ImageFace {
    var image: UIImage
    var face: MPOFace
}

struct ImageSectionModel {
    var header: String
    var items: [StorageImage]
}

extension ImageSectionModel: SectionModelType {
    init(original: ImageSectionModel, items: [StorageImage]) {
        self = original
        self.items = items
    }
}

class SM04NewPersonViewModel {
    let studentFacePerson: BehaviorRelay<MPOPerson?> = BehaviorRelay(value: nil)
    let student: BehaviorRelay<Student?> = BehaviorRelay(value: nil)
    let mode: BehaviorRelay<Mode> = BehaviorRelay(value: .new)
    let name: BehaviorRelay<String> = BehaviorRelay(value: "")
    let id: BehaviorRelay<String> = BehaviorRelay(value: "")
    let mail: BehaviorRelay<String> = BehaviorRelay(value: "")
    let phone: BehaviorRelay<String> = BehaviorRelay(value: "")

    let listImage: BehaviorRelay<[ImageFace]> = BehaviorRelay(value: [])
    let listImageSectionModel: BehaviorRelay<[ImageSectionModel]> = BehaviorRelay(value: [])

    private let disposeBag = DisposeBag()

    private var originalImageList: [StorageImage] = []
    let croppedList: BehaviorRelay<[StorageImage]> = BehaviorRelay(value: [])

    let isInDeleteMode: BehaviorRelay<Bool> = BehaviorRelay(value: false)
    var deletedImage: [StorageImage] = []
    
    var isNameValid: Observable<Bool> {
        return Observable.combineLatest(name, id).map({!$1.isEmpty && !$0.isEmpty})
    }

    init() {
        croppedList
            .map({[ImageSectionModel(header: "", items: $0)]}).bind(to: listImageSectionModel)
            .disposed(by: disposeBag)
        initData()
    }

    func initData() {
        mode.subscribe(onNext: { [weak self] mode in
            guard let self = self else { return }
            switch mode {
            case .new:
                break
            case .update:
                guard let student = self.student.value else {
                    return
                }
                StorageHelper.getAllImage(of: student.studentId).subscribe(onNext: { images in
                    self.originalImageList = images
                    self.croppedList.accept(images)
                }).disposed(by: self.disposeBag)
            }
        }).disposed(by: disposeBag)

        student.subscribe(onNext: {[weak self] student in
            guard let self = self, let student = student else { return }

            self.name.accept(student.studentName)
            self.id.accept(student.studentId)
            self.phone.accept(student.studentPhone)
            self.mail.accept(student.studentMail)

            FaceApiHelper.shared
                .getPersonFromServer(with: student.studentFaceId)
                .bind(to: self.studentFacePerson)
                .disposed(by: self.disposeBag)
        }).disposed(by: disposeBag)
    }

    func createStudent(complete: @escaping () -> Void) {
        guard let student = self.studentFacePerson.value else {
            return
        }
        FirestoreHelper.shared.uploadStudent(student: Student(id: id.value,
                                                              name: name.value,
                                                              mail: mail.value,
                                                              phone: phone.value,
                                                              faceId: student.personId))
            .subscribe(onNext: { _ in
                complete()
        }).disposed(by: disposeBag)
    }

    func getAdditionImage() -> [UIImage] {
        var images: [UIImage] = []
        let originalImages = originalImageList.map({$0.image})
        for image in croppedList.value.map({$0.image}) where originalImages.contains(image) == false {
            images.append(image)
        }
        return images
    }

    func addNewImage(image: ImageFace) {
        listImage.accept(listImage.value + [image])
    }

    func addCroppedImage(image: StorageImage) {
        croppedList.accept(croppedList.value + [image])
    }

    func trainPerson(of faceId: String, complete: @escaping () -> Void) {
        if listImage.value.isEmpty {
            complete()
            return
        }
        let dispatchGroup = DispatchGroup()
        for imageFace in listImage.value {
            dispatchGroup.enter()
            FaceApiHelper.shared
                .trainPerson(image: imageFace.image, with: imageFace.face, studentFaceId: faceId)
                .subscribe(onNext: { _ in
                    dispatchGroup.leave()
                }).disposed(by: disposeBag)
        }
        dispatchGroup.notify(queue: .main) {
            complete()
        }
    }

    func createStudentFaceModel() -> Observable<MPOPerson?> {
        return Observable.create { [weak self] observable -> Disposable in
            guard let self = self else {
                observable.onNext(nil)
                observable.onCompleted()
                return Disposables.create()
            }
            if self.mode.value == .new {
                FaceApiHelper.shared.addPerson(with: self.name.value).subscribe(onNext: { [weak self] person in
                    guard let self = self, let person = person else {
                        return
                    }
                    self.studentFacePerson.accept(person)
                    observable.onNext(person)
                    observable.onCompleted()
                }).disposed(by: self.disposeBag)
            } else {
                observable.onNext(self.studentFacePerson.value)
                observable.onCompleted()
            }
            return Disposables.create()
        }
    }
    
    func select(at indexPath: IndexPath, complete: (Bool) -> Void) {
        var list = croppedList.value
        if croppedList.value.filter({$0.isSelected}).count + 1 == croppedList.value.count {
            if list[indexPath.item].isSelected == false {
                complete(false)
                return
            } else {
                complete(true)
                list[indexPath.item].isSelected = false
                croppedList.accept(list)
                return
            }
        }
        complete(true)
        list[indexPath.item].isSelected = !list[indexPath.item].isSelected
        croppedList.accept(list)
    }

    func deselectEverything() {
        if isInDeleteMode.value {
            let list = croppedList.value
            croppedList.accept(list.map({StorageImage(name: $0.name, image: $0.image, isSelected: false)}))
        }
    }

    func deleteImage() {
        let deletedImages = croppedList.value.filter({$0.isSelected})
        var fullImage = croppedList.value
        for image in deletedImages {
            guard let index = fullImage.firstIndex(where: {$0.name == image.name}) else {
                return
            }
            fullImage.remove(at: index)
            deletedImage.append(image)
        }
        croppedList.accept(fullImage)
    }

    func deleteStoreImage() {
        for image in deletedImage {
            if let name = image.name {
                StorageHelper.deleteImage(with: name, of: id.value).subscribe().disposed(by: disposeBag)
            }
        }
    }
}
