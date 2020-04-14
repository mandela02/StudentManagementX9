//
//  UIViewController+Extension.swift
//  SimpleCalendar
//
//  Created by Cong Nguyen on 9/28/18.
//  Copyright © 2018 komorebi. All rights reserved.
//

import UIKit

extension UIViewController {
    
    var safeAreaInsets: UIEdgeInsets? {
        if #available(iOS 11.0, *) {
            let window = UIApplication.shared.keyWindow
            if let safeArea = window?.safeAreaInsets {
                return safeArea
            }
        }
        return nil
    }
    
    var appDelegate: AppDelegate? {
        return UIApplication.shared.delegate as? AppDelegate
    }
    
    public class func vc() -> Self {
        return self.init(nibName: String(describing: self), bundle: nil)
    }
    
    class func instantiate<T: UIViewController>(_: T.Type, storyboard: String) -> T {
        let storyboard = UIStoryboard(name: storyboard, bundle: nil)
        guard let ViewController = storyboard.instantiateViewController(withIdentifier: T.className) as? T else {
            fatalError("Can not instantiate viewcontroller from storyboard \(storyboard)")
        }
        return ViewController
    }
    
    static func instantiateFromStoryboard(identifier: String = "") -> Self {
        return instantiateFromStoryboard(viewControllerClass: self, identifier: identifier)
    }
    
    private static func instantiateFromStoryboard<T: UIViewController>(viewControllerClass: T.Type, identifier: String = "", function: String = #function, line: Int = #line, file: String = #file) -> T {
        
        var storyboardName = ""
        var controllerIdentifer = ""
        if identifier != "" {
            storyboardName = identifier
            controllerIdentifer = (viewControllerClass as UIViewController.Type).className
        } else {
            storyboardName = (viewControllerClass as UIViewController.Type).className
            controllerIdentifer = storyboardName
        }
        
        let storyboard = UIStoryboard(name: storyboardName, bundle: Bundle.main)
        guard let scene = storyboard.instantiateViewController(withIdentifier: controllerIdentifer) as? T else {
            fatalError("ViewController with identifier \(storyboardName), not found in \(storyboardName) Storyboard.\nFile : \(file) \nLine Number : \(line)")
        }
        return scene
    }

    var safeAreaInsetBottom: CGFloat {
        var height: CGFloat = 0
        if #available(iOS 11.0, *), let window = UIApplication.shared.keyWindow {
            height = window.safeAreaInsets.bottom
        }
        return height
    }
}
