//
//  RightSideMenuViewModel.swift
//  Three For Die
//
//  Created by Tee Monsereenusorn on 7/7/23.
//

import Foundation

enum RightSideMenuViewModel: Int, CaseIterable {
    case profile
    case logout
    
    var title: String {
        switch self {
        case .profile: return "Profile"
        case .logout: return "Logout"
        }
    }
    
    var imageName: String {
        switch self {
        case .profile: return "person"
        case .logout: return "arrow.left.square"
        }
    }
}
