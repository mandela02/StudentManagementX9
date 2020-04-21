//
//  BaseViewController.swift
//  FinancialManagementX9000
//
//  Created by TriBQ on 9/3/19.
//  Copyright © 2019 Tribq. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController {

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        addNotificationObservers()
        configureObservers()
    }

    func  configureLocalizedStrings() {}

    func configureView() {}

    func configureObservers() {}

    func pushViewController(_ viewController: UIViewController) {
        viewController.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(viewController, animated: true)
    }

    private func addNotificationObservers() {
        NotificationCenter.default
            .addObserver(self,
                         selector: #selector(changeLanguage),
                         name: NSNotification.Name(Strings.languageChangedObserver),
                         object: nil)
    }

    @objc private func changeLanguage() {
        configureLocalizedStrings()
    }
}
