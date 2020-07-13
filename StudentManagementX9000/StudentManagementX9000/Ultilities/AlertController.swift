//
//  AlertController.swift
//  FinancialManagementX9000
//
//  Created by TriBQ on 9/14/19.
//  Copyright © 2019 Tribq. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

enum SelectCamera {
    case openLibrary
    case openCamera
    case cancel
}

enum SelectCase {
    case confirm
    case cancel
}

class AlertController: NSObject {
    private let disposeBag = DisposeBag()
    static let shared = AlertController()
    private var alertController: UIAlertController?

    func showErrorMessage(message: String) -> Observable<Void> {
        return Observable.create({ (observable) -> Disposable in
            if self.alertController != nil {
                self.alertController?.dismiss(animated: false, completion: nil)
                self.alertController = nil
            }
            self.alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
            let okAction = UIAlertAction(title: LocalizedStrings.ok, style: .cancel, handler: { _ in
                self.alertController = nil
                observable.onNext(())
                observable.onCompleted()
            })
            self.alertController?.addAction(okAction)
            DispatchQueue.main.async {
                UIApplication.topViewController()?.present(self.alertController!, animated: true, completion: nil)
            }
            return Disposables.create()
        })
    }

    func openAlert(identifer: String) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let alert = storyboard.instantiateViewController(withIdentifier: identifer)
        alert.modalPresentationStyle = .overFullScreen
        alert.modalTransitionStyle = .crossDissolve
        UIApplication.topViewController()?.present(alert, animated: true, completion: nil)
    }

    func showConfirmMessage(message: String, confirm: String, cancel: String) -> Observable<SelectCase> {
        return Observable.create({ (observable) -> Disposable in
            if self.alertController != nil {
                self.alertController?.dismiss(animated: false, completion: nil)
                self.alertController = nil
            }
            self.alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
            let confirmAction = UIAlertAction(title: confirm, style: .default, handler: { (_) in
                self.alertController = nil
                observable.onNext(.confirm)
                observable.onCompleted()
            })
            let cancelAction = UIAlertAction(title: cancel, style: .destructive, handler: { (_) in
                self.alertController = nil
                observable.onNext(.cancel)
                observable.onCompleted()
            })
            self.alertController?.addAction(cancelAction)
            self.alertController?.addAction(confirmAction)
            UIApplication.topViewController()?.present(self.alertController!, animated: true, completion: nil)
            return Disposables.create()
        })
    }
}

// swiftlint:disable line_length
extension UIApplication {
    class func topViewController(base: UIViewController? = (UIApplication.shared.delegate as? AppDelegate)?.window?.rootViewController) -> UIViewController? {
        if let navigationController = base as? UINavigationController {
            return topViewController(base: navigationController.visibleViewController)
        }
        if let tabBarController = base as? UITabBarController {
            if let selected = tabBarController.selectedViewController {
                return topViewController(base: selected)
            }
        }
        if let presented = base?.presentedViewController {
            return topViewController(base: presented)
        }
        return base
    }
}
