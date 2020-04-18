//
//  AppDelegate.swift
//  StudentManagementX9000
//
//  Created by Bui Quang Tri on 4/14/20.
//  Copyright © 2020 Bui Quang Tri. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        let loginViewController = SM01LoginViewController.instantiateFromStoryboard()
        let rootNavigationViewController = UINavigationController(rootViewController: loginViewController)
        window?.rootViewController = rootNavigationViewController
        window?.makeKeyAndVisible()
        return true
    }
}
