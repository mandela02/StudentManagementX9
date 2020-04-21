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

struct ImageSectionModel {
    var header: String
    var items: [UIImage]
}

extension ImageSectionModel: SectionModelType {
    init(original: ImageSectionModel, items: [UIImage]) {
        self = original
        self.items = items
    }
}

class SM04NewPersonViewModel {
    let student: BehaviorRelay<MPOPerson?> = BehaviorRelay(value: nil)
    let mode: BehaviorRelay<Mode> = BehaviorRelay(value: .new)
    let name: BehaviorRelay<String> = BehaviorRelay(value: "")
    let listImage: BehaviorRelay<[UIImage]> = BehaviorRelay(value: [])
    let listImageSectionModel: BehaviorRelay<[ImageSectionModel]> = BehaviorRelay(value: [])
    private let disposeBag = DisposeBag()

    var isNameValid: Observable<Bool> {
        return name.asObservable().map { $0 != "" }
    }

    init() {
        mode.accept(.new)
        listImage
            .map({[ImageSectionModel(header: "", items: $0)]}).bind(to: listImageSectionModel)
            .disposed(by: disposeBag)
    }

    func addNewImage(image: UIImage) {
        listImage.accept(listImage.value + [image])
    }

    func createStudent() -> Observable<MPOPerson?> {
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
                    observable.onNext(person)
                    observable.onCompleted()
                    self.student.accept(person)
                }).disposed(by: self.disposeBag)
            } 
            return Disposables.create()
        }
    }
}
