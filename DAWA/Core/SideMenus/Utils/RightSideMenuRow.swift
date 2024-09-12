//
//  RightSideMenuViewModel.swift
//  Three For Die
//
//  Created by Tee Monsereenusorn on 7/7/23.
//

import Foundation

enum RightSideMenuRow: Int, CaseIterable {
    case profile
    case logout
    case delete
    
    var title: String {
        switch self {
        case .profile: return "Profile"
        case .logout: return "Logout"
        case .delete: return "Delete Account"
        }
    }
    
    var imageName: String {
        switch self {
        case .profile: return "person"
        case .logout: return "arrow.left.square"
        case .delete: return "trash"
        }
    }
}
