//
//  SM02PhotoViewModel.swift
//  StudentManagementX9000
//
//  Created by Bui Quang Tri on 4/18/20.
//  Copyright © 2020 Bui Quang Tri. All rights reserved.
//

import Foundation
import RxDataSources
import RxSwift
import RxCocoa

struct PhotoCell {
    var result: IdentificationResult
    var student: Student
}

struct FaceSectionModel {
    var header: String
    var items: [PhotoCell]
}

extension FaceSectionModel: SectionModelType {
    init(original: FaceSectionModel, items: [PhotoCell]) {
        self = original
        self.items = items
    }
}

class SM02PhotoViewModel {
    let faceDataList: BehaviorRelay<[IdentificationResult]> = BehaviorRelay(value: [])
    let faceResult: BehaviorRelay<[FaceSectionModel]> = BehaviorRelay(value: [])
    let students: BehaviorRelay<[PhotoCell]> = BehaviorRelay(value: [])

    private let disposeBag = DisposeBag()

    init() {
        setupObservers()
    }

    private func setupObservers() {
        FirestoreHelper.shared.listenToChange { _ in
            self.faceDataList.accept(self.faceDataList.value)
        }

        students.map({[FaceSectionModel(header: "", items: $0)]}).bind(to: faceResult).disposed(by: disposeBag)

        faceDataList.subscribe(onNext: { [weak self] models in
            guard let self = self else {
                return
            }
            if models.isEmpty {
                self.students.accept([])
                return
            }
            var students: [PhotoCell] = []
            let dispatchGroup = DispatchGroup()
            for model in models {
                dispatchGroup.enter()
                if model.person.personId == nil {
                    students.append(PhotoCell(result: model, student: Student()))
                    dispatchGroup.leave()
                } else {
                    FirestoreHelper.shared.getStudent(faceID: model.person.personId).subscribe(onNext: { student in
                        students.append(PhotoCell(result: model, student: student))
                        dispatchGroup.leave()
                    }).disposed(by: self.disposeBag)
                }
            }
            dispatchGroup.notify(queue: .main) {
                self.students.accept(students)
            }
        }).disposed(by: disposeBag)
    }
}
