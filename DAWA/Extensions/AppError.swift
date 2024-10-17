//
//  AppError.swift
//  DAWA
//
//  Created by Tee Monsereenusorn on 11/19/23.
//

import Foundation

enum AppError: Error {
    case groupHandleAlreadyExists
    case userAlreadyHasInvite
    case groupMemberNotFound
    case usernameAlreadyExists
    case usernameTooLong
    case bioTooLong
    
    var localizedDescription: String {
        switch self {
        case .groupHandleAlreadyExists:
            return "This group handle is already taken. Please choose a different one."
        case .userAlreadyHasInvite:
            return "User was already invited to this group."
        case .groupMemberNotFound:
            return "Group member not found."
        case .usernameAlreadyExists:
            return "This username is already taken. Please choose a different one."
        case .usernameTooLong:
            return "This username is too long. Usernames cannot exceed \(ProfileConstants.maxUsernameLength) characters"
        case .bioTooLong:
            return "Your bio is too long. Bios cannot exceed \(ProfileConstants.maxBioLength) characters"
        }
    }
}
