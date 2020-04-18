//
//  InternetHelper.swift
//  FinancialManagementX9000
//
//  Created by TriBQ on 9/19/19.
//  Copyright © 2019 Tribq. All rights reserved.
//

import Foundation
import Reachability
import RxSwift
import RxCocoa

enum ConnectionStatus {
    case online
    case offline
}

class InternetHelper {
    static let shared = InternetHelper()

    private let reachability = try? Reachability()

    var connectionStatus: BehaviorRelay<ConnectionStatus>
        = BehaviorRelay(value: ConnectionStatus.online)

    private let disposeBag = DisposeBag()

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    private init() {
        createObservers()
    }

    private func createObservers() {
        guard let reachability = reachability else {
            return
        }
        NotificationCenter
            .default
            .addObserver(self, selector: #selector(reachabilityChanged(note:)),
                         name: .reachabilityChanged, object: reachability)
        do {
            try reachability.startNotifier()
        } catch {
            print("could not start reachability notifier")
            return
        }
    }

    @objc private func reachabilityChanged(note: Notification) {
        guard let reachability = note.object as? Reachability else {
            return
        }
        switch reachability.connection {
        case .wifi, .cellular:
            connectionStatus.accept(ConnectionStatus.online)
        case .none, .unavailable:
            connectionStatus.accept(ConnectionStatus.offline)
        }
    }
}
