//
//  Toolbar+extension.swift
//  FinancialManagementX9000
//
//  Created by TriBQ on 9/11/19.
//  Copyright © 2019 Tribq. All rights reserved.
//

import Foundation
import UIKit

extension UIToolbar {
    func toolbarPiker (mySelect: Selector, viewController: UIViewController) -> UIToolbar {
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        toolBar.tintColor = UIColor.black
        toolBar.sizeToFit()

        let doneButton = UIBarButtonItem(title: LocalizedStrings.done,
                                         style: .plain,
                                         target: viewController,
                                         action: mySelect)
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)

        toolBar.setItems([spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true

        return toolBar
    }
}
