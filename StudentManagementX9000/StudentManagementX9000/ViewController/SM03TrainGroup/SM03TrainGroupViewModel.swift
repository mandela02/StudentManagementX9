//
//  SM03TrainGroupViewModel.swift
//  StudentManagementX9000
//
//  Created by Bui Quang Tri on 4/20/20.
//  Copyright © 2020 Bui Quang Tri. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import RxDataSources
import ProjectOxfordFace

struct Person {
    let person: MPOPerson
    let image: UIImage
}

struct StudentSectionModel {
    var header: String
    var items: [Person]
}

extension StudentSectionModel: SectionModelType {
    init(original: StudentSectionModel, items: [Person]) {
        self = original
        self.items = items
    }
}

class SM03TrainGroupViewModel {
    let students: BehaviorRelay<[Person]> = BehaviorRelay(value: [])
    var studensList: BehaviorRelay<[StudentSectionModel]> = BehaviorRelay(value: [])

    private let disposeBag = DisposeBag()

    init() {
        initPersonList()
    }

    private func initPersonList() {
        FaceApiHelper.shared.students.subscribe(onNext: { [weak self] studentFaceModels in
            guard let self = self else { return }
            var personList: [Person] = []
            guard studentFaceModels.count != 0 else {
                self.students.accept(personList)
                return
            }
            for studentFaceModel in studentFaceModels {
                FirestoreHelper
                    .shared
                    .getStudent(faceID: studentFaceModel.personId)
                    .subscribe(onNext: { student in
                        StorageHelper
                            .getAvatar(from: student.studentId)
                            .subscribe(onNext: { image in
                            personList.append(Person(person: studentFaceModel, image: image))
                            self.students.accept(personList)
                        }).disposed(by: self.disposeBag)
                    }).disposed(by: self.disposeBag)
            }
        }).disposed(by: disposeBag)

        students
            .map({[StudentSectionModel(header: "", items: $0)]})
            .bind(to: studensList)
            .disposed(by: disposeBag)
    }
}
