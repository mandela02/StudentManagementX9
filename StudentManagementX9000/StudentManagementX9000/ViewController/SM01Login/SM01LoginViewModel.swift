//
//  SM01LoginViewModel.swift
//  StudentManagementX9000
//
//  Created by Bui Quang Tri on 4/14/20.
//  Copyright © 2020 Bui Quang Tri. All rights reserved.
//

import RxCocoa
import RxSwift

class SM01LoginViewModel {
    var userEmail: BehaviorRelay<String> = BehaviorRelay(value: "")
    var userPassword: BehaviorRelay<String> = BehaviorRelay(value: "")

    private var isUserEmailValid: Observable<Bool> {
        return userEmail.asObservable().map { StringHelper.isValidEmail(input: $0) }
    }

    private var isUserPasswordValid: Observable<Bool> {
        return userPassword.asObservable().map { $0.count > 5 }
    }

    var isUserAccountValid: Observable<Bool> {
        return Observable.combineLatest(isUserEmailValid,
                                        isUserPasswordValid,
                                        resultSelector: {$0 && $1})
    }
}
