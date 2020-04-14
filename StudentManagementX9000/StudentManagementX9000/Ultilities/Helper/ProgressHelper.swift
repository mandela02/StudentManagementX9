//
//  ProgressHelper.swift
//  FinancialManagementX9000
//
//  Created by TriBQ on 10/8/19.
//  Copyright © 2019 Tribq. All rights reserved.
//

import UIKit

class ProgressHelper: NSObject {
    static let shared = ProgressHelper()

    private var backgroundView: UIView!
    private var activityIndicatorBackgroundView: UIView!
    private var activityIndicatorView: UIActivityIndicatorView!
    private(set) var isShowing = false

    private override init() {
        super.init()
        if backgroundView == nil {
            backgroundView = UIView()
            backgroundView.backgroundColor = .black
            backgroundView.layer.opacity = 0.2
        }
        if activityIndicatorBackgroundView == nil {
            activityIndicatorBackgroundView = UIView()
            activityIndicatorBackgroundView.backgroundColor = .black
        }
        if activityIndicatorView == nil {
            activityIndicatorView = UIActivityIndicatorView(style: .white)
            activityIndicatorView.center = activityIndicatorBackgroundView.center
            activityIndicatorBackgroundView.viewCornerRadius = 10
        }
    }

    func show(isShowCancelButton: Bool = false) {
        if !isShowing {
            isShowing = true
            activityIndicatorView.startAnimating()
            setupBackgroundView()
            setupActivityIndicatorBackgroundView()
            setupIndicatorView()
        }
    }

    func hide() {
        guard isShowing else { return }
        isShowing = false
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.activityIndicatorView.stopAnimating()
            self.activityIndicatorView.removeFromSuperview()
            self.activityIndicatorBackgroundView.removeFromSuperview()
            self.backgroundView.removeFromSuperview()
        }
    }

    private func setupBackgroundView() {
        guard let window = UIApplication.shared.keyWindow else { return }
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        window.addSubview(backgroundView)
        NSLayoutConstraint.activate([
            backgroundView.topAnchor.constraint(equalTo: window.topAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: window.bottomAnchor),
            backgroundView.trailingAnchor.constraint(equalTo: window.trailingAnchor),
            backgroundView.leadingAnchor.constraint(equalTo: window.leadingAnchor)
            ])
    }

    private func setupActivityIndicatorBackgroundView() {
        guard let window = UIApplication.shared.keyWindow else { return }
        activityIndicatorBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        window.addSubview(activityIndicatorBackgroundView)
        NSLayoutConstraint.activate([
            activityIndicatorBackgroundView.centerXAnchor.constraint(equalTo: window.centerXAnchor),
            activityIndicatorBackgroundView.centerYAnchor.constraint(equalTo: window.centerYAnchor),
            activityIndicatorBackgroundView.widthAnchor.constraint(equalToConstant: 75),
            activityIndicatorBackgroundView.heightAnchor.constraint(equalToConstant: 75)
            ])
    }

    private func setupIndicatorView() {
        guard let window = UIApplication.shared.keyWindow else { return }
        activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        window.addSubview(activityIndicatorView)
        NSLayoutConstraint.activate([
            activityIndicatorView.centerXAnchor.constraint(equalTo: window.centerXAnchor),
            activityIndicatorView.centerYAnchor.constraint(equalTo: window.centerYAnchor)
            ])
    }
}
