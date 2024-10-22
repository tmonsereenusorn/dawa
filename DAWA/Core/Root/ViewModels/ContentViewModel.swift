//
//  ContentViewModel.swift
//  DAWA
//
//  Created by Tee Monsereenusorn on 8/8/23.
//

import Foundation
import Combine
import FirebaseAuth

class ContentViewModel: ObservableObject {
    @Published var currentUser: User?
    @Published var userSession: FirebaseAuth.User?
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupSubscribers()
    }
    
    private func setupSubscribers() {
        UserService.shared.$currentUser.sink { [weak self] user in
            self?.currentUser = user
        }.store(in: &cancellables)
        
        AuthService.shared.$userSession.sink { [weak self] session in
            self?.userSession = session
        }.store(in: &cancellables)
    }
}
