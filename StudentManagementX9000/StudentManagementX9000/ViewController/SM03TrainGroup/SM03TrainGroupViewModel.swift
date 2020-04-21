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
    let name: String
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
        FaceApiHelper.shared.students
            .map({$0.map({Person(name: $0.name)})})
            .bind(to: students)
            .disposed(by: disposeBag)
        students
            .map({[StudentSectionModel(header: "", items: $0)]})
            .bind(to: studensList)
            .disposed(by: disposeBag)
    }
}
