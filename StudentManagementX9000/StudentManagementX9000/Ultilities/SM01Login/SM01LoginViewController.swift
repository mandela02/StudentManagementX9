//
//  SM01LoginViewController.swift
//  StudentManagementX9000
//
//  Created by Bui Quang Tri on 4/14/20.
//  Copyright © 2020 Bui Quang Tri. All rights reserved.
//

import UIKit
import RxSwift

class SM01LoginViewController: BaseViewController {

    @IBOutlet weak var passwordView: UIView!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!

    @IBOutlet weak var loginButton: UIButton!

    private let viewModel = SM01LoginViewModel()
    private let disposeBag = DisposeBag()

    override func configureView() {
        setupView()
        setupLanguage()
    }

    override func configureLocalizedStrings() {
        setupLanguage()
    }

    override func configureObservers() {
        loginButton.isEnabled = false
        viewModel.isUserAccountValid
            .bind(to: loginButton.rx.isEnabled)
            .disposed(by: disposeBag)
        emailTextField.rx.text
            .map { $0 ?? "" }
            .bind(to: viewModel.userEmail)
            .disposed(by: disposeBag)
        passwordTextField.rx.text
            .map { $0 ?? "" }
            .bind(to: viewModel.userPassword)
            .disposed(by: disposeBag)
        InternetHelper.shared.connectionStatus.subscribe(onNext: { [weak self] status in
            guard let self = self else { return  }
            self.loginButton.isEnabled = status == .online
        }).disposed(by: disposeBag)
    }

    private func setupView() {
        passwordView.layer.cornerRadius = 5
        passwordView.layer.borderWidth = 1
        passwordView.layer.borderColor = UIColor.lightGray.cgColor
        passwordView.layer.masksToBounds = true

        emailTextField.layer.cornerRadius = 5
        emailTextField.layer.borderWidth = 1
        emailTextField.layer.borderColor = UIColor.lightGray.cgColor
        emailTextField.layer.masksToBounds = true
        loginButton.setDisable()

        emailTextField.becomeFirstResponder()
    }

    private func setupLanguage() {
//        emailTextField.placeholder = LocalizedStrings.sc01EmailLabelPlaceHolder
//        passwordTextField.placeholder = LocalizedStrings.sc01PasswordLabelPlaceHolder
//        loginButton.setTitle(LocalizedStrings.sc01LoginLoginButtonTitle, for: .normal)
    }

    @IBAction func loginButtonTapped(_ sender: Any) {
        let photoViewController = SM02PhotoViewController.instantiateFromStoryboard()
        pushViewController(photoViewController)
    }

    @IBAction func hidePasswordButtonTapped(_ sender: Any) {
        passwordTextField.isSecureTextEntry = !passwordTextField.isSecureTextEntry
    }
}
