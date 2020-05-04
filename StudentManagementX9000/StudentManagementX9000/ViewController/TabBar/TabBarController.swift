//
//  TabBarController.swift
//  StudentManagementX9000
//
//  Created by Bui Quang Tri on 4/19/20.
//  Copyright © 2020 Bui Quang Tri. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController, UITabBarControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
        loadItem()
        deleteAllPersonButton()
        self.navigationItem.setHidesBackButton(true, animated: false)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    private func deleteAllPersonButton() {
        let clearBarButtonItem = UIBarButtonItem(title: "Clear", style: .plain, target: self, action: #selector(clear))
        navigationItem.rightBarButtonItem = clearBarButtonItem
    }

    @objc private func clear() {
        FaceApiHelper.shared.deleteAllPerson()
    }

    private func loadItem() {
        let photoViewController = SM02PhotoViewController.instantiateFromStoryboard()
        let icon1 = UITabBarItem(title: "Test Face Detection",
                                 image: UIImage(named: "someImage.png"),
                                 selectedImage: UIImage(named: "otherImage.png"))
        photoViewController.tabBarItem = icon1
        let trainGroupViewController = SM03TrainGroupViewController.instantiateFromStoryboard()
        let icon2 = UITabBarItem(title: "Test Group",
                                 image: UIImage(named: "someImage.png"),
                                 selectedImage: UIImage(named: "otherImage.png"))
        trainGroupViewController.tabBarItem = icon2
        let controllers = [photoViewController, trainGroupViewController]
        self.viewControllers = controllers
    }

    func tabBarController(_ tabBarController: UITabBarController,
                          shouldSelect viewController: UIViewController) -> Bool {
        print("Should select viewController: \(viewController.title ?? "") ?")
        return true
    }
}
