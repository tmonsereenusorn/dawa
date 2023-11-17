//
//  NotificationsViewModel.swift
//  Three For Die
//
//  Created by Tee Monsereenusorn on 11/16/23.
//

import Foundation
import Combine

class NotificationsViewModel: ObservableObject {
    @Published var user: User?
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupSubscribers()
    }
    
    private func setupSubscribers() {
        UserService.shared.$currentUser.sink { [weak self] user in
            self?.user = user
        }.store(in: &cancellables)
        
        
    }
}
