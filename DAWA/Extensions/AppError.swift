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
    case usernameTooShort
    case bioTooLong
    case groupHandleTooLong
    case groupHandleTooShort
    case groupNameTooLong
    case groupNameTooShort
    
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
            return "This username is too long. Usernames cannot exceed \(ProfileConstants.maxUsernameLength) characters."
        case .bioTooLong:
            return "Your bio is too long. Bios cannot exceed \(ProfileConstants.maxBioLength) characters."
        case .usernameTooShort:
            return "This username is too short. Usernames must contain at least \(ProfileConstants.minUsernameLength) characters."
        case .groupHandleTooLong:
            return "This group handle is too long. Group handles cannot exceed \(GroupConstants.maxHandleLength) characters."
        case .groupHandleTooShort:
            return "This group handle is too short. Group handles must contain at least \(GroupConstants.minHandleLength) characters."
        case .groupNameTooLong:
            return "This group name is too long. Group names cannot exceed \(GroupConstants.maxNameLength) characters."
        case .groupNameTooShort:
            return "This group name is too short. Group names must contain at least \(GroupConstants.minNameLength) characters."
        }
    }
}
