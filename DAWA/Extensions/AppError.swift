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
    case notStanfordEmail
    case usernameAlreadyExists
    case usernameTooLong
    case usernameTooShort
    case passwordTooLong
    case passwordTooShort
    case bioTooLong
    case groupHandleTooLong
    case groupHandleTooShort
    case groupNameTooLong
    case groupNameTooShort
    case groupImageRequired
    
    var localizedDescription: String {
        switch self {
        case .groupHandleAlreadyExists:
            return "This group handle is already taken. Please choose a different one."
        case .userAlreadyHasInvite:
            return "User was already invited to this group."
        case .groupMemberNotFound:
            return "Group member not found."
        case .notStanfordEmail:
            return "You must use a Stanford email address (@stanford.edu) to sign up."
        case .usernameAlreadyExists:
            return "This username is already taken. Please choose a different one."
        case .usernameTooLong:
            return "This username is too long. Usernames cannot exceed \(ProfileConstants.maxUsernameLength) characters."
        case .usernameTooShort:
            return "This username is too short. Usernames must contain at least \(ProfileConstants.minUsernameLength) characters."
        case .passwordTooLong:
            return "This password is too long. Passwords cannot exceed \(ProfileConstants.maxPasswordLength) characters."
        case .passwordTooShort:
            return "This password is too short. Passwords must contain at least \(ProfileConstants.minPasswordLength) characters"
        case .bioTooLong:
            return "Your bio is too long. Bios cannot exceed \(ProfileConstants.maxBioLength) characters."
        case .groupHandleTooLong:
            return "This group handle is too long. Group handles cannot exceed \(GroupConstants.maxHandleLength) characters."
        case .groupHandleTooShort:
            return "This group handle is too short. Group handles must contain at least \(GroupConstants.minHandleLength) characters."
        case .groupNameTooLong:
            return "This group name is too long. Group names cannot exceed \(GroupConstants.maxNameLength) characters."
        case .groupNameTooShort:
            return "This group name is too short. Group names must contain at least \(GroupConstants.minNameLength) characters."
        case .groupImageRequired:
            return "A group image is required. Please upload an image to create the group. You can always modify the image later."
        }
    }
}
