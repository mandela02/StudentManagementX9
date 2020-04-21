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

struct FaceSectionModel {
    var header: String
    var items: [IdentificationResult]
}

extension FaceSectionModel: SectionModelType {
    init(original: FaceSectionModel, items: [IdentificationResult]) {
        self = original
        self.items = items
    }
}

class SM02PhotoViewModel {
    var faceDataList: BehaviorRelay<[IdentificationResult]> = BehaviorRelay(value: [])
    var faceResult: BehaviorRelay<[FaceSectionModel]> = BehaviorRelay(value: [])

    private let disposeBag = DisposeBag()

    init() {
        setupObservers()
    }

    private func setupObservers() {
        faceDataList.subscribe(onNext: { [weak self] models in
            guard let self = self else {
                return
            }
            self.faceResult.accept([FaceSectionModel(header: "", items: models)])
        }).disposed(by: disposeBag)
    }
}
