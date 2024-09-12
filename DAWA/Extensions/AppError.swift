//
//  AppError.swift
//  Three For Die
//
//  Created by Tee Monsereenusorn on 11/19/23.
//

import Foundation

enum AppError: Error {
    case groupHandleAlreadyExists
    case userAlreadyHasInvite
    
    var localizedDescription: String {
        switch self {
        case .groupHandleAlreadyExists:
            return "This group handle is already taken. Please choose a different one."
        case .userAlreadyHasInvite:
            return "User was already invited to this group."
        }
    }
}
