//
//  BaseTableViewController.swift
//  FinancialManagementX9000
//
//  Created by TriBQ on 9/9/19.
//  Copyright © 2019 Tribq. All rights reserved.
//

import UIKit

class BaseTableViewController: UITableViewController {

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        addNotificationObservers()
        configureView()
        configureObservers()
    }

    func  configureLocalizedStrings() {}

    func configureView() {}

    func configureObservers() {}

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
