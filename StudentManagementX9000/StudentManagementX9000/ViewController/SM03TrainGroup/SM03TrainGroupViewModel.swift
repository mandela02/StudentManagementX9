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
    let person: Student
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
        initObserverse()
    }
    private func initObserverse() {
        FirestoreHelper.shared.listenToChange { (students) in
            var personList: [Person] = []
            if students.isEmpty {
                self.students.accept([])
            }
            for student in students {
                StorageHelper
                    .getAvatar(from: student.studentId)
                    .subscribe(onNext: { image in
                        personList.append(Person(person: student, image: image))
                        self.students.accept(personList)
                    }).disposed(by: self.disposeBag)
            }
            FaceApiHelper.shared.trainGroup().subscribe().disposed(by: self.disposeBag)
        }

        self.students
            .map({[StudentSectionModel(header: "", items: $0)]})
            .bind(to: self.studensList)
            .disposed(by: self.disposeBag)
    }

    func refreshData() {
        let localStudents = students.value
        var personList: [Person] = []
        for student in localStudents {
            StorageHelper
                .getAvatar(from: student.person.studentId)
                .subscribe(onNext: { image in
                    personList.append(Person(person: student.person, image: image))
                    self.students.accept(personList)
                }).disposed(by: self.disposeBag)
        }
    }
}
