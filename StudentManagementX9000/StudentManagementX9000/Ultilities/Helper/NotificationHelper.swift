//
//  NotificationHelper.swift
//  FinancialManagementX9000
//
//  Created by TriBQ on 10/15/19.
//  Copyright © 2019 Tribq. All rights reserved.
//

import Foundation
import UIKit

class NotificationHelper: NSObject {
    static let shared = NotificationHelper()

    private var backgroundView: UIView!
    private var confirmBackgroundView: UIView!
    private var confirmImageView: UIImageView!
    private var messageLabel: UILabel!
    private(set) var isShowing = false

    private override init() {
        super.init()
        if backgroundView == nil {
            backgroundView = UIView()
            backgroundView.backgroundColor = .black
            backgroundView.layer.opacity = 0.2
        }
        if confirmBackgroundView == nil {
            confirmBackgroundView = UIView()
            confirmBackgroundView.backgroundColor = .white
            confirmBackgroundView.viewCornerRadius = 10
        }
        if confirmImageView == nil {
            confirmImageView = UIImageView()
            confirmImageView.image = UIImage(named: "confirm")
        }
        if messageLabel == nil {
            messageLabel = UILabel()
            confirmImageView.backgroundColor = .clear
        }
    }

    func show(message: String?) {
        if !isShowing {
            isShowing = true
            setupBackgroundView()
            setupConfirmBackgroundView()
            setupConfirmImageView()
            setUpLabel(message: message)
        }
    }

    func hide() {
        guard isShowing else { return }
        isShowing = false
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.confirmBackgroundView.removeFromSuperview()
            self.confirmImageView.removeFromSuperview()
            self.messageLabel.removeFromSuperview()
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

    private func setupConfirmBackgroundView() {
        guard let window = UIApplication.shared.keyWindow else { return }
        confirmBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        window.addSubview(confirmBackgroundView)
        NSLayoutConstraint.activate([
            confirmBackgroundView.centerXAnchor.constraint(equalTo: window.centerXAnchor),
            confirmBackgroundView.centerYAnchor.constraint(equalTo: window.centerYAnchor),
            confirmBackgroundView.widthAnchor.constraint(equalToConstant: 200),
            confirmBackgroundView.heightAnchor.constraint(equalToConstant: 150)
            ])
    }

    private func setupConfirmImageView() {
        guard let window = UIApplication.shared.keyWindow else { return }
        confirmImageView.translatesAutoresizingMaskIntoConstraints = false
        confirmImageView.contentMode = .scaleAspectFit
        window.addSubview(confirmImageView)
        NSLayoutConstraint.activate([
            confirmImageView.bottomAnchor.constraint(equalTo: confirmBackgroundView.bottomAnchor, constant: -20),
            confirmImageView.centerXAnchor.constraint(equalTo: window.centerXAnchor),
            confirmImageView.widthAnchor.constraint(equalToConstant: 75),
            confirmImageView.heightAnchor.constraint(equalToConstant: 75)
            ])
    }

    private func setUpLabel(message: String?) {
        messageLabel.isHidden = message == nil
        messageLabel.textAlignment = .center
        messageLabel.contentMode = .center
        messageLabel.text = message ?? ""
        messageLabel.font = messageLabel.font.withSize(12)
        guard let window = UIApplication.shared.keyWindow else { return }
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        window.addSubview(messageLabel)
        NSLayoutConstraint.activate([
            messageLabel.topAnchor.constraint(equalTo: confirmBackgroundView.topAnchor),
            messageLabel.bottomAnchor.constraint(equalTo: confirmImageView.topAnchor),
            messageLabel.centerXAnchor.constraint(equalTo: window.centerXAnchor),
            messageLabel.leadingAnchor.constraint(equalTo: confirmBackgroundView.leadingAnchor)
            ])
    }
}
